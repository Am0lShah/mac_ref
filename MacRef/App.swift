import SwiftUI
import AppKit

// MARK: - App Entry Point

@main
struct MacRefApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
        }
        // Remove default window chrome via scene modifiers
        .windowStyle(.hiddenTitleBar)
        .defaultSize(width: 900, height: 700)
    }
}

// MARK: - AppDelegate

final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        configureMainWindow()
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    // MARK: Window Configuration

    private func configureMainWindow() {
        guard let window = NSApplication.shared.windows.first else { return }

        // ── Always on Top ──────────────────────────────────────────────────
        // .floating sits above normal windows but below full-screen overlays.
        // Use .screenSaver if you need it above everything (even menus).
        window.level = .floating

        // ── Frameless / Borderless ─────────────────────────────────────────
        window.styleMask = [
            .borderless,
            .resizable,
            .miniaturizable,
            .fullSizeContentView
        ]

        // ── Transparency & Appearance ──────────────────────────────────────
        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true

        // Force dark appearance at the NSWindow level
        window.appearance = NSAppearance(named: .darkAqua)

        // ── Title Bar Hidden ───────────────────────────────────────────────
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden

        // ── Allow dragging from anywhere on the background ─────────────────
        window.isMovableByWindowBackground = true

        // ── Minimum size so the window can't be collapsed to nothing ────────
        window.minSize = NSSize(width: 300, height: 200)

        // Center on first launch
        window.center()
    }
}
