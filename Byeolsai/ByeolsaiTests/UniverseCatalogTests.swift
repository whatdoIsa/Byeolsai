import Foundation
import Testing
@testable import Byeolsai

struct UniverseCatalogTests {
    @Test func bundledCatalogLoads() throws {
        let catalog = try UniverseCatalog.loadBundled()
        #expect(!catalog.regions.isEmpty)
        #expect(!catalog.destinations.isEmpty)
        #expect(!catalog.ships.isEmpty)
    }

    @Test func startingContentIsAvailableAtZeroSeconds() throws {
        let catalog = try UniverseCatalog.loadBundled()
        #expect(catalog.regions.contains { $0.requiredTotalFocusSeconds == 0 })
        #expect(catalog.ships.contains { $0.requiredTotalFocusSeconds == 0 })
    }

    @Test func everyDestinationBelongsToAKnownRegion() throws {
        let catalog = try UniverseCatalog.loadBundled()
        let regionIDs = Set(catalog.regions.map(\.id))
        for destination in catalog.destinations {
            #expect(regionIDs.contains(destination.regionID))
        }
    }

    @Test func idsAreUnique() throws {
        let catalog = try UniverseCatalog.loadBundled()
        #expect(Set(catalog.regions.map(\.id)).count == catalog.regions.count)
        #expect(Set(catalog.destinations.map(\.id)).count == catalog.destinations.count)
        #expect(Set(catalog.ships.map(\.id)).count == catalog.ships.count)
    }

    @Test func everyUnlockedRegionHasAtLeastOneDestination() throws {
        let catalog = try UniverseCatalog.loadBundled()
        for region in catalog.regions {
            #expect(!catalog.destinations(in: region.id).isEmpty)
        }
    }
}
