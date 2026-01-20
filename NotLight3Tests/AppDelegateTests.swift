import Testing
@testable import NotLight3
import AppKit

private struct AppDelegateTests {
    @Test("bootstrap: creates and configures the main window; calls root coordinator createMainModule")
    func bootstrap() throws {
        let coordinator = MockRootCoordinator()
        let subject = AppDelegate()
        subject.rootCoordinator = coordinator
        subject.bootstrap()
        let window = try #require(subject.window)
        #expect(window.title == "NotLight")
        #expect(window.styleMask == [.miniaturizable, .closable, .titled])
        // I don't want to run this code even when testing bootstrap, so I've wrapped `unlessTesting` around it
        // #expect(NSApplication.shared.mainMenu != nil)
        #expect(coordinator.methodsCalled == ["createMainModule(window:)"])
        #expect(coordinator.window === window)
    }

    @Test("bootstrap: if there is an Option menu in the app's main menu, makes app delegate its submenu's delegate")
    func bootstrapOptionMenu() {
        let menu = NSMenu()
        let option = NSMenuItem(title: "Option", action: nil, keyEquivalent: "")
        menu.addItem(option)
        let submenu = NSMenu()
        option.submenu = submenu
        NSApplication.shared.mainMenu = menu
        let coordinator = MockRootCoordinator()
        let subject = AppDelegate()
        subject.rootCoordinator = coordinator
        subject.bootstrap()
        #expect(submenu.delegate === subject)
    }

    @Test("applicationShouldTerminateAfterLastWindowClosed is true")
    func applicationShouldTerminateAfterLastWindowClosed() {
        let subject = AppDelegate()
        #expect(subject.applicationShouldTerminateAfterLastWindowClosed(NSApplication.shared) == true)
    }

    @Test("menuWillOpen: sets state of first three Option menu items of menu")
    func menuWillOpen() {
        let menu = NSMenu(title: "Option")
        menu.addItem(withTitle: "hey", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "ho", action: nil, keyEquivalent: "")
        menu.addItem(withTitle: "ha", action: nil, keyEquivalent: "")
        let persistence = MockPersistence()
        services.persistence = persistence
        persistence.boolToReturn = true // just say yes to everything
        let subject = AppDelegate()
        subject.menuWillOpen(menu)
        #expect(menu.item(at: 0)?.state == .on)
        #expect(menu.item(at: 1)?.state == .on)
        #expect(menu.item(at: 2)?.state == .on)
        persistence.boolToReturn = false // now just say no
        subject.menuWillOpen(menu)
        #expect(menu.item(at: 0)?.state == .off)
        #expect(menu.item(at: 1)?.state == .off)
        #expect(menu.item(at: 2)?.state == .off)
    }
}


