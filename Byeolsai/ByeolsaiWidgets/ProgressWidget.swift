import SwiftUI
import WidgetKit

struct ProgressEntry: TimelineEntry {
    let date: Date
    let snapshot: WidgetSnapshot?

    static let placeholder = ProgressEntry(
        date: .now,
        snapshot: WidgetSnapshot(
            todaySeconds: 5400,
            totalFocusSeconds: 90000,
            currentStreak: 7,
            nextRegionName: "시리우스",
            nextRegionProgress: 0.6,
            updatedAt: .now
        )
    )
}

struct ProgressProvider: TimelineProvider {
    func placeholder(in context: Context) -> ProgressEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (ProgressEntry) -> Void) {
        if context.isPreview {
            completion(.placeholder)
        } else {
            completion(ProgressEntry(date: .now, snapshot: SharedStore.read()))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ProgressEntry>) -> Void) {
        let entry = ProgressEntry(date: .now, snapshot: SharedStore.read())
        let refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now
        completion(Timeline(entries: [entry], policy: .after(refresh)))
    }
}

struct ProgressWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "ByeolsaiProgress", provider: ProgressProvider()) { entry in
            ProgressWidgetView(entry: entry)
                .containerBackground(DS.background, for: .widget)
        }
        .configurationDisplayName("항해 진행")
        .description("오늘 집중, 스트릭, 다음 마일스톤을 확인해요.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct ProgressWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let entry: ProgressEntry

    var body: some View {
        if let snapshot = entry.snapshot {
            switch family {
            case .systemMedium:
                mediumView(snapshot)
            default:
                smallView(snapshot)
            }
        } else {
            emptyView
        }
    }

    private var emptyView: some View {
        VStack(spacing: 6) {
            Image(systemName: "paperplane.fill")
                .foregroundStyle(DS.accent)
            Text("첫 항해를 떠나보세요")
                .font(.caption)
                .foregroundStyle(DS.textSecondary)
        }
    }

    private func smallView(_ snapshot: WidgetSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("오늘", systemImage: "paperplane.fill")
                .font(.caption2)
                .foregroundStyle(DS.textSecondary)
            Text(TimeFormat.korean(seconds: snapshot.todaySeconds))
                .font(.title3.weight(.bold))
                .foregroundStyle(DS.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            Spacer(minLength: 0)
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.caption2)
                    .foregroundStyle(DS.warning)
                Text("\(snapshot.currentStreak)일 연속")
                    .font(.caption)
                    .foregroundStyle(DS.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }

    private func mediumView(_ snapshot: WidgetSnapshot) -> some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("오늘 집중")
                    .font(.caption2)
                    .foregroundStyle(DS.textSecondary)
                Text(TimeFormat.korean(seconds: snapshot.todaySeconds))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(DS.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.caption2)
                        .foregroundStyle(DS.warning)
                    Text("\(snapshot.currentStreak)일 연속")
                        .font(.caption)
                        .foregroundStyle(DS.textSecondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 6) {
                if let nextRegion = snapshot.nextRegionName {
                    Text("다음 목표 · \(nextRegion)")
                        .font(.caption2)
                        .foregroundStyle(DS.textSecondary)
                    ProgressView(value: snapshot.nextRegionProgress)
                        .tint(DS.accent)
                } else {
                    Text("모든 성계 해금 완료")
                        .font(.caption2)
                        .foregroundStyle(DS.textSecondary)
                }
                Text("누적 \(TimeFormat.korean(seconds: snapshot.totalFocusSeconds))")
                    .font(.caption)
                    .foregroundStyle(DS.textPrimary)
                Text(snapshot.updatedAt, style: .time) + Text(" 기준")
            }
            .font(.caption2)
            .foregroundStyle(DS.textSecondary)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
}
