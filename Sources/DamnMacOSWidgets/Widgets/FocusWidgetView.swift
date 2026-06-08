import SwiftUI

struct FocusWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        WidgetChrome(kind: .focus) {
            TimelineView(.periodic(from: .now, by: 1)) { context in
                let focus = widgetManager.appState.focus
                let remaining = focus.remainingSeconds(at: context.date)
                let isFinished = remaining <= 0 && !focus.isRunning

                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .firstTextBaseline) {
                        Text(focus.isRunning ? "Deep work" : "Ready")
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("25 min")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Text(isFinished ? "00:00" : focus.formattedRemaining(at: context.date))
                        .font(.system(size: 34, weight: .semibold, design: .rounded))
                        .monospacedDigit()

                    Text(isFinished ? "Session complete." : (focus.isRunning ? "Timer is running." : "Start a focused session."))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 8) {
                        Button(focus.isRunning ? "Pause" : "Start") {
                            if focus.isRunning {
                                widgetManager.pauseFocus()
                            } else {
                                widgetManager.startFocus()
                            }
                        }
                        .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))

                        Button("Reset") {
                            widgetManager.resetFocus()
                        }
                        .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
                        .foregroundStyle(.secondary)

                        Spacer()
                    }
                    .font(.subheadline.weight(.medium))
                }
            }
        }
    }
}
