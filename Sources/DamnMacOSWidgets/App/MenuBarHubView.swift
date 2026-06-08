import SwiftUI

struct MenuBarHubView: View {
    @EnvironmentObject private var widgetManager: WidgetManager

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            header
            sectionCard {
                systemControls
            }
            sectionCard {
                widgetList
            }
            footer
        }
        .padding(14)
        .frame(width: 340)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.05, green: 0.06, blue: 0.08),
                            Color(red: 0.08, green: 0.09, blue: 0.12)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.10), lineWidth: 1)
                )
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 8) {
                Text("damn-macos-widgets")
                    .font(.system(size: 19, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text("Small, sharp widgets that stay out of the way.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.65))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Text("LOCAL")
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color(red: 0.82, green: 0.90, blue: 1.0))
                .padding(.horizontal, 8)
                .padding(.vertical, 5)
                .background(Color.white.opacity(0.08), in: Capsule())
        }
    }

    private var systemControls: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: launchAtLoginBinding) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Launch at login")
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(widgetManager.launchAtLoginStatusText)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
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
        .foregroundStyle(.white.opacity(0.75))
    }

    private var launchAtLoginBinding: Binding<Bool> {
        Binding(
            get: { widgetManager.appState.launchAtLoginEnabled },
            set: { widgetManager.setLaunchAtLoginEnabled($0) }
        )
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                    )
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
                Circle()
                    .fill(kind.accentColor.opacity(isVisible ? 0.9 : 0.25))
                    .frame(width: 10, height: 10)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(kind.title)
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white)

                        Text(isVisible ? "ON" : "OFF")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(isVisible ? kind.accentColor : .white.opacity(0.55))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background((isVisible ? kind.accentColor : .white).opacity(isVisible ? 0.14 : 0.06), in: Capsule())
                    }
                    Text(kind.subtitle)
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.65))
                }

                Spacer()

                Image(systemName: isVisible ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isVisible ? kind.accentColor : .white.opacity(0.25))
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
