@testable import NotLight3
import AppKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: NSWindow?
    var resultsState: ResultsState?
    var title: String?
    var message: String?
    var sourceRect: CGRect?
    var sourceView: NSView?
    var edge: NSRectEdge?

    func createMainModule(window: NSWindow) {
        methodsCalled.append(#function)
        self.window = window
    }

    func showResults(state: ResultsState) {
        methodsCalled.append(#function)
        self.resultsState = state
    }

    func showSearchKeys() {
        methodsCalled.append(#function)
    }

    func showDateAssistant() {
        methodsCalled.append(#function)
    }

    func showImportExport(
        sourceRect rect: NSRect,
        sourceView view: NSView,
        edge: NSRectEdge
    ) {
        methodsCalled.append(#function)
        self.sourceRect = rect
        self.sourceView = view
        self.edge = edge
    }

    func dismiss() {
        methodsCalled.append(#function)
    }

    func bringMainToFront() {
        methodsCalled.append(#function)
    }

    func showAlert(title: String, message: String) {
        methodsCalled.append(#function)
        self.title = title
        self.message = message
    }

}
