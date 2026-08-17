import Foundation
import Testing
@testable import Byeolsai

struct WidgetSnapshotTests {
    let snapshot = WidgetSnapshot(
        todaySeconds: 1500,
        totalFocusSeconds: 7200,
        currentStreak: 3,
        nextRegionName: "시리우스",
        nextRegionProgress: 0.33,
        updatedAt: Date(timeIntervalSince1970: 1_787_200_000)
    )

    @Test func roundTripsThroughSharedStore() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("snapshot-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }

        SharedStore.write(snapshot, to: url)
        let loaded = SharedStore.read(from: url)
        #expect(loaded == snapshot)
    }

    @Test func readReturnsNilWhenFileMissing() {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("missing-\(UUID().uuidString).json")
        #expect(SharedStore.read(from: url) == nil)
    }

    @Test func nilURLIsANoOp() {
        SharedStore.write(snapshot, to: nil)
        #expect(SharedStore.read(from: nil) == nil)
    }
}
