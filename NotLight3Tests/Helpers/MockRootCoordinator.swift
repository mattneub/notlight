@testable import NotLight3
import AppKit

final class MockRootCoordinator: RootCoordinatorType {
    var methodsCalled = [String]()
    var window: NSWindow?
    var resultsState: ResultsState?

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

    func dismiss() {
        methodsCalled.append(#function)
    }

}
