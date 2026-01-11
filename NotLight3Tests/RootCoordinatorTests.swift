import Testing
@testable import NotLight3
import AppKit

private struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createMainModule: creates the main module")
    func createMainModule() throws {
        let viewController = MainViewController()
        subject.createMainModule(mainViewController: viewController)
        let processor = try #require(subject.mainProcessor as? MainProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.presenter === viewController)
        #expect(viewController.processor === processor)
        #expect(subject.mainViewController === viewController)
    }
}
