@testable import NotLight3

final class MockResultsDatasource: NSObject, @MainActor ResultsDatasourceType {
    typealias State = ResultsState
    typealias Received = Void
    var statePresented: ResultsState?
    var methodsCalled = [String]()

    func present(_ state: ResultsState) async {
        self.statePresented = state
    }

}
