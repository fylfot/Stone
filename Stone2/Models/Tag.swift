import Foundation
import SwiftData

@Model
final class Tag: Identifiable {
    var id: UUID
    var name: String
    var colorHex: String

    @Relationship(inverse: \Project.tags)
    var projects: [Project] = []

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#8E8E93"
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
    }
}
