@testable import NotLight3

final class MockSearchKeysDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = SearchKeysState
    typealias Received = Void
    var statePresented: SearchKeysState?
    var methodsCalled = [String]()

    func present(_ state: SearchKeysState) async {
        self.statePresented = state
    }

}
