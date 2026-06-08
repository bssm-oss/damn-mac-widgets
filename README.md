# damn-macos-widgets

Tiny macOS widgets for people who hate opening apps.

A collection of small, glanceable desktop widgets for macOS. No login, no cloud — just lightweight utilities pinned to your empty desktop space. A menu bar app manages everything.

## Philosophy

- **Glanceable** — see what matters without opening an app
- **Local-first** — your data stays on your Mac
- **Lightweight** — small footprint, fast launch, no bloat
- **Beautiful** — native SwiftUI, subtle vibrancy, intentional typography

## Widgets

| Widget | Status | Description |
|--------|--------|-------------|
| **Now** | ✅ | What you're working on right now |
| **Todo** | ✅ | Simple task list |
| **Note** | ✅ | Quick scratch pad |
| **Focus** | ✅ | Focus state & timer |
| **Calendar** | ✅ | Upcoming events at a glance |
| **GitHub** | ✅ | Issues, PRs, contributions |

## Requirements

- macOS 14 Sonoma or later
- Xcode 15+ (or Swift 5.9+ toolchain)

## Development

Open in Xcode:

```bash
open Package.swift
```

Build and run from Xcode, or:

```bash
swift build
.build/debug/DamnMacOSWidgets
```

The app lives in the menu bar. Toggle widgets from the menu bar panel.
Launch at login is available from the same menu.

Run the test suite with:

```bash
swift test
```

Build a signed `.app` bundle with:

```bash
scripts/package-app
```

Set `CODE_SIGN_IDENTITY` if you want to sign with an actual identity instead of ad hoc signing.

## Architecture

```
Sources/DamnMacOSWidgets/
├── App/           # Entry point, menu bar hub
├── Core/          # Widget manager, floating panels, models
├── Widgets/       # Individual widget views
└── Storage/       # Local persistence (JSON in Application Support)
```

Each widget is a floating `NSPanel` on the desktop — not a Notification Center widget, not a Dock app window. The menu bar app is the control hub; widgets appear where you put them.

Focus, Calendar, and GitHub are implemented as separate panels:

- **Focus** keeps a simple Pomodoro-style timer in the widget itself.
- **Calendar** requests EventKit access and shows upcoming events.
- **GitHub** reads unread notifications through the `gh` CLI when it is available and authenticated.

## License

MIT
