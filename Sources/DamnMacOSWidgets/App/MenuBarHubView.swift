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
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(.white.opacity(0.14), lineWidth: 1)
                )
        }
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
                .background(.thinMaterial, in: Capsule())
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
            .disabled(!widgetManager.hasHiddenWidgets)

            Spacer()

            Button("Hide All") {
                widgetManager.hideAll()
            }
            .disabled(!widgetManager.hasVisibleWidgets)

            Spacer()

            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
        }
        .buttonStyle(.borderless)
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
                            .background(.thinMaterial, in: Capsule())
                    }
                    Text(kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isVisible ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isVisible ? .primary : .secondary)
            }
            .padding(.vertical, 6)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
