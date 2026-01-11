import AppKit

protocol RootCoordinatorType: AnyObject {
    func createMainModule(mainViewController: MainViewController)
}

final class RootCoordinator: RootCoordinatorType {
    weak var mainViewController: NSViewController?

    var mainProcessor: (any Processor<MainAction, MainState, Void>)?

    func createMainModule(mainViewController: MainViewController) {
        let processor = MainProcessor()
        self.mainProcessor = processor
        processor.coordinator = self
        processor.presenter = mainViewController
        mainViewController.processor = processor
        self.mainViewController = mainViewController
    }
}
