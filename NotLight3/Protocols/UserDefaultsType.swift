import Foundation

/// Protocol that describes UserDefaults so we can mock it for testing.
protocol UserDefaultsType {
    func set(_: Any?, forKey: String)
    func bool(forKey: String) -> Bool
    func integer(forKey: String) -> Int
    func data(forKey: String) -> Data?
}

extension UserDefaults: UserDefaultsType {}
