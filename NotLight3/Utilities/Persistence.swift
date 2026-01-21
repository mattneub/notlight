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

    static func key(forColumns columns: [String]) -> String {
        let array = ["tableColumnWidths"] + columns
        return array.joined(separator: "_")
    }
}

protocol PersistenceType {
    func saveShowFileIcons(_: Bool)
    func loadShowFileIcons() -> Bool
    func saveShowModDates(_: Bool)
    func loadShowModDates() -> Bool
    func saveShowFileSizes(_: Bool)
    func loadShowFileSizes() -> Bool
    func saveColumns(_: [ColumnWidth])
    func loadColumns(_: [String]) -> [ColumnWidth]?
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
    func saveColumns(_ columns: [ColumnWidth]) {
        let key = Defaults.key(forColumns: columns.map(\.name))
        save(columns, forKey: key)
    }
    func loadColumns(_ columns: [String]) -> [ColumnWidth]? {
        let key = Defaults.key(forColumns: columns)
        return load(forKey: key)
    }


    func save<T: Codable>(_ value: T, forKey key: String) {
        if T.self == Bool.self {
            services.userDefaults.set(value, forKey: key)
        } else {
            let data = try? PropertyListEncoder().encode(value)
            services.userDefaults.set(data, forKey: key)
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        if T.self == Bool.self {
            return services.userDefaults.bool(forKey: key) as? T
        } else {
            if let data = services.userDefaults.data(forKey: key) {
                return try? PropertyListDecoder().decode(T.self, from: data)
            }
        }
        return nil
    }
}
