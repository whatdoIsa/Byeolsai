import Foundation

struct WidgetSnapshot: Codable, Equatable {
    var todaySeconds: Int
    var totalFocusSeconds: Int
    var currentStreak: Int
    var nextRegionName: String?
    var nextRegionProgress: Double
    var updatedAt: Date
}

enum SharedStore {
    static let appGroupID = "group.kr.arcseed.byeolsai"

    static var defaultSnapshotURL: URL? {
        FileManager.default
            .containerURL(forSecurityApplicationGroupIdentifier: appGroupID)?
            .appendingPathComponent("widget-snapshot.json")
    }

    static func write(_ snapshot: WidgetSnapshot, to url: URL? = defaultSnapshotURL) {
        guard let url else { return }
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        try? data.write(to: url, options: .atomic)
    }

    static func read(from url: URL? = defaultSnapshotURL) -> WidgetSnapshot? {
        guard let url, let data = try? Data(contentsOf: url) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(WidgetSnapshot.self, from: data)
    }
}
