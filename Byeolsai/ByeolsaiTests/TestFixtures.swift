import Foundation
@testable import Byeolsai

enum Fixtures {
    static let catalog = UniverseCatalog(
        regions: [
            Region(id: "r0", name: "첫 성계", requiredTotalFocusSeconds: 0, artAsset: "sun.max.fill"),
            Region(id: "r1", name: "둘째 성계", requiredTotalFocusSeconds: 3600, artAsset: "star.fill"),
            Region(id: "r2", name: "셋째 성계", requiredTotalFocusSeconds: 10800, artAsset: "sparkle")
        ],
        destinations: [
            Destination(id: "d0", name: "달", regionID: "r0", travelSeconds: 600, artAsset: "moon.fill"),
            Destination(id: "d1", name: "행성", regionID: "r1", travelSeconds: 1800, artAsset: "globe")
        ],
        ships: [
            Ship(id: "s0", name: "기본선", requiredTotalFocusSeconds: 0, artAsset: "paperplane.fill"),
            Ship(id: "s1", name: "고급선", requiredTotalFocusSeconds: 7200, artAsset: "bolt.fill")
        ]
    )

    static func profile(totalFocusSeconds: Int = 0, streak: Int = 0, lastFocusDay: Date? = nil) -> UserProfile {
        var profile = UserProfile(
            id: UUID(),
            displayName: "",
            createdAt: .now,
            currentShipID: "s0",
            totalFocusSeconds: totalFocusSeconds,
            currentStreak: streak,
            lastFocusDay: lastFocusDay,
            unlockedRegionIDs: [],
            unlockedShipIDs: []
        )
        _ = MilestoneEngine(catalog: catalog).apply(to: &profile)
        return profile
    }
}
