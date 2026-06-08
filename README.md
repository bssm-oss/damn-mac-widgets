# damn-macos-widgets

Tiny macOS widgets for people who hate opening apps.

A collection of small, glanceable desktop widgets for macOS. No login, no cloud — just lightweight utilities pinned to your empty desktop space. A menu bar app manages everything.

## Philosophy

- **Glanceable** — see what matters without opening an app
- **Local-first** — your data stays on your Mac
- **Lightweight** — small footprint, fast launch, no bloat
- **Beautiful** — native SwiftUI, Liquid Glass, intentional typography

## Widgets

| Widget | Status | Description |
|--------|--------|-------------|
| **Now** | ✅ | What you're working on right now |
| **Todo** | ✅ | Simple task list |
| **Note** | ✅ | Quick scratch pad |
| **Counter** | ✅ | Local tally with increment/decrement |
| **Snippet** | ✅ | Reusable line or command snippet |
| **Bookmark** | ✅ | Saved local link with open/copy |
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

Build a release zip and optionally notarize it with:

```bash
scripts/release-app
```

Set `NOTARYTOOL_PROFILE` or `APPLE_ID` / `APPLE_ID_PASSWORD` / `APPLE_TEAM_ID` to enable notarization.

## Architecture

```
Sources/DamnMacOSWidgets/
├── App/           # Entry point, menu bar hub
├── Core/          # Widget manager, desktop-attached panels, models
├── Widgets/       # Individual widget views
└── Storage/       # Local persistence (JSON in Application Support)
```

Each widget is a desktop-attached `NSPanel` that sits on the wallpaper — not a Notification Center widget, not a floating tool palette, not a Dock app window. The menu bar app is the control hub; widgets stay on the desktop layer. Use the move handle to reposition a widget and the `- / +` controls to make it smaller or larger.

Counter, Snippet, and Bookmark are pure local-state widgets:

- **Counter** keeps a small persistent tally with +/- controls.
- **Snippet** stores a reusable line of text and copies it to the clipboard.
- **Bookmark** stores a title plus URL and can open or copy the saved link.

Focus, Calendar, and GitHub are implemented as separate panels:

- **Focus** keeps a simple Pomodoro-style timer in the widget itself.
- **Calendar** requests EventKit access and shows upcoming events.
- **GitHub** reads unread notifications through the `gh` CLI when it is available and authenticated.

## License

MIT
