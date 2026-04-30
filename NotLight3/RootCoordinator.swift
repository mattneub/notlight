import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(window: NSWindow)
    func showResults(state: ResultsState)
    func showSearchKeys()
    func showDateAssistant()
    func showImportExport(sourceRect rect: NSRect, sourceView view: NSView, edge: NSRectEdge)
    func dismiss()
    func bringMainToFront()
    func showAlert(title: String, message: String) async
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    /// In case we need to know where the main window is, or bring it to the front.
    weak var mainWindow: NSWindow?

    /// Allows us to know whether the date assistant window exists, so we don't create two.
    weak var dateAssistantWindow: NSWindow?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?
    var resultsProcessor: (any Processor<ResultsAction, ResultsState, ResultsEffect>)?
    var searchKeysProcessor: (any Processor<SearchKeysAction, SearchKeysState, SearchKeysEffect>)?
    var dateProcessor: (any Processor<DateAction, DateState, Void>)?
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
        self.mainWindow = window
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
        Task.immediate {
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
        Task.immediate {
            try? await Task.sleep(for: .seconds(0.2))
            mainViewController?.presentAsSheet(viewController)
        }
    }

    func showDateAssistant() {
        guard dateAssistantWindow == nil else {
            return
        }
        let processor = DateProcessor()
        self.dateProcessor = processor
        processor.coordinator = self
        let viewController = DateViewController()
        processor.presenter = viewController
        processor.delegate = mainProcessor as? any DateDelegate
        viewController.processor = processor
        // deliberate "load view and delay" strategy so that things don't visibly jump around
        viewController.loadViewIfNeeded()
        Task.immediate {
            try? await Task.sleep(for: .seconds(0.2))
            let window = NSPanel(
                contentRect: NSRect(x: 0, y: 0, width: 316, height: 222),
                styleMask: [.utilityWindow, .closable, .titled],
                backing: .buffered,
                defer: false
            )
            services.application.addWindowsItem(window, title: "Date Assistant", filename: false)
            window.center()
            window.title = "Date Assistant"
            window.contentViewController = viewController
            window.isReleasedWhenClosed = false
            window.makeKeyAndOrderFront(nil)
            self.dateAssistantWindow = window
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
        Task.immediate {
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

    func bringMainToFront() {
        mainWindow?.makeKeyAndOrderFront(nil)
    }

    func showAlert(title: String, message: String) async {
        guard let mainWindow else {
            return
        }
        let alert = services.alertFactory.makeAlert()
        alert.alertStyle = .informational
        alert.messageText = title
        alert.informativeText = message
        await alert.beginSheetModal(for: mainWindow)
    }
}
