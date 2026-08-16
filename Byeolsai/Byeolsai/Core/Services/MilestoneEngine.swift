import Foundation

struct UnlockResult: Equatable, Sendable {
    let newRegions: [Region]
    let newShips: [Ship]

    var isEmpty: Bool { newRegions.isEmpty && newShips.isEmpty }

    static let none = UnlockResult(newRegions: [], newShips: [])
}

struct MilestoneEngine: Sendable {
    let catalog: UniverseCatalog

    func unlockedRegionIDs(totalFocusSeconds: Int) -> [String] {
        catalog.regions
            .filter { $0.requiredTotalFocusSeconds <= totalFocusSeconds }
            .map(\.id)
    }

    func unlockedShipIDs(totalFocusSeconds: Int) -> [String] {
        catalog.ships
            .filter { $0.requiredTotalFocusSeconds <= totalFocusSeconds }
            .map(\.id)
    }

    func apply(to profile: inout UserProfile) -> UnlockResult {
        let regionIDs = unlockedRegionIDs(totalFocusSeconds: profile.totalFocusSeconds)
        let shipIDs = unlockedShipIDs(totalFocusSeconds: profile.totalFocusSeconds)
        let newRegions = regionIDs
            .filter { !profile.unlockedRegionIDs.contains($0) }
            .compactMap { catalog.region(id: $0) }
        let newShips = shipIDs
            .filter { !profile.unlockedShipIDs.contains($0) }
            .compactMap { catalog.ship(id: $0) }
        profile.unlockedRegionIDs = regionIDs
        profile.unlockedShipIDs = shipIDs
        return UnlockResult(newRegions: newRegions, newShips: newShips)
    }

    func nextRegionMilestone(totalFocusSeconds: Int) -> (region: Region, remainingSeconds: Int)? {
        catalog.regions
            .filter { $0.requiredTotalFocusSeconds > totalFocusSeconds }
            .min { $0.requiredTotalFocusSeconds < $1.requiredTotalFocusSeconds }
            .map { ($0, $0.requiredTotalFocusSeconds - totalFocusSeconds) }
    }
}
