import SwiftUI

struct NoteWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @FocusState private var isFocused: Bool

    var body: some View {
        WidgetChrome(kind: .note) {
            TextEditor(text: binding)
                .font(.body)
                .scrollContentBackground(.hidden)
                .background(.clear)
                .focused($isFocused)
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { widgetManager.appState.noteText },
            set: { widgetManager.updateNote($0) }
        )
    }
}
