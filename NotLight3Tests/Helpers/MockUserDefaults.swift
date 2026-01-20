import Testing
@testable import NotLight3
import AppKit

final class MockUserDefaults: UserDefaultsType {
    var methodsCalled = [String]()
    var valuesSet = [String: Any?]()
    var valuesToReturn = [String: Any?]()

    func set(_ value: Any?, forKey key: String) {
        methodsCalled.append(#function)
        valuesSet[key] = value
    }

    func bool(forKey key: String) -> Bool {
        methodsCalled.append(#function)
        return valuesToReturn[key] as? Bool ?? crashThisTest(key)
    }

    func crashThisTest(_ key: String) -> Bool {
        fatalError("no value for key \(key) as Bool found in valuesToReturn")
    }
}
