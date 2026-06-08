import AppKit
import SwiftUI

@MainActor
final class WidgetManager: ObservableObject {
    @Published private(set) var appState: AppState
    @Published private(set) var launchAtLoginStatusText: String = "Disabled"
    @Published private(set) var calendarEvents: [CalendarEventSummary] = []
    @Published private(set) var calendarStatusText: String = "Calendar access not requested"
    @Published private(set) var githubSnapshot: GitHubActivitySnapshot = .empty

    private var panels: [WidgetKind: WidgetPanel] = [:]
    private let store: LocalStore
    private let launchAtLoginService: LaunchAtLoginService
    private let calendarService: CalendarService
    private let githubService: GitHubService
    private var saveTask: Task<Void, Never>?

    private var didBootstrap = false

    init(
        store: LocalStore = LocalStore(),
        autoBootstrap: Bool = true,
        launchAtLoginService: LaunchAtLoginService? = nil,
        calendarService: CalendarService? = nil,
        githubService: GitHubService? = nil
    ) {
        self.store = store
        self.launchAtLoginService = launchAtLoginService ?? LaunchAtLoginService()
        self.calendarService = calendarService ?? CalendarService()
        self.githubService = githubService ?? GitHubService()
        self.appState = store.load()
        seedDefaultsIfNeeded()
        syncLaunchAtLoginPreference()
        refreshLaunchAtLoginStatus()
        calendarStatusText = self.calendarService.authorizationSummary

        if autoBootstrap {
            Task { @MainActor in
                bootstrap()
            }
        }
    }

    func bootstrap() {
        guard !didBootstrap else { return }
        didBootstrap = true
        syncVisiblePanels()
    }

    var hasVisibleWidgets: Bool {
        WidgetKind.allCases.contains { isVisible($0) && $0.isAvailable }
    }

    var hasHiddenWidgets: Bool {
        WidgetKind.allCases.contains { !isVisible($0) && $0.isAvailable }
    }

    func isVisible(_ kind: WidgetKind) -> Bool {
        appState.widgets[kind.rawValue]?.isVisible ?? false
    }

    func toggle(_ kind: WidgetKind) {
        guard kind.isAvailable else { return }
        setVisible(kind, visible: !isVisible(kind))
    }

    func showAll() {
        for kind in WidgetKind.allCases where kind.isAvailable {
            setVisible(kind, visible: true)
        }
    }

    func hideAll() {
        for kind in WidgetKind.allCases where kind.isAvailable {
            setVisible(kind, visible: false)
        }
    }

    func updateNow(_ text: String) {
        var state = appState
        state.nowText = text
        appState = state
        scheduleSave()
    }

    func addTodo(_ title: String) {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        var state = appState
        state.todos.append(TodoItem(title: trimmed))
        appState = state
        scheduleSave()
    }

    func toggleTodo(_ id: UUID) {
        guard let index = appState.todos.firstIndex(where: { $0.id == id }) else { return }
        var state = appState
        state.todos[index].isDone.toggle()
        appState = state
        scheduleSave()
    }

    func removeTodo(_ id: UUID) {
        var state = appState
        state.todos.removeAll { $0.id == id }
        appState = state
        scheduleSave()
    }

    func updateNote(_ text: String) {
        var state = appState
        state.noteText = text
        appState = state
        scheduleSave()
    }

    func incrementCounter() {
        updateCounter(appState.counterValue + 1)
    }

    func decrementCounter() {
        updateCounter(max(0, appState.counterValue - 1))
    }

    func resetCounter() {
        updateCounter(0)
    }

    func updateSnippet(_ text: String) {
        var state = appState
        state.snippetText = text
        appState = state
        scheduleSave()
    }

    func updateBookmarkTitle(_ text: String) {
        var state = appState
        state.bookmarkTitle = text
        appState = state
        scheduleSave()
    }

    func updateBookmarkURL(_ text: String) {
        var state = appState
        state.bookmarkURL = text
        appState = state
        scheduleSave()
    }

    func resize(_ kind: WidgetKind, to size: CGSize) {
        let clampedSize = constrainedSize(size, for: kind)

        var state = widgetState(for: kind)
        state.frame = WidgetFrame(origin: state.frame.origin, size: clampedSize)

        var snapshot = appState
        snapshot.widgets[kind.rawValue] = state
        appState = snapshot
        scheduleSave()

        guard let panel = panels[kind] else { return }
        var frame = panel.frame
        frame.size = clampedSize
        panel.setFrame(frame, display: true)
        panel.reportFrame()
    }

    func startFocus() {
        var state = appState
        state.focus.start()
        appState = state
        scheduleSave()
    }

    func pauseFocus() {
        var state = appState
        state.focus.pause()
        appState = state
        scheduleSave()
    }

    func resetFocus() {
        var state = appState
        state.focus.reset()
        appState = state
        scheduleSave()
    }

    func setLaunchAtLoginEnabled(_ enabled: Bool) {
        var state = appState
        state.launchAtLoginEnabled = enabled
        appState = state
        scheduleSave()

        do {
            if enabled {
                try launchAtLoginService.enable()
            } else {
                try launchAtLoginService.disable()
            }
        } catch {
            // The menu still reflects the user's preference while we keep the
            // current system status visible in the status text.
        }

        refreshLaunchAtLoginStatus()
    }

    func refreshCalendar() {
        Task { @MainActor in
            await loadCalendarEvents()
        }
    }

    func refreshGitHubActivity() {
        Task { @MainActor in
            await loadGitHubActivity()
        }
    }

