import SwiftUI

struct LaunchPadView: View {
    @Environment(AppContainer.self) private var container
    @State private var selectedDestinationID: String?
    @State private var mode: SessionMode = .phoneDown

    private var unlockedDestinations: [Destination] {
        guard let profile = container.progress.profile else { return [] }
        return container.catalog.destinations.filter { profile.unlockedRegionIDs.contains($0.regionID) }
    }

    private var selectedDestination: Destination? {
        unlockedDestinations.first { $0.id == selectedDestinationID } ?? unlockedDestinations.first
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            StarfieldView()
            ScrollView {
                VStack(spacing: DS.Spacing.lg) {
                    statsHeader
                    shipSection
                    destinationSection
                    modeSection
                    launchButton
                }
                .padding(DS.Spacing.md)
            }
        }
    }

    private var statsHeader: some View {
        HStack(spacing: DS.Spacing.sm) {
            statCard(title: "오늘", value: TimeFormat.korean(seconds: container.progress.todaySeconds))
            statCard(title: "누적", value: TimeFormat.korean(seconds: container.progress.profile?.totalFocusSeconds ?? 0))
            statCard(title: "스트릭", value: "\(container.progress.profile?.currentStreak ?? 0)일")
        }
    }

    private func statCard(title: String, value: String) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            Text(title)
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DS.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
    }

    private var shipSection: some View {
        VStack(spacing: DS.Spacing.sm) {
            Image(systemName: container.progress.currentShip?.artAsset ?? "paperplane.fill")
                .font(.system(size: 64))
                .foregroundStyle(DS.accent)
                .padding(DS.Spacing.lg)
            Text(container.progress.currentShip?.name ?? "")
                .font(.headline)
                .foregroundStyle(DS.textPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.md)
    }

    private var destinationSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("목적지")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DS.textSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.sm) {
                    ForEach(unlockedDestinations) { destination in
                        destinationCard(destination)
                    }
                }
            }
        }
    }

    private func destinationCard(_ destination: Destination) -> some View {
        let isSelected = destination.id == selectedDestination?.id
        return Button {
            selectedDestinationID = destination.id
        } label: {
            VStack(spacing: DS.Spacing.xs) {
                Image(systemName: destination.artAsset)
                    .font(.title2)
                    .foregroundStyle(isSelected ? DS.accent : DS.textSecondary)
                Text(destination.name)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(DS.textPrimary)
                Text(TimeFormat.korean(seconds: destination.travelSeconds))
                    .font(.caption2)
                    .foregroundStyle(DS.textSecondary)
            }
            .padding(DS.Spacing.md)
            .frame(width: 104)
            .background(
                RoundedRectangle(cornerRadius: DS.cornerRadius)
                    .fill(isSelected ? DS.surfaceElevated : DS.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.cornerRadius)
                            .stroke(isSelected ? DS.accent : .clear, lineWidth: 1.5)
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var modeSection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("세션 모드")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(DS.textSecondary)
            HStack(spacing: DS.Spacing.sm) {
                modeCard(
                    title: "폰다운",
                    subtitle: "폰을 엎어두고 집중",
                    icon: "iphone.gen3",
                    selected: mode == .phoneDown,
                    disabled: false
                ) { mode = .phoneDown }
                modeCard(
                    title: "캠 모드",
                    subtitle: "v0.2에서 열려요",
                    icon: "camera.fill",
                    selected: false,
                    disabled: true
                ) {}
            }
        }
    }

    private func modeCard(title: String, subtitle: String, icon: String, selected: Bool, disabled: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(selected ? DS.accent : DS.textSecondary)
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(DS.textPrimary)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(DS.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(DS.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: DS.cornerRadius)
                    .fill(selected ? DS.surfaceElevated : DS.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: DS.cornerRadius)
                            .stroke(selected ? DS.accent : .clear, lineWidth: 1.5)
                    )
            )
            .opacity(disabled ? 0.45 : 1)
        }
        .buttonStyle(.plain)
        .disabled(disabled)
    }

    private var launchButton: some View {
        Button {
            if let destination = selectedDestination {
                container.engine.start(destination: destination, mode: mode)
            }
        } label: {
            Text("발사")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.md)
                .background(DS.accent, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
        }
        .disabled(selectedDestination == nil)
        .padding(.top, DS.Spacing.sm)
    }
}
