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

    private let repository: FocusRepository
    private var remoteChangeTask: Task<Void, Never>?

    static func defaultRepository() -> FocusRepository {
        let env = ProcessInfo.processInfo.environment
        let isTestHost = env["XCTestConfigurationFilePath"] != nil
            || env["XCTestSessionIdentifier"] != nil
            || NSClassFromString("XCTestCase") != nil
        return CloudKitRepository(cloudSyncEnabled: !isTestHost, migratingFrom: LocalJSONRepository())
    }

    init(repository: FocusRepository = AppContainer.defaultRepository()) {
        do {
            catalog = try UniverseCatalog.loadBundled()
        } catch {
            fatalError("UniverseContent.json load failed: \(error)")
        }
        self.repository = repository
        let milestones = MilestoneEngine(catalog: catalog)
        progress = ProgressStore(repository: repository, milestones: milestones, snapshotPublisher: WidgetSnapshotPublisher())
        engine = SessionEngine(store: progress, activityPresenter: LiveActivityController())
    }

    func bootstrap() async {
        guard bootState == .loading else { return }
        do {
            try await progress.load()
            bootState = .ready
            observeRemoteChanges()
        } catch {
            bootState = .failed(error.localizedDescription)
        }
    }

    private func observeRemoteChanges() {
        guard remoteChangeTask == nil else { return }
        let changes = repository.remoteChanges
        remoteChangeTask = Task { [weak self] in
            for await _ in changes {
                guard let self, self.engine.activeSession == nil else { continue }
                try? await self.progress.load()
            }
        }
    }
}