    private func setVisible(_ kind: WidgetKind, visible: Bool) {
        var state = widgetState(for: kind)
        state.isVisible = visible
        var snapshot = appState
        snapshot.widgets[kind.rawValue] = state
        appState = snapshot
        scheduleSave()

        if visible {
            showPanel(for: kind)
        } else {
            hidePanel(for: kind)
        }
    }

    private func syncVisiblePanels() {
        for kind in WidgetKind.allCases where kind.isAvailable {
            if isVisible(kind) {
                showPanel(for: kind)
            }
        }
    }

    private func showPanel(for kind: WidgetKind) {
        if let panel = panels[kind] {
            panel.orderFrontRegardless()
            refreshContent(for: kind)
            return
        }

        let frame = widgetState(for: kind).frame
        let panel = WidgetPanel(
            kind: kind,
            content: widgetView(for: kind),
            frame: frame
        ) { [weak self] newFrame in
            self?.updateFrame(kind, frame: newFrame)
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didMoveNotification,
            object: panel,
            queue: .main
        ) { [weak panel] _ in
            Task { @MainActor in
                panel?.reportFrame()
            }
        }

        NotificationCenter.default.addObserver(
            forName: NSWindow.didResizeNotification,
            object: panel,
            queue: .main
        ) { [weak panel] _ in
            Task { @MainActor in
                panel?.reportFrame()
            }
        }

        panels[kind] = panel
        panel.orderFrontRegardless()
        refreshContent(for: kind)
    }

    private func hidePanel(for kind: WidgetKind) {
        panels[kind]?.orderOut(nil)
    }

    private func updateFrame(_ kind: WidgetKind, frame: WidgetFrame) {
        var state = widgetState(for: kind)
        state.frame = frame
        var snapshot = appState
        snapshot.widgets[kind.rawValue] = state
        appState = snapshot
        scheduleSave()
    }

    @ViewBuilder
    private func widgetView(for kind: WidgetKind) -> some View {
        Group {
            switch kind {
            case .now:
                NowWidgetView()
            case .todo:
                TodoWidgetView()
            case .note:
                NoteWidgetView()
            case .counter:
                CounterWidgetView()
            case .snippet:
                SnippetWidgetView()
            case .bookmark:
                BookmarkWidgetView()
            case .focus:
                FocusWidgetView()
            case .calendar:
                CalendarWidgetView()
            case .github:
                GitHubWidgetView()
            }
        }
        .environmentObject(self)
    }

    private func widgetState(for kind: WidgetKind) -> WidgetState {
        if let existing = appState.widgets[kind.rawValue] {
            return existing
        }

        let defaultFrame = defaultFrame(for: kind)
        let state = WidgetState(isVisible: false, frame: defaultFrame)
        appState.widgets[kind.rawValue] = state
        return state
    }

    private func defaultFrame(for kind: WidgetKind) -> WidgetFrame {
        let size = kind.defaultSize
        let screen = NSScreen.main?.visibleFrame ?? NSRect(x: 100, y: 100, width: 1200, height: 800)
        let origin = CGPoint(
            x: screen.maxX - size.width - 40 - CGFloat(kind.ordinalOffset * 30),
            y: screen.maxY - size.height - 80 - CGFloat(kind.ordinalOffset * 40)
        )
        return WidgetFrame(origin: origin, size: size)
    }

    private func seedDefaultsIfNeeded() {
        guard appState.widgets.isEmpty else { return }

        for kind in WidgetKind.allCases where kind.isAvailable {
            appState.widgets[kind.rawValue] = WidgetState(
                isVisible: kind == .now,
                frame: defaultFrame(for: kind)
            )
        }
        scheduleSave()
    }

    private func scheduleSave() {
        saveTask?.cancel()
        let snapshot = appState
        saveTask = Task {
            try? await Task.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }
            store.save(snapshot)
        }
    }

    private func refreshContent(for kind: WidgetKind) {
        switch kind {
        case .calendar:
            refreshCalendar()
        case .github:
            refreshGitHubActivity()
        default:
            break
        }
    }

    private func syncLaunchAtLoginPreference() {
        do {
            if appState.launchAtLoginEnabled {
                try launchAtLoginService.enable()
            } else {
                try launchAtLoginService.disable()
            }
        } catch {
            // Keep the local preference; the menu surfaces system status.
        }
    }

    private func refreshLaunchAtLoginStatus() {
        launchAtLoginStatusText = launchAtLoginService.statusDescription
    }

    private func loadCalendarEvents() async {
        calendarStatusText = calendarService.authorizationSummary

        do {
            let events = try await calendarService.fetchUpcomingEvents()
            calendarEvents = events
            calendarStatusText = events.isEmpty ? "No upcoming events found." : calendarService.authorizationSummary
        } catch {
            calendarEvents = []
            calendarStatusText = error.localizedDescription
        }
    }

    private func loadGitHubActivity() async {
        githubSnapshot = await githubService.fetchSnapshot()
    }

    private func constrainedSize(_ size: CGSize, for kind: WidgetKind) -> CGSize {
        let minimum = kind.minimumSize
        return CGSize(
            width: max(minimum.width, size.width),
            height: max(minimum.height, size.height)
        )
    }

    private func updateCounter(_ value: Int) {
        var state = appState
        state.counterValue = value
        appState = state
        scheduleSave()
    }
}

private extension WidgetKind {
    var ordinalOffset: Int {
        WidgetKind.allCases.firstIndex(of: self) ?? 0
    }
}
