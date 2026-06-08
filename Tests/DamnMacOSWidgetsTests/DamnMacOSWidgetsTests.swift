import CoreGraphics
import Foundation
import XCTest
@testable import DamnMacOSWidgets

@MainActor
final class DamnMacOSWidgetsTests: XCTestCase {
    func testLocalStoreRoundTripsAppState() throws {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("state.json")

        defer {
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
        }

        let store = LocalStore(fileURL: storeURL)
        let state = AppState(
            widgets: [
                WidgetKind.now.rawValue: WidgetState(
                    isVisible: true,
                    frame: WidgetFrame(
                        origin: CGPoint(x: 42, y: 84),
                        size: CGSize(width: 280, height: 120)
                    )
                ),
                WidgetKind.counter.rawValue: WidgetState(
                    isVisible: false,
                    frame: WidgetFrame(
                        origin: CGPoint(x: 120, y: 160),
                        size: CGSize(width: 220, height: 180)
                    )
                )
            ],
            nowText: "Ship it",
            todos: [TodoItem(title: "Write tests", isDone: false)],
            noteText: "Keep moving",
            counterValue: 7,
            snippetText: "swift test",
            bookmarkTitle: "Docs",
            bookmarkURL: "https://example.com/docs",
            focus: FocusTimerState(
                durationSeconds: 1_500,
                remainingSeconds: 1_200,
                isRunning: true,
                startedAt: Date(timeIntervalSince1970: 1_700_000_000)
            ),
            launchAtLoginEnabled: true
        )

        store.save(state)

        XCTAssertEqual(store.load(), state)
    }

    func testFocusTimerTransitions() {
        var focus = FocusTimerState(
            durationSeconds: 1_500,
            remainingSeconds: 1_500,
            isRunning: false,
            startedAt: nil
        )
        let startDate = Date(timeIntervalSince1970: 1_700_000_000)
        let laterDate = startDate.addingTimeInterval(90)

        focus.start(now: startDate)
        XCTAssertTrue(focus.isRunning)
        XCTAssertEqual(focus.remainingSeconds(at: laterDate), 1_410)

        focus.pause(now: laterDate)
        XCTAssertFalse(focus.isRunning)
        XCTAssertEqual(focus.remainingSeconds, 1_410)

        focus.reset()
        XCTAssertEqual(focus.remainingSeconds, 1_500)
        XCTAssertFalse(focus.isRunning)
    }

    func testWidgetManagerMutations() {
        let storeURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
            .appendingPathComponent("state.json")

        defer {
            try? FileManager.default.removeItem(at: storeURL.deletingLastPathComponent())
        }

        let manager = WidgetManager(
            store: LocalStore(fileURL: storeURL),
            autoBootstrap: false
        )

        XCTAssertTrue(manager.isVisible(.now))
        XCTAssertTrue(manager.hasHiddenWidgets)

        manager.updateNow("A better note")
        manager.addTodo("Write docs")
        manager.updateNote("Scratchpad")
        manager.incrementCounter()
        manager.updateSnippet("pnpm test")
        manager.updateBookmarkTitle("Repo")
        manager.updateBookmarkURL("https://github.com")

        XCTAssertEqual(manager.appState.nowText, "A better note")
        XCTAssertEqual(manager.appState.todos.count, 1)
        XCTAssertEqual(manager.appState.todos.first?.title, "Write docs")
        XCTAssertEqual(manager.appState.noteText, "Scratchpad")
        XCTAssertEqual(manager.appState.counterValue, 1)
        XCTAssertEqual(manager.appState.snippetText, "pnpm test")
        XCTAssertEqual(manager.appState.bookmarkTitle, "Repo")
        XCTAssertEqual(manager.appState.bookmarkURL, "https://github.com")
    }
}
