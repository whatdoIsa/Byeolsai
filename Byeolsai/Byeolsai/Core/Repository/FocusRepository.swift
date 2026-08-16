import Foundation

protocol FocusRepository {
    func loadProfile() async throws -> UserProfile?
    func save(profile: UserProfile) async throws
    func save(session: FocusSession) async throws
    func allSessions() async throws -> [FocusSession]
}
