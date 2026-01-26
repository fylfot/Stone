import Foundation
import SwiftData
import Combine

@Observable
final class MenuBarViewModel {
    private(set) var projects: [Project] = []
    private(set) var currentDuration: TimeInterval = 0
    private(set) var isTracking: Bool = false
    private(set) var showIdleAlert: Bool = false
    private(set) var idleSeconds: TimeInterval = 0

    private var timeTracker: TimeTrackerService
    private var systemEvents: SystemEventService
    private var modelContext: ModelContext?
    private var timerCancellable: AnyCancellable?

    var activeProject: Project? {
        timeTracker.activeProject
    }

    var statusText: String {
        if isTracking {
            return currentDuration.formattedDuration
        }
        return "Stone"
    }

    init(
        timeTracker: TimeTrackerService,
        systemEvents: SystemEventService
    ) {
        self.timeTracker = timeTracker
        self.systemEvents = systemEvents
        setupSystemEvents()
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        timeTracker.configure(modelContext: modelContext)
        loadProjects()
        updateTrackingState()
        startTimerUpdates()
    }

    func startTracking(project: Project) {
        do {
            try timeTracker.start(project: project)
            updateTrackingState()
        } catch {
            print("Failed to start tracking: \(error)")
        }
    }

    func stopTracking() {
        do {
            try timeTracker.stop()
            updateTrackingState()
        } catch {
            print("Failed to stop tracking: \(error)")
        }
    }

    func switchProject(_ project: Project) {
        do {
            try timeTracker.switchTo(project: project)
            updateTrackingState()
        } catch {
            print("Failed to switch project: \(error)")
        }
    }

    func createProject(name: String, colorHex: String) {
        guard let modelContext else { return }

        let project = Project(
            name: name,
            colorHex: colorHex,
            sortOrder: projects.count
        )

        modelContext.insert(project)
        try? modelContext.save()
        loadProjects()
    }

    func keepIdleTime() {
        showIdleAlert = false
        idleSeconds = 0
    }

    func discardIdleTime() {
        guard let entry = timeTracker.activeEntry else {
            showIdleAlert = false
            idleSeconds = 0
            return
        }

        // Adjust the entry to subtract idle time
        let newEnd = Date.now.addingTimeInterval(-idleSeconds)
        entry.endedAt = newEnd

        // Create a new entry starting now if we want to continue
        if let project = timeTracker.activeProject {
            try? timeTracker.start(project: project)
        }

        showIdleAlert = false
        idleSeconds = 0
        try? modelContext?.save()
    }

    private func loadProjects() {
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

    private func updateTrackingState() {
        isTracking = timeTracker.isTracking
        currentDuration = timeTracker.currentDuration
    }

    private func startTimerUpdates() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTrackingState()
            }
    }

    private func setupSystemEvents() {
        systemEvents.onSystemWillSleep = { [weak self] in
            self?.timeTracker.handleSystemWillSleep()
        }

        systemEvents.onSystemDidWake = { [weak self] idleSeconds in
            guard let self, self.isTracking, idleSeconds > 60 else { return }
            self.idleSeconds = idleSeconds
            self.showIdleAlert = true
        }

        systemEvents.onIdleDetected = { [weak self] idleSeconds in
            guard let self, self.isTracking else { return }
            self.idleSeconds = idleSeconds
            self.showIdleAlert = true
        }

        systemEvents.startObserving()
    }
}
