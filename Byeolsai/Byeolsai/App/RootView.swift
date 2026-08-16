import SwiftUI

struct RootView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            switch container.bootState {
            case .loading:
                ProgressView()
                    .tint(DS.accent)
            case .failed(let message):
                VStack(spacing: DS.Spacing.md) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(DS.warning)
                    Text("데이터를 불러오지 못했어요")
                        .font(.headline)
                        .foregroundStyle(DS.textPrimary)
                    Text(message)
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
                .padding()
            case .ready:
                MainTabView()
            }
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        ZStack {
            TabView {
                LaunchPadView()
                    .tabItem { Label("발사대", systemImage: "paperplane.fill") }
                UniverseMapView()
                    .tabItem { Label("우주 지도", systemImage: "map.fill") }
                HangarView()
                    .tabItem { Label("격납고", systemImage: "airplane.circle.fill") }
                LogView()
                    .tabItem { Label("로그", systemImage: "list.bullet.rectangle.fill") }
            }
            .tint(DS.accent)

            switch container.engine.phase {
            case .idle:
                EmptyView()
            case .running:
                SessionView()
                    .transition(.opacity)
            case .arrived(let summary):
                ArrivalView(summary: summary)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: container.engine.phase)
    }
}
