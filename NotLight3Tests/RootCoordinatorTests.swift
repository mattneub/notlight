import Testing
@testable import NotLight3
import AppKit

private struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createMainModule: creates the main module")
    func createMainModule() throws {
        let window = NSWindow()
        subject.createMainModule(window: window)
        let processor = try #require(subject.mainProcessor as? MainProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? MainViewController)
        #expect(viewController.processor === processor)
        #expect(subject.mainViewController === viewController)
        #expect(window.contentViewController === viewController)
    }
}
