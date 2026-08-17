import Foundation

protocol FocusRepository {
    func prepare() async throws
    func loadProfile() async throws -> UserProfile?
    func save(profile: UserProfile) async throws
    func save(session: FocusSession) async throws
    func allSessions() async throws -> [FocusSession]
    var remoteChanges: AsyncStream<Void> { get }
}

extension FocusRepository {
    func prepare() async throws {}

    var remoteChanges: AsyncStream<Void> {
        AsyncStream { $0.finish() }
    }
}
