import SwiftUI

struct WidgetChrome<Content: View>: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var resizeStartSize: CGSize?

    let kind: WidgetKind
    @ViewBuilder let content: () -> Content

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: kind.icon)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(kind.title.uppercased())
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .tracking(0.8)
                    Spacer()
                }

                content()
            }

            resizeHandle
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(.white.opacity(0.12), lineWidth: 1)
                }
        }
    }

    private var resizeHandle: some View {
        let size = widgetManager.appState.widgets[kind.rawValue]?.frame.size ?? kind.defaultSize

        return Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(.white.opacity(0.12), lineWidth: 1)
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
