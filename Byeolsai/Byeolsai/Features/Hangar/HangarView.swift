import SwiftUI

struct HangarView: View {
    @Environment(AppContainer.self) private var container

    private let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            StarfieldView(speed: 3)
            ScrollView {
                LazyVGrid(columns: columns, spacing: DS.Spacing.md) {
                    ForEach(container.catalog.ships) { ship in
                        shipCard(ship)
                    }
                }
                .padding(DS.Spacing.md)
            }
        }
    }

    private func shipCard(_ ship: Ship) -> some View {
        let profile = container.progress.profile
        let unlocked = profile?.unlockedShipIDs.contains(ship.id) ?? false
        let isCurrent = profile?.currentShipID == ship.id

        return Button {
            Task { try? await container.progress.selectShip(id: ship.id) }
        } label: {
            VStack(spacing: DS.Spacing.sm) {
                Image(systemName: unlocked ? ship.artAsset : "lock.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(unlocked ? DS.accent : DS.textSecondary)
                    .frame(height: 56)
                Text(ship.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DS.textPrimary)
                if isCurrent {
                    Label("탑승 중", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(DS.success)
                } else if unlocked {
                    Text("탑승하기")
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                } else {
                    Text("누적 \(TimeFormat.korean(seconds: ship.requiredTotalFocusSeconds))")
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.cornerRadius)
                    .fill(DS.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.cornerRadius)
                            .stroke(isCurrent ? DS.accent : .clear, lineWidth: 1.5)
                    )
            )
            .opacity(unlocked ? 1 : 0.6)
        }
        .buttonStyle(.plain)
        .disabled(!unlocked)
    }
}
