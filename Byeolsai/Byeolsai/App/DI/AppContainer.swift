import Foundation
import Observation

@Observable
final class AppContainer {
    enum BootState: Equatable {
        case loading
        case ready
        case failed(String)
    }

    private(set) var bootState: BootState = .loading
    let catalog: UniverseCatalog
    let progress: ProgressStore
    let engine: SessionEngine

    init(repository: FocusRepository = LocalJSONRepository()) {
        do {
            catalog = try UniverseCatalog.loadBundled()
        } catch {
            fatalError("UniverseContent.json load failed: \(error)")
        }
        let milestones = MilestoneEngine(catalog: catalog)
        progress = ProgressStore(repository: repository, milestones: milestones)
        engine = SessionEngine(store: progress, activityPresenter: LiveActivityController())
    }

    func bootstrap() async {
        guard bootState == .loading else { return }
        do {
            try await progress.load()
            bootState = .ready
        } catch {
            bootState = .failed(error.localizedDescription)
        }
    }
}
