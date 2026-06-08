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
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.07, blue: 0.10),
                            Color(red: 0.09, green: 0.10, blue: 0.14),
                            kind.accentSoftBackground.opacity(0.6)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(alignment: .topTrailing) {
                    Circle()
                        .fill(kind.accentGlow)
                        .frame(width: 96, height: 96)
                        .blur(radius: 30)
                        .offset(x: 28, y: -18)
                }
                .overlay(alignment: .bottomLeading) {
                    RoundedRectangle(cornerRadius: 999, style: .continuous)
                        .fill(kind.accentColor.opacity(0.18))
                        .frame(width: 78, height: 3)
                        .padding(.leading, 18)
                        .padding(.bottom, 14)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                }
                .shadow(color: .black.opacity(0.28), radius: 22, x: 0, y: 14)
                .shadow(color: kind.accentGlow.opacity(0.18), radius: 12, x: 0, y: 0)
        }
    }

    private var header: some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            ZStack {
                Circle()
                    .fill(kind.accentColor.opacity(0.22))
                    .frame(width: 28, height: 28)
                Image(systemName: kind.icon)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(kind.accentColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(kind.title)
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(kind.subtitle)
                    .font(.caption2)
                    .foregroundStyle(.white.opacity(0.60))
            }

            Spacer()

            Text(kind.title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundStyle(kind.accentColor)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(kind.accentColor.opacity(0.12), in: Capsule())
        }
    }

    private var resizeHandle: some View {
        let size = widgetManager.appState.widgets[kind.rawValue]?.frame.size ?? kind.defaultSize

        return Image(systemName: "arrow.up.left.and.arrow.down.right")
            .font(.system(size: 10, weight: .semibold))
            .foregroundStyle(kind.accentColor.opacity(0.9))
            .frame(width: 22, height: 22)
            .background(Color.white.opacity(0.06), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 7, style: .continuous)
                    .strokeBorder(kind.accentColor.opacity(0.24), lineWidth: 1)
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
