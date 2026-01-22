@testable import NotLight3

final class MockAppleScripter: AppleScripterType {
    var methodsCalled = [String]()
    var stringToReturn = ""

    func executeScript() -> String {
        methodsCalled.append(#function)
        return stringToReturn
    }

}
