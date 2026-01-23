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

    // static let paths = "paths"
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
    func saveWordBased(_ value: Bool)
    func loadWordBased() -> Bool
    func saveCaseInsensitive(_ value: Bool)
    func loadCaseInsensitive() -> Bool
    func saveDiacriticInsensitive(_ value: Bool)
    func loadDiacriticInsensitive() -> Bool
    func saveAutoContains(_ value: Bool)
    func loadAutoContains() -> Bool
    func saveKeyPopupIndex(_: Int)
    func loadKeyPopupIndex() -> Int
    func saveTerm(_ value: String)
    func loadTerm() -> String
    func saveCurrentSearch(_ value: String)
    func loadCurrentSearch() -> String
    func saveSearchOperator(_ value: String)
    func loadSearchOperator() -> String
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
    func saveWordBased(_ value: Bool) {
        save(value, forKey: Defaults.wordBased)
    }
    func loadWordBased() -> Bool {
        load(forKey: Defaults.wordBased) ?? false
    }
    func saveCaseInsensitive(_ value: Bool) {
        save(value, forKey: Defaults.caseInsensitive)
    }
    func loadCaseInsensitive() -> Bool {
        load(forKey: Defaults.caseInsensitive) ?? false
    }
    func saveDiacriticInsensitive(_ value: Bool) {
        save(value, forKey: Defaults.diacriticInsensitive)
    }
    func loadDiacriticInsensitive() -> Bool {
        load(forKey: Defaults.diacriticInsensitive) ?? false
    }
    func saveAutoContains(_ value: Bool) {
        save(value, forKey: Defaults.autoContains)
    }
    func loadAutoContains() -> Bool {
        load(forKey: Defaults.autoContains) ?? false
    }
    func saveKeyPopupIndex(_ value: Int) {
        save(value, forKey: Defaults.keyChoice)
    }
    func loadKeyPopupIndex() -> Int {
        load(forKey: Defaults.keyChoice) ?? 0
    }
    func saveTerm(_ value: String) {
        save(value, forKey: Defaults.term)
    }
    func loadTerm() -> String {
        load(forKey: Defaults.term) ?? ""
    }
    func saveCurrentSearch(_ value: String) {
        save(value, forKey: Defaults.currentSearch)
    }
    func loadCurrentSearch() -> String {
        load(forKey: Defaults.currentSearch) ?? ""
    }
    func saveSearchOperator(_ value: String) {
        save(value, forKey: Defaults.operatorChoice)
    }
    func loadSearchOperator() -> String {
        load(forKey: Defaults.operatorChoice) ?? "=="
    }

    func save<T: Codable>(_ value: T, forKey key: String) {
        if T.self == Bool.self || T.self == Int.self || T.self == String.self {
            services.userDefaults.set(value, forKey: key)
        } else {
            let data = try? PropertyListEncoder().encode(value)
            services.userDefaults.set(data, forKey: key)
        }
    }

    func load<T: Codable>(forKey key: String) -> T? {
        if T.self == Bool.self {
            return services.userDefaults.bool(forKey: key) as? T
        } else if T.self == Int.self {
            return services.userDefaults.integer(forKey: key) as? T
        } else if T.self == String.self {
            return services.userDefaults.string(forKey: key) as? T
        } else {
            if let data = services.userDefaults.data(forKey: key) {
                return try? PropertyListDecoder().decode(T.self, from: data)
            }
        }
        return nil
    }
}
