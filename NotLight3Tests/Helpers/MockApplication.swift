@testable import NotLight3

final class MockApplication: ApplicationType {
    var optionKeyDownToReturn = false
    var methodsCalled = [String]()
    var error: (any Error)?

    var optionKeyDown: Bool {
        optionKeyDownToReturn
    }

    func presentError(_ error: any Error) -> Bool {
        methodsCalled.append(#function)
        self.error = error
        return true
    }
}
