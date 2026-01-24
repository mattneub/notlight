@testable import NotLight3

final class MockSearchKeysDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = SearchKeysState
    typealias Received = SearchKeysEffect
    var statePresented: SearchKeysState?
    var methodsCalled = [String]()
    var thingsReceived = [SearchKeysEffect]()

    func present(_ state: SearchKeysState) async {
        methodsCalled.append(#function)
        self.statePresented = state
    }

    func receive(_ effect: SearchKeysEffect) async {
        methodsCalled.append(#function)
        self.thingsReceived.append(effect)
    }
}
