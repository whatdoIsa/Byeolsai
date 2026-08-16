import ActivityKit
import Foundation

final class LiveActivityController: SessionActivityPresenting {
    private var activity: Activity<VoyageActivityAttributes>?

    func sessionDidStart(_ session: ActiveSession) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        let attributes = VoyageActivityAttributes(
            destinationName: session.destination.name,
            destinationSymbol: session.destination.artAsset,
            shipSymbol: session.ship.artAsset,
            travelSeconds: session.destination.travelSeconds
        )
        let content = ActivityContent(
            state: VoyageActivityAttributes.ContentState(startAt: session.startAt),
            staleDate: nil
        )
        activity = try? Activity.request(attributes: attributes, content: content)
    }

    func sessionDidEnd() {
        guard let current = activity else { return }
        activity = nil
        Task {
            await current.end(nil, dismissalPolicy: .immediate)
        }
    }
}
