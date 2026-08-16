import SwiftUI

struct ArrivalView: View {
    @Environment(AppContainer.self) private var container
    let summary: SessionSummary

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            StarfieldView(speed: 4)
            VStack(spacing: DS.Spacing.lg) {
                Spacer()

                Image(systemName: summary.arrived ? summary.destination.artAsset : "flag.checkered")
                    .font(.system(size: 72))
                    .foregroundStyle(summary.arrived ? DS.accent : DS.textSecondary)

                Text(summary.arrived ? "\(summary.destination.name) 도착!" : "항해 종료")
                    .font(.title2.weight(.bold))
                    .foregroundStyle(DS.textPrimary)

                if summary.session.valid {
                    Text("집중 \(TimeFormat.korean(seconds: summary.session.focusSeconds)) 기록")
                        .font(.headline)
                        .foregroundStyle(DS.success)
                } else {
                    Text("1분 미만 세션은 기록되지 않아요")
                        .font(.subheadline)
                        .foregroundStyle(DS.textSecondary)
                }

                if !summary.unlocks.isEmpty {
                    unlockList
                }

                Spacer()

                Button {
                    container.engine.acknowledgeSummary()
                } label: {
                    Text("확인")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.md)
                        .background(DS.accent, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
                }
                .padding(.horizontal, DS.Spacing.lg)
                .padding(.bottom, DS.Spacing.xl)
            }
        }
    }

    private var unlockList: some View {
        VStack(spacing: DS.Spacing.sm) {
            ForEach(summary.unlocks.newRegions) { region in
                unlockRow(icon: region.artAsset, text: "새 성계 해금 · \(region.name)")
            }
            ForEach(summary.unlocks.newShips) { ship in
                unlockRow(icon: ship.artAsset, text: "새 우주선 해금 · \(ship.name)")
            }
        }
        .padding(.horizontal, DS.Spacing.lg)
    }

    private func unlockRow(icon: String, text: String) -> some View {
        HStack(spacing: DS.Spacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(DS.warning)
            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(DS.textPrimary)
            Spacer()
        }
        .padding(DS.Spacing.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
    }
}
