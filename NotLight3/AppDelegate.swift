import AppKit

@MainActor
var services: Services = Services()

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: NSWindow!

    var rootCoordinator: any RootCoordinatorType = RootCoordinator()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        unlessTesting {
            bootstrap()
        }
    }

    func bootstrap() {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
            styleMask: [.miniaturizable, .closable, .titled],
            backing: .buffered,
            defer: false
        )
        window.center()
        window.title = "NotLight"
        window.makeKeyAndOrderFront(nil)
        // The Empty.xib file prevents automatic finding of the MainMenu.xib file,
        // so we can now load it ourselves as part of the bootstrap
        // but I don't want to do that even when testing this method, because of the massive console dump it causes
        unlessTesting {
            Bundle.main.loadNibNamed("MainMenu", owner: NSApplication.shared, topLevelObjects: nil)
        }
        rootCoordinator.createMainModule(window: window)
    }

    func applicationDidBecomeActive(_ notif: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

