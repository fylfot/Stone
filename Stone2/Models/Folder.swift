import Foundation
import SwiftData

@Model
final class Folder: Identifiable {
    var id: UUID
    var name: String
    var sortOrder: Int
    var isExpanded: Bool

    @Relationship(deleteRule: .nullify, inverse: \Project.folder)
    var projects: [Project] = []

    init(
        id: UUID = UUID(),
        name: String,
        sortOrder: Int = 0,
        isExpanded: Bool = true
    ) {
        self.id = id
        self.name = name
        self.sortOrder = sortOrder
        self.isExpanded = isExpanded
    }
}
