import Foundation
import SwiftData

enum ReportPeriod: String, CaseIterable {
    case today = "Today"
    case yesterday = "Yesterday"
    case thisWeek = "This Week"
    case lastWeek = "Last Week"
    case thisMonth = "This Month"
    case lastMonth = "Last Month"
    case custom = "Custom"

    var dateRange: (start: Date, end: Date) {
        let calendar = Calendar.current
        let now = Date.now

        switch self {
        case .today:
            let start = calendar.startOfDay(for: now)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return (start, end)

        case .yesterday:
            let today = calendar.startOfDay(for: now)
            let start = calendar.date(byAdding: .day, value: -1, to: today)!
            return (start, today)

        case .thisWeek:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let weekEnd = calendar.date(byAdding: .day, value: 7, to: weekStart)!
            return (weekStart, weekEnd)

        case .lastWeek:
            let thisWeekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now))!
            let lastWeekStart = calendar.date(byAdding: .day, value: -7, to: thisWeekStart)!
            return (lastWeekStart, thisWeekStart)

        case .thisMonth:
            let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let monthEnd = calendar.date(byAdding: .month, value: 1, to: monthStart)!
            return (monthStart, monthEnd)

        case .lastMonth:
            let thisMonthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: now))!
            let lastMonthStart = calendar.date(byAdding: .month, value: -1, to: thisMonthStart)!
            return (lastMonthStart, thisMonthStart)

        case .custom:
            // Default to this week for custom
            return ReportPeriod.thisWeek.dateRange
        }
    }
}

struct ProjectSummary: Identifiable {
    let id: UUID
    let name: String
    let colorHex: String
    let duration: TimeInterval
    let percentage: Double
}

struct DaySummary: Identifiable {
    let id = UUID()
    let date: Date
    let totalDuration: TimeInterval
    let projectBreakdown: [ProjectSummary]
}

@Observable
final class ReportsViewModel {
    private(set) var entries: [TimeEntry] = []
    private(set) var projects: [Project] = []
    private(set) var projectSummaries: [ProjectSummary] = []
    private(set) var dailySummaries: [DaySummary] = []
    private(set) var totalDuration: TimeInterval = 0
    private var modelContext: ModelContext?

    var selectedPeriod: ReportPeriod = .thisWeek {
        didSet {
            if selectedPeriod != .custom {
                let range = selectedPeriod.dateRange
                customStartDate = range.start
                customEndDate = range.end
            }
            loadData()
        }
    }

    var customStartDate: Date = Date.now.addingTimeInterval(-7 * 24 * 3600) {
        didSet { if selectedPeriod == .custom { loadData() } }
    }

    var customEndDate: Date = Date.now {
        didSet { if selectedPeriod == .custom { loadData() } }
    }

    var searchText: String = "" {
        didSet { loadData() }
    }

    var startDate: Date {
        selectedPeriod == .custom ? customStartDate : selectedPeriod.dateRange.start
    }

    var endDate: Date {
        selectedPeriod == .custom ? customEndDate : selectedPeriod.dateRange.end
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProjects()
        loadData()
    }

    private func loadProjects() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        do {
            projects = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch projects: \(error)")
        }
    }

    func loadData() {
        loadEntries()
        calculateProjectSummaries()
        calculateDailySummaries()
    }

    private func loadEntries() {
        guard let modelContext else { return }

        let start = startDate
        let end = endDate
        let search = searchText.lowercased()

        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate { entry in
                entry.startedAt >= start && entry.startedAt < end
            },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        do {
            var fetched = try modelContext.fetch(descriptor)

            // Apply text search filter
            if !search.isEmpty {
                fetched = fetched.filter { entry in
                    let projectName = entry.project?.name.lowercased() ?? ""
                    let note = entry.note?.lowercased() ?? ""
                    return projectName.contains(search) || note.contains(search)
                }
            }

            entries = fetched
            totalDuration = entries.reduce(0) { $0 + $1.duration }
        } catch {
            print("Failed to fetch entries: \(error)")
        }
    }

    private func calculateProjectSummaries() {
        var durationByProject: [UUID: TimeInterval] = [:]

        for entry in entries {
            guard let projectId = entry.project?.id else { continue }
            durationByProject[projectId, default: 0] += entry.duration
        }

        projectSummaries = durationByProject.compactMap { projectId, duration in
            guard let project = projects.first(where: { $0.id == projectId }) else { return nil }
            let percentage = totalDuration > 0 ? (duration / totalDuration) * 100 : 0
            return ProjectSummary(
                id: projectId,
                name: project.name,
                colorHex: project.colorHex,
                duration: duration,
                percentage: percentage
            )
        }.sorted { $0.duration > $1.duration }
    }

    private func calculateDailySummaries() {
        let calendar = Calendar.current
        var entriesByDay: [Date: [TimeEntry]] = [:]

        for entry in entries {
            let dayStart = calendar.startOfDay(for: entry.startedAt)
            entriesByDay[dayStart, default: []].append(entry)
        }

        dailySummaries = entriesByDay.map { date, dayEntries in
            let totalDuration = dayEntries.reduce(0) { $0 + $1.duration }

            var projectDurations: [UUID: TimeInterval] = [:]
            for entry in dayEntries {
                guard let projectId = entry.project?.id else { continue }
                projectDurations[projectId, default: 0] += entry.duration
            }

            let breakdown = projectDurations.compactMap { projectId, duration -> ProjectSummary? in
                guard let project = projects.first(where: { $0.id == projectId }) else { return nil }
                let percentage = totalDuration > 0 ? (duration / totalDuration) * 100 : 0
                return ProjectSummary(
                    id: projectId,
                    name: project.name,
                    colorHex: project.colorHex,
                    duration: duration,
                    percentage: percentage
                )
            }.sorted { $0.duration > $1.duration }

            return DaySummary(date: date, totalDuration: totalDuration, projectBreakdown: breakdown)
        }.sorted { $0.date > $1.date }
    }

    func exportToCSV() -> String {
        var csv = "Date,Start Time,End Time,Duration (hours),Project,Note\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"

        for entry in entries.sorted(by: { $0.startedAt < $1.startedAt }) {
            let date = dateFormatter.string(from: entry.startedAt)
            let start = timeFormatter.string(from: entry.startedAt)
            let end = entry.endedAt.map { timeFormatter.string(from: $0) } ?? "Running"
            let hours = String(format: "%.2f", entry.duration / 3600)
            let project = entry.project?.name ?? "No Project"
            let note = entry.note ?? ""

            // Escape fields with commas or quotes
            let escapedProject = project.contains(",") ? "\"\(project)\"" : project
            let escapedNote = note.contains(",") || note.contains("\"")
                ? "\"\(note.replacingOccurrences(of: "\"", with: "\"\""))\""
                : note

            csv += "\(date),\(start),\(end),\(hours),\(escapedProject),\(escapedNote)\n"
        }

        return csv
    }

    func saveCSVToFile() -> URL? {
        let csv = exportToCSV()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let fileName = "Stone_Report_\(dateFormatter.string(from: startDate))_to_\(dateFormatter.string(from: endDate)).csv"

        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent(fileName)

        do {
            try csv.write(to: fileURL, atomically: true, encoding: .utf8)
            return fileURL
        } catch {
            print("Failed to save CSV: \(error)")
            return nil
        }
    }
}
