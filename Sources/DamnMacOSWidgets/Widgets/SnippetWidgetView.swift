import AppKit
import SwiftUI

struct SnippetWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @FocusState private var isFocused: Bool

    private var snippetText: String {
        widgetManager.appState.snippetText
    }

    var body: some View {
        WidgetChrome(kind: .snippet) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reusable line")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text("Keep a command, URL, or note fragment nearby.")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("Copy") {
                        copySnippet()
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .disabled(snippetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                ZStack(alignment: .topLeading) {
                    if snippetText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        Text("Paste a reusable line here.")
                            .font(.system(size: 14, weight: .medium, design: .monospaced))
                            .foregroundStyle(.secondary)
                            .padding(.top, 12)
                            .padding(.leading, 10)
                    }

                    TextEditor(text: binding)
                        .font(.system(size: 14, weight: .medium, design: .monospaced))
                        .foregroundStyle(.primary)
                        .scrollContentBackground(.hidden)
                        .background(.clear)
                        .focused($isFocused)
                        .padding(.horizontal, 2)
                }
                .frame(minHeight: 120)
                .padding(10)
                .liquidGlassBackground(cornerRadius: 16)

                HStack {
                    Button("Clear") {
                        widgetManager.updateSnippet("")
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .disabled(snippetText.isEmpty)

                    Spacer()
                }
            }
        }
    }

    private var binding: Binding<String> {
        Binding(
            get: { widgetManager.appState.snippetText },
            set: { widgetManager.updateSnippet($0) }
        )
    }

    private func copySnippet() {
        let trimmed = snippetText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(trimmed, forType: .string)
    }
}
