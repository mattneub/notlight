import Foundation

struct Defaults {
    static let showFileIcons = "showFileIcons"
    static let showModDates = "showModDates"
    static let showFileSizes = "showFileSizes"

    static let additionalKeys = "additionalKeys"

    static let wordBased = "wordBased"
    static let caseInsensitive = "caseInsensitive"
    static let diacriticInsensitive = "diacriticInsensitive"
    static let autoContains = "autoContains"

    static let operatorChoice = "operatorChoice"
    static let keyChoice = "keyChoice"

    static let paths = "paths"
    static let term = "term"
    static let currentSearch = "currentSearch"
}

protocol PersistenceType {
    func saveShowFileIcons(_: Bool)
    func loadShowFileIcons() -> Bool
    func saveShowModDates(_: Bool)
    func loadShowModDates() -> Bool
    func saveShowFileSizes(_: Bool)
    func loadShowFileSizes() -> Bool
}

final class Persistence: PersistenceType {
    func saveShowFileIcons(_ value: Bool) {
        save(value, forKey: Defaults.showFileIcons)
    }
    func loadShowFileIcons() -> Bool {
        load(forKey: Defaults.showFileIcons) ?? false
    }
    func saveShowModDates(_ value: Bool) {
        save(value, forKey: Defaults.showModDates)
    }
    func loadShowModDates() -> Bool {
        load(forKey: Defaults.showModDates) ?? false
    }
    func saveShowFileSizes(_ value: Bool) {
        save(value, forKey: Defaults.showFileSizes)
    }
    func loadShowFileSizes() -> Bool {
        load(forKey: Defaults.showFileSizes) ?? false
    }

    func save<T>(_ value: T, forKey key: String) {
        if T.self == Bool.self {
            services.userDefaults.set(value, forKey: key)
        }
    }

    func load<T>(forKey key: String) -> T? {
        if T.self == Bool.self {
            return services.userDefaults.bool(forKey: key) as? T
        }
        return nil
    }
}
