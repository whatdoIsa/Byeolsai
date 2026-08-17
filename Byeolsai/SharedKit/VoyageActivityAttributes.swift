import ActivityKit
import Foundation

struct VoyageActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var startAt: Date
    }

    var destinationName: String
    var destinationSymbol: String
    var shipSymbol: String
    var travelSeconds: Int

    func arrivalDate(from startAt: Date) -> Date {
        startAt.addingTimeInterval(TimeInterval(travelSeconds))
    }
}
