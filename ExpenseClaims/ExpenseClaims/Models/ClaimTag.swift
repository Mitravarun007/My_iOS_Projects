import Foundation
import SwiftData

/// A lightweight, reusable tag (e.g. "Client Visit June 2026") used to group
/// bills together before raising a claim. Mirrors the "recent tags" chips
/// shown in the Save Bill flow.
@Model
final class ClaimTag {
    var id: UUID
    var name: String
    var createdAt: Date

    init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
        self.id = id
        self.name = name
        self.createdAt = createdAt
    }
}
