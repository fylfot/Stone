import Foundation
import SwiftData

@Model
final class Project: Identifiable {
    var id: UUID
    var name: String
    var colorHex: String
    var isArchived: Bool
    var createdAt: Date
    var sortOrder: Int

    @Relationship(deleteRule: .cascade, inverse: \TimeEntry.project)
    var entries: [TimeEntry] = []

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#007AFF",
        isArchived: Bool = false,
        createdAt: Date = .now,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.isArchived = isArchived
        self.createdAt = createdAt
        self.sortOrder = sortOrder
    }

    var totalDuration: TimeInterval {
        entries.reduce(0) { $0 + $1.duration }
    }

    var todayDuration: TimeInterval {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: .now)
        return entries
            .filter { $0.startedAt >= startOfDay }
            .reduce(0) { $0 + $1.duration }
    }

    var thisWeekDuration: TimeInterval {
        let calendar = Calendar.current
        guard let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: .now)) else {
            return 0
        }
        return entries
            .filter { $0.startedAt >= weekStart }
            .reduce(0) { $0 + $1.duration }
    }
}
