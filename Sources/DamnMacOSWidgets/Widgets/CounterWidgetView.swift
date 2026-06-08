import SwiftUI

struct CounterWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        WidgetChrome(kind: .counter) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Local tally")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Count up or down")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Text("SYNCED")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .liquidGlassBackground(cornerRadius: 999)
                }

                Text("\(widgetManager.appState.counterValue)")
                    .font(.system(size: 42, weight: .semibold, design: .rounded))
                    .monospacedDigit()
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .liquidGlassBackground(cornerRadius: 18)

                HStack(spacing: 8) {
                    Button(action: widgetManager.decrementCounter) {
                        Image(systemName: "minus")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 8))

                    Button("Reset") {
                        widgetManager.resetCounter()
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 12, verticalPadding: 8))
                    .foregroundStyle(.secondary)

                    Button(action: widgetManager.incrementCounter) {
                        Image(systemName: "plus")
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 8))

                    Spacer()
                }
                .font(.subheadline.weight(.medium))
            }
        }
    }
}
