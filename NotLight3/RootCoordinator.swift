import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showResults(state: ResultsState)
    func dismiss()
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?
    var resultsProcessor: (any Processor<ResultsAction, ResultsState, Void>)?

    func createMainModule(window: NSWindow) {
        let processor = MainProcessor()
        self.mainProcessor = processor
        processor.coordinator = self
        let viewController = MainViewController()
        processor.presenter = viewController
        viewController.processor = processor
        self.mainViewController = viewController
        window.contentViewController = viewController
    }

    func showResults(state: ResultsState) {
        let processor = ResultsProcessor()
        self.resultsProcessor = processor
        processor.state = state
        processor.coordinator = self
        let viewController = ResultsViewController()
        processor.presenter = viewController
        viewController.processor = processor
        mainViewController?.presentAsSheet(viewController)
    }

    func dismiss() {
        if let presented = mainViewController?.presentedViewControllers?.first {
            mainViewController?.dismiss(presented)
        }
    }
}
