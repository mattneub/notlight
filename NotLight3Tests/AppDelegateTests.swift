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
        // I don't want to run this code even when testing bootstrap
        // #expect(NSApplication.shared.mainMenu != nil)
        #expect(coordinator.methodsCalled == ["createMainModule(window:)"])
        #expect(coordinator.window === window)
    }

    @Test("applicationShouldTerminateAfterLastWindowClosed is true")
    func applicationShouldTerminateAfterLastWindowClosed() {
        let subject = AppDelegate()
        #expect(subject.applicationShouldTerminateAfterLastWindowClosed(NSApplication.shared) == true)
    }
}


