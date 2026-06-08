import SwiftUI

struct MenuBarHubView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider()
            systemControls
            Divider()
            widgetList
            Divider()
            footer
        }
        .frame(width: 280)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("damn-macos-widgets")
                .font(.headline)
            Text("Tiny widgets for people who hate opening apps.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(16)
    }

    private var systemControls: some View {
        VStack(alignment: .leading, spacing: 8) {
            Toggle(isOn: launchAtLoginBinding) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at login")
                        .font(.subheadline)
                    Text(widgetManager.launchAtLoginStatusText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .toggleStyle(.switch)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
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
                    Divider().padding(.leading, 16)
                }
            }
        }
        .padding(.vertical, 4)
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
        .buttonStyle(.plain)
        .font(.caption)
        .foregroundStyle(.secondary)
        .padding(12)
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { widgetManager.appState.launchAtLoginEnabled },
            set: { widgetManager.setLaunchAtLoginEnabled($0) }
        )
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
                Image(systemName: kind.icon)
                    .frame(width: 20)
                    .foregroundStyle(isAvailable ? .primary : .tertiary)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(kind.title)
                            .font(.body)
                        if !isAvailable {
                            Text("Soon")
                                .font(.caption2.weight(.medium))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.quaternary, in: Capsule())
                        }
                    }
                    Text(kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: isVisible ? "eye.fill" : "eye.slash")
                    .foregroundStyle(isVisible ? Color.green : Color.secondary.opacity(0.5))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!isAvailable)
    }
}
