import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showResults(state: ResultsState)
    func showSearchKeys()
    func dismiss()
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?
    var resultsProcessor: (any Processor<ResultsAction, ResultsState, ResultsEffect>)?
    var searchKeysProcessor: (any Processor<SearchKeysAction, SearchKeysState, SearchKeysEffect>)?

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
        // deliberate "load view and delay" strategy so that things don't visibly jump around
        viewController.loadViewIfNeeded()
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            mainViewController?.presentAsSheet(viewController)
        }
    }

    func showSearchKeys() {
        let processor = SearchKeysProcessor()
        self.searchKeysProcessor = processor
        processor.coordinator = self
        let viewController = SearchKeysViewController()
        processor.presenter = viewController
        viewController.processor = processor
        // deliberate "load view and delay" strategy so that things don't visibly jump around
        viewController.loadViewIfNeeded()
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            mainViewController?.presentAsSheet(viewController)
        }
    }

    func dismiss() {
        if let presented = mainViewController?.presentedViewControllers?.first {
            mainViewController?.dismiss(presented)
        }
    }
}
