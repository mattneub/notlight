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
        // The Empty.xib file prevents automatic finding of the MainMenu.xib file,
        // so we can now load it ourselves as part of the bootstrap
        // but I don't want to do that even when testing this method, because of the massive console dump it causes
        unlessTesting {
            Bundle.main.loadNibNamed("MainMenu", owner: NSApplication.shared, topLevelObjects: nil)
        }
        // create the window _after_ loading the menu, so that it gets registered into the window menu
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 270),
            styleMask: [.miniaturizable, .closable, .titled],
            backing: .buffered,
            defer: false
        )
        rootCoordinator.createMainModule(window: window)
        window.center()
        window.title = "NotLight"
        window.makeKeyAndOrderFront(nil)
        window.setFrameAutosaveName("NotLight_Main_Window")
        // hook Option menu to our "manual binding" system
        NSApplication.shared.mainMenu?.item(withTitle: "Option")?.submenu?.delegate = self
    }

    func applicationDidBecomeActive(_ notif: Notification) {
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        true
    }
}

/// "Manual binding" from user defaults to menu checkmark state.
extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        if menu.title == "Option" {
            menu.item(at: 0)?.state = services.persistence.loadShowFileIcons() ? .on : .off
            menu.item(at: 1)?.state = services.persistence.loadShowModDates() ? .on : .off
            menu.item(at: 2)?.state = services.persistence.loadShowFileSizes() ? .on : .off
        }
    }
}

