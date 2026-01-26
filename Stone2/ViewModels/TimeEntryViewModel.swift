import Foundation
import SwiftData

@Observable
final class TimeEntryViewModel {
    private(set) var entries: [TimeEntry] = []
    private(set) var projects: [Project] = []
    private var modelContext: ModelContext?

    // Edit state
    var editingEntry: TimeEntry?
    var isEditing: Bool = false
    var editStartDate: Date = .now
    var editEndDate: Date = .now
    var editNote: String = ""
    var editProjectId: UUID?

    // Add state
    var isAdding: Bool = false
    var addStartDate: Date = .now
    var addEndDate: Date = .now
    var addNote: String = ""
    var addProjectId: UUID?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadProjects()
        loadEntries()
    }

    func loadEntries(for date: Date? = nil) {
        guard let modelContext else { return }

        let targetDate = date ?? .now
        let startOfDay = targetDate.startOfDay
        let endOfDay = targetDate.endOfDay

        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate { entry in
                entry.startedAt >= startOfDay && entry.startedAt <= endOfDay
            },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        do {
            entries = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries: \(error)")
        }
    }

    func loadProjects() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Project>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.sortOrder)]
        )

        do {
            projects = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch projects: \(error)")
        }
    }

    func startEditing(_ entry: TimeEntry) {
        editingEntry = entry
        editStartDate = entry.startedAt
        editEndDate = entry.endedAt ?? .now
        editNote = entry.note ?? ""
        editProjectId = entry.project?.id
        isEditing = true
    }

    func saveEdit() {
        guard let entry = editingEntry else { return }

        entry.startedAt = editStartDate
        entry.endedAt = editEndDate
        entry.note = editNote.isEmpty ? nil : editNote

        if let projectId = editProjectId,
           let project = projects.first(where: { $0.id == projectId }) {
            entry.project = project
        }

        try? modelContext?.save()
        isEditing = false
        editingEntry = nil
        loadEntries()
    }

    func cancelEdit() {
        isEditing = false
        editingEntry = nil
    }

    func deleteEntry(_ entry: TimeEntry) {
        guard let modelContext else { return }
        modelContext.delete(entry)
        try? modelContext.save()
        loadEntries()
    }

    func startAdding() {
        addStartDate = .now.addingTimeInterval(-3600) // Default to 1 hour ago
        addEndDate = .now
        addNote = ""
        addProjectId = projects.first?.id
        isAdding = true
    }

    func saveAdd() {
        guard let modelContext else { return }

        let entry = TimeEntry(
            startedAt: addStartDate,
            endedAt: addEndDate,
            note: addNote.isEmpty ? nil : addNote,
            source: .manual
        )

        if let projectId = addProjectId,
           let project = projects.first(where: { $0.id == projectId }) {
            entry.project = project
            project.entries.append(entry)
        }

        modelContext.insert(entry)
        try? modelContext.save()
        isAdding = false
        loadEntries()
    }

    func cancelAdd() {
        isAdding = false
    }
}
