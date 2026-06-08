import SwiftUI

struct WidgetChrome<Content: View>: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var resizeStartSize: CGSize?
    @State private var isHovering = false

    let kind: WidgetKind
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                header
                content()
            }

            resizeHandle
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .liquidGlassBackground(cornerRadius: 20)
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(isHovering ? 0.14 : 0.06),
                            Color.clear
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .blendMode(.screen)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .scaleEffect(isHovering ? 1.006 : 1.0)
        .animation(.snappy(duration: 0.18), value: isHovering)
        .onHover { isHovering = $0 }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Image(systemName: kind.icon)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.secondary)
                .frame(width: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text(kind.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
    }

    private var resizeHandle: some View {
        let size = widgetManager.appState.widgets[kind.rawValue]?.frame.size ?? kind.defaultSize

        return Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .liquidGlassBackground(cornerRadius: 7)
            .scaleEffect(isHovering ? 1.04 : 1.0)
            .opacity(isHovering ? 1 : 0.65)
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
