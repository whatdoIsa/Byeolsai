import Foundation
import Observation

@Observable
final class ProgressStore {
    private(set) var profile: UserProfile?
    private(set) var sessions: [FocusSession] = []

    private let repository: FocusRepository
    private let milestones: MilestoneEngine
    private let calendar: Calendar
    private let snapshotPublisher: SnapshotPublishing?

    init(repository: FocusRepository, milestones: MilestoneEngine, calendar: Calendar = .current, snapshotPublisher: SnapshotPublishing? = nil) {
        self.repository = repository
        self.milestones = milestones
        self.calendar = calendar
        self.snapshotPublisher = snapshotPublisher
    }

    var todaySeconds: Int {
        focusSeconds(on: .now)
    }

    func focusSeconds(on day: Date) -> Int {
        sessions
            .filter { $0.valid && calendar.isDate($0.startAt, inSameDayAs: day) }
            .reduce(0) { $0 + $1.focusSeconds }
    }

    func load() async throws {
        try await repository.prepare()
        sessions = try await repository.allSessions()
        if let existing = try await repository.loadProfile() {
            profile = existing
        } else {
            var fresh = UserProfile(
                id: UUID(),
                displayName: "",
                createdAt: .now,
                currentShipID: milestones.catalog.ships.first?.id ?? "",
                totalFocusSeconds: 0,
                currentStreak: 0,
                lastFocusDay: nil,
                unlockedRegionIDs: [],
                unlockedShipIDs: []
            )
            _ = milestones.apply(to: &fresh)
            try await repository.save(profile: fresh)
            profile = fresh
        }
        publishSnapshot()
    }

    func record(_ session: FocusSession) async throws -> UnlockResult {
        try await repository.save(session: session)
        sessions.append(session)
        guard session.valid, var updated = profile else { return .none }
        updated.totalFocusSeconds += session.focusSeconds
        updated.currentStreak = Streak.advance(
            current: updated.currentStreak,
            lastFocusDay: updated.lastFocusDay,
            sessionDay: session.endAt,
            calendar: calendar
        )
        updated.lastFocusDay = session.endAt
        let unlocks = milestones.apply(to: &updated)
        try await repository.save(profile: updated)
        profile = updated
        publishSnapshot()
        return unlocks
    }

    func selectShip(id: String) async throws {
        guard var updated = profile, updated.unlockedShipIDs.contains(id) else { return }
        updated.currentShipID = id
        try await repository.save(profile: updated)
        profile = updated
    }

    var currentShip: Ship? {
        profile.flatMap { milestones.catalog.ship(id: $0.currentShipID) }
    }

    var nextMilestone: (region: Region, remainingSeconds: Int)? {
        profile.flatMap { milestones.nextRegionMilestone(totalFocusSeconds: $0.totalFocusSeconds) }
    }

    private func publishSnapshot() {
        guard let profile else { return }
        let next = nextMilestone
        let progress: Double
        if let next, next.region.requiredTotalFocusSeconds > 0 {
            progress = min(1, Double(profile.totalFocusSeconds) / Double(next.region.requiredTotalFocusSeconds))
        } else {
            progress = 1
        }
        snapshotPublisher?.publish(WidgetSnapshot(
            todaySeconds: todaySeconds,
            totalFocusSeconds: profile.totalFocusSeconds,
            currentStreak: profile.currentStreak,
            nextRegionName: next?.region.name,
            nextRegionProgress: progress,
            updatedAt: .now
        ))
    }
}
