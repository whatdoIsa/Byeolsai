import ActivityKit
import SwiftUI
import WidgetKit

struct VoyageLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: VoyageActivityAttributes.self) { context in
            LockScreenVoyageView(context: context)
                .activityBackgroundTint(DS.background)
                .activitySystemActionForegroundColor(DS.textPrimary)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: context.attributes.shipSymbol)
                        .font(.title2)
                        .foregroundStyle(DS.accent)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.startAt, style: .timer)
                        .font(.title3.weight(.semibold))
                        .monospacedDigit()
                        .multilineTextAlignment(.trailing)
                        .frame(width: 72)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(spacing: 6) {
                        Text("\(context.attributes.destinationName)(으)로 항해 중")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        ProgressView(
                            timerInterval: context.state.startAt...context.attributes.arrivalDate(from: context.state.startAt),
                            countsDown: false,
                            label: { EmptyView() },
                            currentValueLabel: { EmptyView() }
                        )
                        .tint(DS.accent)
                    }
                }
            } compactLeading: {
                Image(systemName: context.attributes.shipSymbol)
                    .foregroundStyle(DS.accent)
            } compactTrailing: {
                Text(context.state.startAt, style: .timer)
                    .monospacedDigit()
                    .frame(maxWidth: 52)
                    .multilineTextAlignment(.trailing)
            } minimal: {
                Image(systemName: context.attributes.shipSymbol)
                    .foregroundStyle(DS.accent)
            }
        }
    }
}

private struct LockScreenVoyageView: View {
    let context: ActivityViewContext<VoyageActivityAttributes>

    var body: some View {
        VStack(spacing: DS.Spacing.sm) {
            HStack {
                Label {
                    Text("\(context.attributes.destinationName)(으)로 항해 중")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(DS.textPrimary)
                } icon: {
                    Image(systemName: context.attributes.shipSymbol)
                        .foregroundStyle(DS.accent)
                }
                Spacer()
                Text(context.state.startAt, style: .timer)
                    .font(.headline)
                    .monospacedDigit()
                    .foregroundStyle(DS.textPrimary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 80)
            }
            HStack(spacing: DS.Spacing.sm) {
                ProgressView(
                    timerInterval: context.state.startAt...context.attributes.arrivalDate(from: context.state.startAt),
                    countsDown: false,
                    label: { EmptyView() },
                    currentValueLabel: { EmptyView() }
                )
                .tint(DS.accent)
                Image(systemName: context.attributes.destinationSymbol)
                    .font(.footnote)
                    .foregroundStyle(DS.textSecondary)
            }
        }
        .padding(DS.Spacing.md)
    }
}
