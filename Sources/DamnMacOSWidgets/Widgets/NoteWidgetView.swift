import SwiftUI

struct NoteWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @FocusState private var isFocused: Bool

    var body: some View {
        WidgetChrome(kind: .note) {
            ZStack(alignment: .topLeading) {
                if widgetManager.appState.noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Capture the stray thought.")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.28))
                        .padding(.top, 8)
                        .padding(.leading, 5)
                }

                TextEditor(text: binding)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(.white)
                    .scrollContentBackground(.hidden)
                    .background(.clear)
                    .focused($isFocused)
                    .padding(.horizontal, 2)
            }
            .frame(minHeight: 120)
            .padding(10)
            .background(Color.white.opacity(0.05), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { widgetManager.appState.noteText },
            set: { widgetManager.updateNote($0) }
        )
    }
}
