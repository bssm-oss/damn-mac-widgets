import Foundation
import SwiftUI

enum WidgetKind: String, CaseIterable, Identifiable, Codable {
    case now
    case todo
    case note
    case focus
    case calendar
    case github

    var id: String { rawValue }

    var title: String {
        switch self {
        case .now: "Now"
        case .todo: "Todo"
        case .note: "Note"
        case .focus: "Focus"
        case .calendar: "Calendar"
        case .github: "GitHub"
        }
    }

    var subtitle: String {
        switch self {
        case .now: "What you're working on"
        case .todo: "Simple task list"
        case .note: "Quick scratch pad"
        case .focus: "Focus timer & state"
        case .calendar: "Upcoming events"
        case .github: "Issues, PRs, activity"
        }
    }

    var icon: String {
        switch self {
        case .now: "scope"
        case .todo: "checklist"
        case .note: "note.text"
        case .focus: "timer"
        case .calendar: "calendar"
        case .github: "chevron.left.forwardslash.chevron.right"
        }
    }

    var defaultSize: CGSize {
        switch self {
        case .now: CGSize(width: 280, height: 120)
        case .todo: CGSize(width: 260, height: 320)
        case .note: CGSize(width: 300, height: 240)
        case .focus: CGSize(width: 220, height: 160)
        case .calendar: CGSize(width: 280, height: 300)
        case .github: CGSize(width: 300, height: 280)
        }
    }

    var minimumSize: CGSize {
        switch self {
        case .now: CGSize(width: 240, height: 110)
        case .todo: CGSize(width: 240, height: 260)
        case .note: CGSize(width: 260, height: 200)
        case .focus: CGSize(width: 220, height: 160)
        case .calendar: CGSize(width: 260, height: 240)
        case .github: CGSize(width: 280, height: 220)
        }
    }

    var isAvailable: Bool {
        true
    }

    var accentColor: Color {
        switch self {
        case .now: Color(red: 0.98, green: 0.60, blue: 0.25)
        case .todo: Color(red: 0.18, green: 0.78, blue: 0.72)
        case .note: Color(red: 0.42, green: 0.73, blue: 0.98)
        case .focus: Color(red: 0.96, green: 0.36, blue: 0.49)
        case .calendar: Color(red: 0.72, green: 0.54, blue: 0.98)
        case .github: Color(red: 0.48, green: 0.90, blue: 0.52)
        }
    }

    var accentGlow: Color {
        accentColor.opacity(0.32)
    }

    var accentSoftBackground: Color {
        accentColor.opacity(0.15)
    }
}

struct WidgetFrame: Codable, Equatable {
    var originX: Double
    var originY: Double
    var width: Double
    var height: Double

    init(origin: CGPoint, size: CGSize) {
        originX = origin.x
        originY = origin.y
        width = size.width
        height = size.height
    }

    var origin: CGPoint {
        CGPoint(x: originX, y: originY)
    }

    var size: CGSize {
        CGSize(width: width, height: height)
    }
}

struct WidgetState: Codable, Equatable {
    var isVisible: Bool
    var frame: WidgetFrame
}

struct AppState: Codable, Equatable {
    var widgets: [String: WidgetState]
    var nowText: String
    var todos: [TodoItem]
    var noteText: String
    var focus: FocusTimerState
    var launchAtLoginEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case widgets
        case nowText
        case todos
        case noteText
        case focus
        case launchAtLoginEnabled
    }

    init(
        widgets: [String: WidgetState],
        nowText: String,
        todos: [TodoItem],
        noteText: String,
        focus: FocusTimerState = .default,
        launchAtLoginEnabled: Bool = false
    ) {
        self.widgets = widgets
        self.nowText = nowText
        self.todos = todos
        self.noteText = noteText
        self.focus = focus
        self.launchAtLoginEnabled = launchAtLoginEnabled
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        widgets = try container.decodeIfPresent([String: WidgetState].self, forKey: .widgets) ?? [:]
        nowText = try container.decodeIfPresent(String.self, forKey: .nowText) ?? ""
        todos = try container.decodeIfPresent([TodoItem].self, forKey: .todos) ?? []
        noteText = try container.decodeIfPresent(String.self, forKey: .noteText) ?? ""
        focus = try container.decodeIfPresent(FocusTimerState.self, forKey: .focus) ?? .default
        launchAtLoginEnabled = try container.decodeIfPresent(Bool.self, forKey: .launchAtLoginEnabled) ?? false
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(widgets, forKey: .widgets)
        try container.encode(nowText, forKey: .nowText)
        try container.encode(todos, forKey: .todos)
        try container.encode(noteText, forKey: .noteText)
        try container.encode(focus, forKey: .focus)
        try container.encode(launchAtLoginEnabled, forKey: .launchAtLoginEnabled)
    }

    static let empty = AppState(
        widgets: [:],
        nowText: "",
        todos: [],
        noteText: "",
        focus: .default,
        launchAtLoginEnabled: false
    )
}

struct TodoItem: Identifiable, Codable, Equatable {
    var id: UUID
    var title: String
    var isDone: Bool

    init(id: UUID = UUID(), title: String, isDone: Bool = false) {
        self.id = id
        self.title = title
        self.isDone = isDone
    }
}

struct FocusTimerState: Codable, Equatable {
    var durationSeconds: TimeInterval
    var remainingSeconds: TimeInterval
    var isRunning: Bool
    var startedAt: Date?

    static let `default` = FocusTimerState(
        durationSeconds: 25 * 60,
        remainingSeconds: 25 * 60,
        isRunning: false,
        startedAt: nil
    )

    func remainingSeconds(at date: Date = .now) -> TimeInterval {
        guard isRunning, let startedAt else { return remainingSeconds }
        return max(0, remainingSeconds - date.timeIntervalSince(startedAt))
    }

    func formattedRemaining(at date: Date = .now) -> String {
        let totalSeconds = Int(remainingSeconds(at: date).rounded(.down))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    mutating func start(now: Date = .now) {
        if isRunning {
            return
        }

        if remainingSeconds <= 0 {
            remainingSeconds = durationSeconds
        }

        startedAt = now
        isRunning = true
    }

    mutating func pause(now: Date = .now) {
        guard isRunning else { return }
        remainingSeconds = remainingSeconds(at: now)
        startedAt = nil
        isRunning = false
    }

    mutating func reset() {
        remainingSeconds = durationSeconds
        startedAt = nil
        isRunning = false
    }
}
