import AppKit
import SwiftUI

struct GitHubWidgetView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        WidgetChrome(kind: .github) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(widgetManager.githubSnapshot.statusMessage)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)

                        if let username = widgetManager.githubSnapshot.username {
                            Text("@\(username)")
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    Button("Refresh") {
                        widgetManager.refreshGitHubActivity()
                    }
                    .buttonStyle(.borderless)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.primary)
                }

                if widgetManager.githubSnapshot.items.isEmpty {
                    Text("No unread GitHub notifications.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(widgetManager.githubSnapshot.items) { item in
                                GitHubActivityRow(item: item)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(maxHeight: .infinity)
                }

                Button("Open GitHub") {
                    if let url = URL(string: "https://github.com") {
                        NSWorkspace.shared.open(url)
                    }
                }
                .buttonStyle(.borderless)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
            }
        }
    }
}

private struct GitHubActivityRow: View {
    let item: GitHubActivityItem

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                Spacer(minLength: 8)

                Text(item.updatedAtText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 6) {
                Text(item.repositoryName)
                Text("•")
                Text(item.reason)
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 10)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}
