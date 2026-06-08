import SwiftUI

@main
struct DamnMacOSWidgetsApp: App {
    @StateObject private var widgetManager = WidgetManager()

    init() {
        NSApplication.shared.setActivationPolicy(.accessory)
    }

    var body: some Scene {
        MenuBarExtra("damn-macos-widgets", systemImage: "square.grid.2x2.fill") {
            MenuBarHubView()
                .environmentObject(widgetManager)
        }
        .menuBarExtraStyle(.window)
    }
}
