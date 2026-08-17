import Foundation
import WidgetKit

final class WidgetSnapshotPublisher: SnapshotPublishing {
    func publish(_ snapshot: WidgetSnapshot) {
        SharedStore.write(snapshot)
        WidgetCenter.shared.reloadAllTimelines()
    }
}
