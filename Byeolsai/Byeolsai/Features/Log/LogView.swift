import SwiftUI

struct LogView: View {
    @Environment(AppContainer.self) private var container

    private var groupedByDay: [(day: String, totalSeconds: Int, sessions: [FocusSession])] {
        let sorted = container.progress.sessions.sorted { $0.startAt > $1.startAt }
        var order: [String] = []
        var groups: [String: [FocusSession]] = [:]
        for session in sorted {
            let key = TimeFormat.day(session.startAt)
            if groups[key] == nil { order.append(key) }
            groups[key, default: []].append(session)
        }
        return order.map { key in
            let sessions = groups[key] ?? []
            let total = sessions.filter(\.valid).reduce(0) { $0 + $1.focusSeconds }
            return (key, total, sessions)
        }
    }

    var body: some View {
        ZStack {
            DS.background.ignoresSafeArea()
            if container.progress.sessions.isEmpty {
                emptyState
            } else {
                ScrollView {
                    VStack(spacing: DS.Spacing.lg) {
                        ForEach(groupedByDay, id: \.day) { group in
                            daySection(group)
                        }
                    }
                    .padding(DS.Spacing.md)
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: DS.Spacing.md) {
            Image(systemName: "moon.stars.fill")
                .font(.system(size: 48))
                .foregroundStyle(DS.textSecondary)
            Text("아직 항해 기록이 없어요")
                .font(.subheadline)
                .foregroundStyle(DS.textSecondary)
        }
    }

    private func daySection(_ group: (day: String, totalSeconds: Int, sessions: [FocusSession])) -> some View {
        VStack(alignment: .leading, spacing: DS.Spacing.sm) {
            HStack {
                Text(group.day)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(DS.textPrimary)
                Spacer()
                Text("집중 \(TimeFormat.korean(seconds: group.totalSeconds))")
                    .font(.caption)
                    .foregroundStyle(DS.accent)
            }
            VStack(spacing: DS.Spacing.xs) {
                ForEach(group.sessions) { session in
                    sessionRow(session)
                }
            }
        }
    }

    private func sessionRow(_ session: FocusSession) -> some View {
        let destination = container.catalog.destination(id: session.destinationID)
        return HStack(spacing: DS.Spacing.sm) {
            Image(systemName: destination?.artAsset ?? "circle.fill")
                .foregroundStyle(session.valid ? DS.accent : DS.textSecondary)
            Text(destination?.name ?? "알 수 없는 목적지")
                .font(.subheadline)
                .foregroundStyle(DS.textPrimary)
            Spacer()
            if session.valid {
                Text(TimeFormat.korean(seconds: session.focusSeconds))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(DS.textPrimary)
            } else {
                Text("기록 제외")
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
            }
        }
        .padding(DS.Spacing.md)
        .background(DS.surface, in: RoundedRectangle(cornerRadius: DS.cornerRadius))
        .opacity(session.valid ? 1 : 0.6)
    }
}
