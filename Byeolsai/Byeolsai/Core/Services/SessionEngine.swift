import Foundation
import Observation

struct ActiveSession: Equatable {
    let startAt: Date
    let mode: SessionMode
    let destination: Destination
    let ship: Ship
}

struct SessionSummary: Equatable {
    let session: FocusSession
    let destination: Destination
    let unlocks: UnlockResult
    let arrived: Bool
}

enum SessionPhase: Equatable {
    case idle
    case running(ActiveSession)
    case arrived(SessionSummary)
}

@Observable
final class SessionEngine {
    private(set) var phase: SessionPhase = .idle

    private let store: ProgressStore
    private let integrity: IntegrityGuard

    init(store: ProgressStore, integrity: IntegrityGuard = IntegrityGuard()) {
        self.store = store
        self.integrity = integrity
    }

    var activeSession: ActiveSession? {
        if case .running(let active) = phase { return active }
        return nil
    }

    func start(destination: Destination, mode: SessionMode, now: Date = .now) {
        guard case .idle = phase, let ship = store.currentShip else { return }
        phase = .running(ActiveSession(startAt: now, mode: mode, destination: destination, ship: ship))
    }

    func elapsedSeconds(now: Date = .now) -> Int {
        guard case .running(let active) = phase else { return 0 }
        return max(0, Int(now.timeIntervalSince(active.startAt)))
    }

    func progress(now: Date = .now) -> Double {
        guard case .running(let active) = phase, active.destination.travelSeconds > 0 else { return 0 }
        return min(1, Double(elapsedSeconds(now: now)) / Double(active.destination.travelSeconds))
    }

    func end(now: Date = .now) async {
        guard case .running(let active) = phase else { return }
        let raw = max(0, Int(now.timeIntervalSince(active.startAt)))
        let verdict = integrity.evaluate(rawSeconds: raw, todayAccumulatedSeconds: store.todaySeconds)
        let session = FocusSession(
            id: UUID(),
            startAt: active.startAt,
            endAt: now,
            focusSeconds: verdict.creditedSeconds,
            mode: active.mode,
            destinationID: active.destination.id,
            valid: verdict.isValid,
            hasVideoLog: false
        )
        let unlocks = (try? await store.record(session)) ?? .none
        phase = .arrived(SessionSummary(
            session: session,
            destination: active.destination,
            unlocks: unlocks,
            arrived: raw >= active.destination.travelSeconds
        ))
    }

    func completeIfArrived(now: Date = .now) async {
        guard case .running = phase, progress(now: now) >= 1 else { return }
        await end(now: now)
    }

    func acknowledgeSummary() {
        if case .arrived = phase { phase = .idle }
    }

    func applicationDidEnterBackground() async {
        guard case .running(let active) = phase, active.mode == .cam else { return }
        await end()
    }
}
