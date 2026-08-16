import Foundation

struct Region: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let requiredTotalFocusSeconds: Int
    let artAsset: String
}

struct Destination: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let regionID: String
    let travelSeconds: Int
    let artAsset: String
}

struct Ship: Codable, Identifiable, Equatable, Sendable {
    let id: String
    let name: String
    let requiredTotalFocusSeconds: Int
    let artAsset: String
}

struct UniverseCatalog: Codable, Equatable, Sendable {
    let regions: [Region]
    let destinations: [Destination]
    let ships: [Ship]

    enum CatalogError: Error {
        case missingResource
    }

    static func loadBundled(bundle: Bundle = .main) throws -> UniverseCatalog {
        guard let url = bundle.url(forResource: "UniverseContent", withExtension: "json") else {
            throw CatalogError.missingResource
        }
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(UniverseCatalog.self, from: data)
    }

    func region(id: String) -> Region? {
        regions.first { $0.id == id }
    }

    func destination(id: String) -> Destination? {
        destinations.first { $0.id == id }
    }

    func ship(id: String) -> Ship? {
        ships.first { $0.id == id }
    }

    func destinations(in regionID: String) -> [Destination] {
        destinations.filter { $0.regionID == regionID }
    }
}
