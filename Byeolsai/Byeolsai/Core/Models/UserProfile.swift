import Foundation

struct UserProfile: Codable, Equatable, Sendable {
    var id: UUID
    var displayName: String
    var createdAt: Date
    var currentShipID: String
    var totalFocusSeconds: Int
    var currentStreak: Int
    var lastFocusDay: Date?
    var unlockedRegionIDs: [String]
    var unlockedShipIDs: [String]
}
