import Testing
@testable import Byeolsai

struct MilestoneEngineTests {
    let engine = MilestoneEngine(catalog: Fixtures.catalog)

    @Test func unlocksOnlyZeroThresholdContentAtStart() {
        #expect(engine.unlockedRegionIDs(totalFocusSeconds: 0) == ["r0"])
        #expect(engine.unlockedShipIDs(totalFocusSeconds: 0) == ["s0"])
    }

    @Test func unlocksRegionWhenThresholdCrossed() {
        #expect(engine.unlockedRegionIDs(totalFocusSeconds: 3600) == ["r0", "r1"])
    }

    @Test func applyReportsNewlyUnlockedContentOnce() {
        var profile = Fixtures.profile()
        profile.totalFocusSeconds = 7200

        let first = engine.apply(to: &profile)
        #expect(first.newRegions.map(\.id) == ["r1"])
        #expect(first.newShips.map(\.id) == ["s1"])

        let second = engine.apply(to: &profile)
        #expect(second.isEmpty)
    }

    @Test func nextMilestoneReportsRemainingSeconds() {
        let next = engine.nextRegionMilestone(totalFocusSeconds: 3000)
        #expect(next?.region.id == "r1")
        #expect(next?.remainingSeconds == 600)
    }

    @Test func nextMilestoneIsNilWhenEverythingUnlocked() {
        #expect(engine.nextRegionMilestone(totalFocusSeconds: 999999) == nil)
    }
}
