import AppKit
import SwiftUI

struct BookmarkWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    private var titleBinding: Binding<String> {
        Binding(
            get: { widgetManager.appState.bookmarkTitle },
            set: { widgetManager.updateBookmarkTitle($0) }
        )
    }

    private var urlBinding: Binding<String> {
        Binding(
            get: { widgetManager.appState.bookmarkURL },
            set: { widgetManager.updateBookmarkURL($0) }
        )
    }

    private var resolvedURL: URL? {
        let raw = widgetManager.appState.bookmarkURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !raw.isEmpty else { return nil }

        if let url = URL(string: raw), url.scheme != nil {
            return url
        }

        return URL(string: "https://\(raw)")
    }

    var body: some View {
        WidgetChrome(kind: .bookmark) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Saved link")
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(resolvedURL?.host ?? "Store one local shortcut")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    Button("Open") {
                        if let resolvedURL {
                            NSWorkspace.shared.open(resolvedURL)
                        }
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                    .disabled(resolvedURL == nil)
                }

                VStack(alignment: .leading, spacing: 8) {
                    TextField("Title", text: titleBinding)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .liquidGlassBackground(cornerRadius: 12)

                    TextField("https://example.com", text: urlBinding)
                        .textFieldStyle(.plain)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundStyle(.primary)
                        .background(Color.clear)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 12)
                        .liquidGlassBackground(cornerRadius: 12)
                }

                HStack {
                    Button("Copy URL") {
                        copyResolvedURL()
                    }
                    .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                    .disabled(resolvedURL == nil)

                    Spacer()
                }
            }
        }
    }

    private func copyResolvedURL() {
        guard let resolvedURL else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resolvedURL.absoluteString, forType: .string)
    }
}
