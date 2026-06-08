import SwiftUI

struct NowWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @FocusState private var isFocused: Bool

    var body: some View {
        WidgetChrome(kind: .now) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Right now")
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.secondary)

                TextField("What are you working on?", text: binding, axis: .vertical)
                    .textFieldStyle(.plain)
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                    .lineLimit(2...4)
                    .focused($isFocused)
                    .onAppear { isFocused = true }
                    .background(Color.clear)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .liquidGlassBackground(cornerRadius: 14, tintOpacity: 0.02, strokeOpacity: 0.06)
            }
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { widgetManager.appState.nowText },
            set: { widgetManager.updateNow($0) }
        )
    }
}
