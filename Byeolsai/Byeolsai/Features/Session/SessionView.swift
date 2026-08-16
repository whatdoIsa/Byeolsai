import SwiftUI

struct SessionView: View {
    @Environment(AppContainer.self) private var container

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            StarfieldView(speed: 30)
            if let active = container.engine.activeSession {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    content(active: active, now: context.date)
                }
            }
        }
        .task {
            while container.engine.activeSession != nil {
                await container.engine.completeIfArrived()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }

    private func content(active: ActiveSession, now: Date) -> some View {
        let elapsed = container.engine.elapsedSeconds(now: now)
        let progress = container.engine.progress(now: now)
        let remaining = max(0, active.destination.travelSeconds - elapsed)

        return VStack(spacing: DS.Spacing.xl) {
            Spacer()

            VStack(spacing: DS.Spacing.sm) {
                Text("\(active.destination.name)(으)로 항해 중")
                    .font(.subheadline)
                    .foregroundStyle(DS.textSecondary)
                Text(TimeFormat.clock(seconds: elapsed))
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(DS.textPrimary)
                Text("도착까지 \(TimeFormat.korean(seconds: remaining))")
                    .font(.footnote)
                    .foregroundStyle(DS.textSecondary)
            }

            voyageTrack(active: active, progress: progress)

            Spacer()

            Button {
                Task { await container.engine.end() }
            } label: {
                Text("항해 종료")
                    .font(.headline)
                    .foregroundStyle(DS.textPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DS.Spacing.md)
                    .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
            }
            .padding(.horizontal, DS.Spacing.lg)
            .padding(.bottom, DS.Spacing.xl)
        }
    }

    private func voyageTrack(active: ActiveSession, progress: Double) -> some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(DS.surface)
                    .frame(height: 4)
                Capsule()
                    .fill(DS.accent)
                    .frame(width: max(0, width * progress), height: 4)
                Image(systemName: active.destination.artAsset)
                    .font(.title3)
                    .foregroundStyle(DS.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                Image(systemName: active.ship.artAsset)
                    .font(.title2)
                    .foregroundStyle(DS.accent)
                    .rotationEffect(.degrees(90))
                    .offset(x: max(0, (width - 28) * progress))
            }
            .frame(maxHeight: .infinity)
        }
        .frame(height: 44)
        .padding(.horizontal, DS.Spacing.lg)
    }
}
