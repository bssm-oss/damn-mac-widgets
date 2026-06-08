import SwiftUI

struct NowWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @FocusState private var isFocused: Bool

    var body: some View {
        WidgetChrome(kind: .now) {
            TextField("What are you working on?", text: binding, axis: .vertical)
                .textFieldStyle(.plain)
                .font(.title3.weight(.medium))
                .lineLimit(2...4)
                .focused($isFocused)
                .onAppear { isFocused = true }
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { widgetManager.appState.nowText },
            set: { widgetManager.updateNow($0) }
        )
    }
}
