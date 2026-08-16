import SwiftUI

@main
struct ByeolsaiApp: App {
    @State private var container = AppContainer()
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(container)
                .task { await container.bootstrap() }
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        Task { await container.engine.applicationDidEnterBackground() }
                    }
                }
        }
    }
}
