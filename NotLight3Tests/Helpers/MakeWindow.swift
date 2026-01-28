@testable import NotLight3
import AppKit

@discardableResult
func makeWindow(viewController: NSViewController) -> NSWindow {
    for window in NSApplication.shared.windows {
        if !window.isReleasedWhenClosed {
            window.close()
        }
    }
    let window = NSWindow(
        contentRect: NSRect(x: -10000, y: -10000, width: 480, height: 270),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    window.contentViewController = viewController
    window.makeKeyAndOrderFront(nil)
    window.isReleasedWhenClosed = false
    return window
}

@discardableResult
func makeWindow(view: NSView) -> NSWindow {
    for window in NSApplication.shared.windows {
        if !window.isReleasedWhenClosed {
            window.close()
        }
    }
    let window = NSWindow(
        contentRect: NSRect(x: -10000, y: -10000, width: 480, height: 270),
        styleMask: [.miniaturizable, .closable, .resizable, .titled],
        backing: .buffered,
        defer: false
    )
    window.contentView = view
    window.makeKeyAndOrderFront(nil)
    window.isReleasedWhenClosed = false
    return window
}
