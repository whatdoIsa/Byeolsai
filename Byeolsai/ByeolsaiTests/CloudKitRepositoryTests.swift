import Foundation
import Testing
@testable import Byeolsai

struct CloudKitRepositoryTests {
    private func makeRepository(legacy: LocalJSONRepository? = nil) -> CloudKitRepository {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("cd-\(UUID().uuidString).sqlite")
        return CloudKitRepository(cloudSyncEnabled: false, storeURL: storeURL, migratingFrom: legacy)
    }

    private func makeLegacy(withData: Bool) async throws -> LocalJSONRepository {
        let directory = FileManager.default.temporaryDirectory
            .appendingPathComponent("legacy-\(UUID().uuidString)", isDirectory: true)
        let legacy = LocalJSONRepository(directory: directory)
        if withData {
            var profile = Fixtures.profile()
            profile.totalFocusSeconds = 7200
            profile.currentStreak = 5
            try await legacy.save(profile: profile)
            try await legacy.save(session: FocusSession(
                id: UUID(),
                startAt: Date(timeIntervalSince1970: 1_787_000_000),
                endAt: Date(timeIntervalSince1970: 1_787_001_500),
                focusSeconds: 1500,
                mode: .phoneDown,
                destinationID: "d0",
                valid: true,
                hasVideoLog: false
            ))
        }
        return legacy
    }

    @Test func profileRoundTrip() async throws {
        let repository = makeRepository()
        #expect(try await repository.loadProfile() == nil)

        var profile = Fixtures.profile()
        profile.totalFocusSeconds = 3600
        try await repository.save(profile: profile)

        let loaded = try await repository.loadProfile()
        #expect(loaded == profile)
    }

    @Test func savingProfileTwiceKeepsSingleRecord() async throws {
        let repository = makeRepository()
        var profile = Fixtures.profile()
        try await repository.save(profile: profile)
        profile.totalFocusSeconds = 9999
        try await repository.save(profile: profile)

        let loaded = try await repository.loadProfile()
        #expect(loaded?.totalFocusSeconds == 9999)
    }

    @Test func sessionsPersistAndSortByStartDate() async throws {
        let repository = makeRepository()
        let older = FocusSession(
            id: UUID(),
            startAt: Date(timeIntervalSince1970: 1_787_000_000),
            endAt: Date(timeIntervalSince1970: 1_787_000_600),
            focusSeconds: 600,
            mode: .phoneDown,
            destinationID: "d0",
            valid: true,
            hasVideoLog: false
        )
        let newer = FocusSession(
            id: UUID(),
            startAt: Date(timeIntervalSince1970: 1_787_100_000),
            endAt: Date(timeIntervalSince1970: 1_787_101_500),
            focusSeconds: 1500,
            mode: .cam,
            destinationID: "d1",
            valid: true,
            hasVideoLog: false
        )
        try await repository.save(session: newer)
        try await repository.save(session: older)

        let sessions = try await repository.allSessions()
        #expect(sessions == [older, newer])
    }

    @Test func migratesLegacyJSONDataOnce() async throws {
        let legacy = try await makeLegacy(withData: true)
        let repository = makeRepository(legacy: legacy)

        try await repository.prepare()
        #expect(try await repository.loadProfile()?.totalFocusSeconds == 7200)
        #expect(try await repository.allSessions().count == 1)

        try await repository.prepare()
        #expect(try await repository.allSessions().count == 1)
    }

    @Test func freshInstallWithoutLegacyDataStartsEmpty() async throws {
        let legacy = try await makeLegacy(withData: false)
        let repository = makeRepository(legacy: legacy)

        try await repository.prepare()
        #expect(try await repository.loadProfile() == nil)
        #expect(try await repository.allSessions().isEmpty)
    }
}
