import Foundation
import SwiftData
import Combine

@Observable
final class TimeTrackerService {
    private(set) var activeEntry: TimeEntry?
    private(set) var activeProject: Project?
    private var modelContext: ModelContext?
    private var timerCancellable: AnyCancellable?

    var isTracking: Bool {
        activeEntry != nil
    }

    var currentDuration: TimeInterval {
        guard let entry = activeEntry else { return 0 }
        return entry.duration
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        restoreActiveEntry()
    }

    func start(project: Project) throws {
        guard let modelContext else {
            throw TimeTrackerError.notConfigured
        }

        // Stop any existing timer first
        if activeEntry != nil {
            try stop()
        }

        let entry = TimeEntry(
            startedAt: .now,
            source: .automatic,
            project: project
        )

        modelContext.insert(entry)
        project.entries.append(entry)

        activeEntry = entry
        activeProject = project

        try modelContext.save()
    }

    func stop() throws {
        guard let modelContext else {
            throw TimeTrackerError.notConfigured
        }

        guard let entry = activeEntry else { return }

        entry.stop()
        activeEntry = nil
        activeProject = nil

        try modelContext.save()
    }

    func switchTo(project: Project) throws {
        try stop()
        try start(project: project)
    }

    func handleSystemWillSleep() {
        guard let entry = activeEntry else { return }
        entry.stop()
        try? modelContext?.save()
    }

    func handleSystemDidWake(afterIdleSeconds: TimeInterval) {
        // Will be handled by idle detection
    }

    private func restoreActiveEntry() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<TimeEntry>(
            predicate: #Predicate { $0.endedAt == nil },
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        do {
            let runningEntries = try modelContext.fetch(descriptor)
            if let entry = runningEntries.first {
                activeEntry = entry
                activeProject = entry.project
            }
        } catch {
            print("Failed to restore active entry: \(error)")
        }
    }
}

enum TimeTrackerError: LocalizedError {
    case notConfigured
    case noActiveTimer

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "TimeTrackerService is not configured with a ModelContext"
        case .noActiveTimer:
            return "No active timer to stop"
        }
    }
}
