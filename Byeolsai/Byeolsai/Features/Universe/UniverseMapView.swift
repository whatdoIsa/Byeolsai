import SwiftUI

struct UniverseMapView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            StarfieldView(speed: 3)
            ScrollView {
                VStack(spacing: DS.Spacing.md) {
                    if let next = container.progress.nextMilestone {
                        nextMilestoneCard(next)
                    }
                    ForEach(container.catalog.regions) { region in
                        regionCard(region)
                    }
                }
                .padding(DS.Spacing.md)
            }
        }
    }

    private func nextMilestoneCard(_ next: (region: Region, remainingSeconds: Int)) -> some View {
        let total = next.region.requiredTotalFocusSeconds
        let current = container.progress.profile?.totalFocusSeconds ?? 0
        let ratio = total > 0 ? Double(current) / Double(total) : 0

        return VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            Text("다음 목표")
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
            Text("\(next.region.name)까지 \(TimeFormat.korean(seconds: next.remainingSeconds))")
                .font(.headline)
                .foregroundStyle(DS.textPrimary)
            ProgressView(value: min(1, ratio))
                .tint(DS.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.md)
        .background(DS.surfaceElevated, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
    }

    private func regionCard(_ region: Region) -> some View {
        let unlocked = container.progress.profile?.unlockedRegionIDs.contains(region.id) ?? false
        let destinations = container.catalog.destinations(in: region.id)

        return HStack(spacing: DS.Spacing.md) {
            Image(systemName: unlocked ? region.artAsset : "lock.fill")
                .font(.title2)
                .foregroundStyle(unlocked ? DS.accent : DS.textSecondary)
                .frame(width: 44, height: 44)
                .background(DS.surfaceElevated, in: Circle())
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(region.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DS.textPrimary)
                if unlocked {
                    Text("목적지 \(destinations.count)곳")
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                } else {
                    Text("누적 \(TimeFormat.korean(seconds: region.requiredTotalFocusSeconds)) 달성 시 해금")
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
            }
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
        .opacity(unlocked ? 1 : 0.6)
    }
}
