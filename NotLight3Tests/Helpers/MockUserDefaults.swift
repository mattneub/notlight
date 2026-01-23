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

    func integer(forKey key: String) -> Int {
        methodsCalled.append(#function)
        return valuesToReturn[key] as? Int ?? crashThisTest(key)
    }

    func string(forKey key: String) -> String? {
        methodsCalled.append(#function)
        return valuesToReturn[key] as? String ?? crashThisTest(key)
    }

    func data(forKey key: String) -> Data? {
        methodsCalled.append(#function)
        return valuesToReturn[key] as? Data
    }

    func crashThisTest<T>(_ key: String) -> T {
        fatalError("no value for key \(key) as \(T.self) found in valuesToReturn")
    }
}
