import SwiftUI

struct WidgetChrome<Content: View>: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var resizeStartSize: CGSize?

    let kind: WidgetKind
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 14) {
                header
                content()
            }

            resizeHandle
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.18),
                                    Color.white.opacity(0.03),
                                    Color.black.opacity(0.10)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .blendMode(.screen)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.16), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.20), radius: 20, x: 0, y: 12)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.10))
                    .frame(width: 28, height: 28)
                Image(systemName: kind.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(kind.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(kind.title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.06), in: Capsule())
        }
    }

    private var resizeHandle: some View {
        let size = widgetManager.appState.widgets[kind.rawValue]?.frame.size ?? kind.defaultSize

        return Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.14), lineWidth: 1)
            )
            .padding(8)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if resizeStartSize == nil {
                            resizeStartSize = size
                        }

                        guard let resizeStartSize else { return }

                        widgetManager.resize(
                            kind,
                            to: CGSize(
                                width: resizeStartSize.width + value.translation.width,
                                height: resizeStartSize.height + value.translation.height
                            )
                        )
                    }
                    .onEnded { _ in
                        resizeStartSize = nil
                    }
            )
            .accessibilityLabel("Resize \(kind.title)")
    }
}
