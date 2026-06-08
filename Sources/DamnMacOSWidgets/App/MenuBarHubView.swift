import SwiftUI

struct MenuBarHubView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            sectionCard { systemControls }
            sectionCard { widgetList }
            footer
        }
        .padding(14)
        .frame(width: 340)
        .liquidGlassBackground(cornerRadius: 24)
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("damn-macos-widgets")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.primary)
                Text("Small, sharp widgets that stay out of the way.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text("LOCAL")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .liquidGlassBackground(cornerRadius: 999)
        }
    }

    private var systemControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: launchAtLoginBinding) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at login")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.primary)
                    Text(widgetManager.launchAtLoginStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        }
    }

    private var widgetList: some View {
        VStack(spacing: 0) {
            ForEach(WidgetKind.allCases) { kind in
                WidgetToggleRow(
                    kind: kind,
                    isVisible: widgetManager.isVisible(kind),
                    isAvailable: kind.isAvailable
                ) {
                    widgetManager.toggle(kind)
                }
                if kind != WidgetKind.allCases.last {
                    Divider()
                        .overlay(Color.white.opacity(0.08))
                }
            }
        }
    }

    private var footer: some View {
        HStack {
            Button("Show All") {
                widgetManager.showAll()
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
            .disabled(!widgetManager.hasHiddenWidgets)

            Spacer()

            Button("Hide All") {
                widgetManager.hideAll()
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
            .disabled(!widgetManager.hasVisibleWidgets)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(GlassActionButtonStyle(cornerRadius: 10, horizontalPadding: 10, verticalPadding: 5))
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(.primary)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { widgetManager.appState.launchAtLoginEnabled },
            set: { widgetManager.setLaunchAtLoginEnabled($0) }
        )
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(10)
    }
}

private struct WidgetToggleRow: View {
    let kind: WidgetKind
    let isVisible: Bool
    let isAvailable: Bool
    let onToggle: () -> Void
    @State private var isHovering = false

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(kind.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.primary)

                        Text(isVisible ? "ON" : "OFF")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .liquidGlassBackground(cornerRadius: 999)
                    }
                    Text(kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isVisible ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isVisible ? .primary : .secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 10)
            .background {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.white.opacity(isHovering ? 0.08 : 0.03))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(isHovering ? 0.12 : 0.05), lineWidth: 0.8)
            }
            .scaleEffect(isHovering ? 1.01 : 1.0)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { isHovering = $0 }
        .animation(.snappy(duration: 0.18), value: isHovering)
    }
}
