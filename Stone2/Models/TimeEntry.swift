import Foundation
import SwiftData

enum EntrySource: String, Codable {
    case manual
    case automatic
}

@Model
final class TimeEntry: Identifiable {
    var id: UUID
    var startedAt: Date
    var endedAt: Date?
    var note: String?
    var source: EntrySource

    var project: Project?

    init(
        id: UUID = UUID(),
        startedAt: Date = .now,
        endedAt: Date? = nil,
        note: String? = nil,
        source: EntrySource = .automatic,
        project: Project? = nil
    ) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.note = note
        self.source = source
        self.project = project
    }

    var duration: TimeInterval {
        let end = endedAt ?? .now
        return end.timeIntervalSince(startedAt)
    }

    var isRunning: Bool {
        endedAt == nil
    }

    func stop() {
        guard endedAt == nil else { return }
        endedAt = .now
    }
}
