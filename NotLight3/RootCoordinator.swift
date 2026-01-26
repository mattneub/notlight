import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showResults(state: ResultsState)
    func showSearchKeys()
    func showImportExport(sourceRect rect: NSRect, sourceView view: NSView, edge: NSRectEdge)
    func dismiss()
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?
    var resultsProcessor: (any Processor<ResultsAction, ResultsState, ResultsEffect>)?
    var searchKeysProcessor: (any Processor<SearchKeysAction, SearchKeysState, SearchKeysEffect>)?
    var importExportProcessor: (any Processor<ImportExportAction, ImportExportState, Void>)?

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
        processor.delegate = (mainProcessor as? any SearchKeysDelegate)
        // deliberate "load view and delay" strategy so that things don't visibly jump around
        viewController.loadViewIfNeeded()
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            mainViewController?.presentAsSheet(viewController)
        }
    }

    func showImportExport(sourceRect rect: NSRect, sourceView view: NSView, edge: NSRectEdge) {
        let processor = ImportExportProcessor()
        self.importExportProcessor = processor
        processor.coordinator = self
        let viewController = ImportExportViewController()
        processor.presenter = viewController
        viewController.processor = processor
        processor.delegate = (mainProcessor as? any ImportExportDelegate)
        // deliberate "load view and delay" strategy so that things don't visibly jump around
        viewController.loadViewIfNeeded()
        Task {
            try? await Task.sleep(for: .seconds(0.2))
            mainViewController?.present(
                viewController,
                asPopoverRelativeTo: rect,
                of: view,
                preferredEdge: edge,
                behavior: .transient
            )
        }
    }

    func dismiss() {
        if let presented = mainViewController?.presentedViewControllers?.first {
            mainViewController?.dismiss(presented)
        }
    }
}
