@testable import NotLight3

final class MockBeeper: BeeperType {
    var methodsCalled = [String]()

    func beep() {
        methodsCalled.append(#function)
    }
}
