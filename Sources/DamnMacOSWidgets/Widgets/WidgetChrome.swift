import AppKit
import SwiftUI

struct WidgetChrome<Content: View>: View {
    @EnvironmentObject private var widgetManager: WidgetManager
    @State private var resizeStartSize: CGSize?
    @State private var moveStartOrigin: CGPoint?
    @State private var hostingWindow: NSWindow?
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
        .background(WindowAccessor { window in
            hostingWindow = window
        })
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

            moveHandle
            sizeControls
        }
    }

    private var moveHandle: some View {
        Image(systemName: "line.3.horizontal")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(.secondary)
            .frame(width: 22, height: 22)
            .liquidGlassBackground(cornerRadius: 7)
            .opacity(isHovering ? 1 : 0.75)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard let hostingWindow else { return }
                        if moveStartOrigin == nil {
                            moveStartOrigin = hostingWindow.frame.origin
                        }

                        guard let moveStartOrigin else { return }

                        hostingWindow.setFrameOrigin(
                            CGPoint(
                                x: moveStartOrigin.x + value.translation.width,
                                y: moveStartOrigin.y - value.translation.height
                            )
                        )
                    }
                    .onEnded { _ in
                        moveStartOrigin = nil
                    }
            )
            .accessibilityLabel("Move \(kind.title)")
    }

    private var sizeControls: some View {
        HStack(spacing: 6) {
            Button {
                resizeBy(widthDelta: -36, heightDelta: -24)
            } label: {
                Image(systemName: "minus")
                    .font(.system(size: 9, weight: .semibold))
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 7, horizontalPadding: 0, verticalPadding: 0))
            .accessibilityLabel("Make \(kind.title) smaller")

            Button {
                resizeBy(widthDelta: 36, heightDelta: 24)
            } label: {
                Image(systemName: "plus")
                    .font(.system(size: 9, weight: .semibold))
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 7, horizontalPadding: 0, verticalPadding: 0))
            .accessibilityLabel("Make \(kind.title) larger")
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

    private func resizeBy(widthDelta: CGFloat, heightDelta: CGFloat) {
        let size = widgetManager.appState.widgets[kind.rawValue]?.frame.size ?? kind.defaultSize
        widgetManager.resize(
            kind,
            to: CGSize(
                width: size.width + widthDelta,
                height: size.height + heightDelta
            )
        )
    }
}

private struct WindowAccessor: NSViewRepresentable {
    let onResolve: (NSWindow?) -> Void

    func makeNSView(context: Context) -> ResolverView {
        let view = ResolverView()
        view.onResolve = onResolve
        return view
    }

    func updateNSView(_ nsView: ResolverView, context: Context) {
        nsView.onResolve = onResolve
    }

    final class ResolverView: NSView {
        var onResolve: ((NSWindow?) -> Void)?

        override func viewDidMoveToWindow() {
            super.viewDidMoveToWindow()
            onResolve?(window)
        }
    }
}
