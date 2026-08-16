import Foundation

final class LocalJSONRepository: FocusRepository {
    private let directory: URL
    private var cachedSessions: [FocusSession]?

    private var profileURL: URL { directory.appendingPathComponent("profile.json") }
    private var sessionsURL: URL { directory.appendingPathComponent("sessions.json") }

    init(directory: URL? = nil) {
        if let directory {
            self.directory = directory
        } else {
            let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            self.directory = support.appendingPathComponent("Byeolsai", isDirectory: true)
        }
        try? FileManager.default.createDirectory(at: self.directory, withIntermediateDirectories: true)
    }

    func loadProfile() async throws -> UserProfile? {
        guard FileManager.default.fileExists(atPath: profileURL.path) else { return nil }
        let data = try Data(contentsOf: profileURL)
        return try decoder.decode(UserProfile.self, from: data)
    }

    func save(profile: UserProfile) async throws {
        let data = try encoder.encode(profile)
        try data.write(to: profileURL, options: .atomic)
    }

    func save(session: FocusSession) async throws {
        var sessions = try await allSessions()
        sessions.append(session)
        cachedSessions = sessions
        let data = try encoder.encode(sessions)
        try data.write(to: sessionsURL, options: .atomic)
    }

    func allSessions() async throws -> [FocusSession] {
        if let cachedSessions { return cachedSessions }
        guard FileManager.default.fileExists(atPath: sessionsURL.path) else {
            cachedSessions = []
            return []
        }
        let data = try Data(contentsOf: sessionsURL)
        let sessions = try decoder.decode([FocusSession].self, from: data)
        cachedSessions = sessions
        return sessions
    }

    private var encoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }

    private var decoder: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
