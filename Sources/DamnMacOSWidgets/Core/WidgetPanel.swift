import CoreGraphics
import AppKit
import SwiftUI

@MainActor
final class WidgetPanel: NSPanel {
    private let kind: WidgetKind
    private var onFrameChange: ((WidgetFrame) -> Void)?

    init<Content: View>(
        kind: WidgetKind,
        content: Content,
        frame: WidgetFrame,
        onFrameChange: @escaping (WidgetFrame) -> Void
    ) {
        self.kind = kind
        self.onFrameChange = onFrameChange

        super.init(
            contentRect: NSRect(origin: frame.origin, size: frame.size),
            styleMask: [.nonactivatingPanel, .borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        title = kind.title
        isFloatingPanel = false
        level = NSWindow.Level(rawValue: Int(CGWindowLevelForKey(.desktopWindow)))
        collectionBehavior = [.canJoinAllSpaces, .stationary, .fullScreenAuxiliary, .ignoresCycle]
        isMovableByWindowBackground = true
        backgroundColor = .clear
        isOpaque = false
        hasShadow = false
        hidesOnDeactivate = false
        animationBehavior = .none
        becomesKeyOnlyIfNeeded = true

        let hostingView = NSHostingView(rootView: content)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        let containerView = NSView()
        containerView.wantsLayer = true
        containerView.layer?.cornerRadius = 22
        containerView.layer?.masksToBounds = true
        containerView.layer?.backgroundColor = NSColor.clear.cgColor
        containerView.addSubview(hostingView)
        contentView = containerView

        if let contentView = contentView {
            NSLayoutConstraint.activate([
                hostingView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
                hostingView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
                hostingView.topAnchor.constraint(equalTo: contentView.topAnchor),
                hostingView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            ])
        }
    }

    override var canBecomeKey: Bool { true }

    func reportFrame() {
        onFrameChange?(WidgetFrame(origin: frame.origin, size: frame.size))
    }
}
