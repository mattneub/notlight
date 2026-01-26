import Testing
@testable import NotLight3
import AppKit
import WaitWhile

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

    @Test("showResults: assembles the results module, sets the state, presents the view controller")
    func showResults() async throws {
        let state = ResultsState(results: [.init(displayName: "name", path: "path", date: .distantPast, size: 10)])
        let mainViewController = NSViewController()
        makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        subject.showResults(state: state)
        let processor = try #require(subject.resultsProcessor as? ResultsProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? ResultsViewController)
        #expect(viewController.processor === processor)
        await #while(mainViewController.presentedViewControllers?.first == nil)
        #expect(mainViewController.presentedViewControllers?.first === viewController)
    }

    @Test("showSearchKeys: assembles the search keys module, presents the view controller")
    func showSearchKeys() async throws {
        subject.mainProcessor = MainProcessor()
        let mainViewController = NSViewController()
        makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        subject.showSearchKeys()
        let processor = try #require(subject.searchKeysProcessor as? SearchKeysProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.delegate === subject.mainProcessor)
        let viewController = try #require(processor.presenter as? SearchKeysViewController)
        #expect(viewController.processor === processor)
        await #while(mainViewController.presentedViewControllers?.first == nil)
        #expect(mainViewController.presentedViewControllers?.first === viewController)
    }

    @Test("dismiss: dismisses the presented view controller")
    func dismiss() throws {
        let mainViewController = NSViewController()
        makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        let presented = NSViewController()
        mainViewController.presentAsSheet(presented)
        #expect(mainViewController.presentedViewControllers?.count == 1)
        subject.dismiss()
        #expect(mainViewController.presentedViewControllers?.count == 0)
    }
}
