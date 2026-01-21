import Testing
@testable import NotLight3
import Foundation

private struct PersistenceTests {
    let subject = Persistence()
    let defaults = MockUserDefaults()

    init() {
        services.userDefaults = defaults
    }

    @Test("saveShowFileIcons: saves for key showFileIcons")
    func saveShowFileIcons() {
        subject.saveShowFileIcons(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["showFileIcons"] as? Bool == true)
    }

    @Test("loadShowFileIcons: loads bool for key showFileIcons")
    func loadShowFileIcons() {
        defaults.valuesToReturn["showFileIcons"] = true
        let result = subject.loadShowFileIcons()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveShowFileSizes: saves for key showFileSizes")
    func saveShowFileSizes() {
        subject.saveShowFileSizes(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["showFileSizes"] as? Bool == true)
    }

    @Test("loadShowFileSizes: loads bool for key showFileSizes")
    func loadShowFileSizes() {
        defaults.valuesToReturn["showFileSizes"] = true
        let result = subject.loadShowFileSizes()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveShowModDates: saves for key showModDates")
    func saveShowModDates() {
        subject.saveShowModDates(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["showModDates"] as? Bool == true)
    }

    @Test("loadShowModDates: loads bool for key showModDates")
    func loadShowModDates() {
        defaults.valuesToReturn["showModDates"] = true
        let result = subject.loadShowModDates()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveColumns: saves for key based on column names")
    func saveColumns() throws {
        let columns = [ColumnWidth(name: "hey", width: 10), ColumnWidth(name: "ho", width: 20)]
        subject.saveColumns(columns)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        let saved = try #require(defaults.valuesSet["tableColumnWidths_hey_ho"] as? Data)
        let expected = try PropertyListEncoder().encode(columns)
        #expect(saved == expected)
    }

    @Test("loadColumns: loads for key based on column names")
    func loadColumns() throws {
        let columns = [ColumnWidth(name: "hey", width: 10), ColumnWidth(name: "ho", width: 20)]
        let data = try PropertyListEncoder().encode(columns)
        defaults.valuesToReturn["tableColumnWidths_hey_ho"] = data
        let result = subject.loadColumns(["hey", "ho"])
        #expect(defaults.methodsCalled == ["data(forKey:)"])
        #expect(result == columns)
    }

    @Test("saveWordBased: saves bool for key wordBased")
    func saveWordBased() {
        subject.saveWordBased(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["wordBased"] as? Bool == true)
    }

    @Test("loadWordBased: loads bool for key wordBased")
    func loadWordBased() {
        defaults.valuesToReturn["wordBased"] = true
        let result = subject.loadWordBased()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveCaseInsensitive: saves bool for key caseInsensitive")
    func saveCaseInsensitive() {
        subject.saveCaseInsensitive(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["caseInsensitive"] as? Bool == true)
    }

    @Test("loadCaseInsensitive: loads bool for key caseInsensitive")
    func loadCaseInsensitive() {
        defaults.valuesToReturn["caseInsensitive"] = true
        let result = subject.loadCaseInsensitive()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveDiacriticInsensitive: saves bool for key diacriticInsensitive")
    func saveDiacriticInsensitive() {
        subject.saveDiacriticInsensitive(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["diacriticInsensitive"] as? Bool == true)
    }

    @Test("loadDiacriticInsensitive: loads bool for key diacriticInsensitive")
    func loadDiacriticInsensitive() {
        defaults.valuesToReturn["diacriticInsensitive"] = true
        let result = subject.loadDiacriticInsensitive()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

    @Test("saveAutoContains: saves bool for key autoContains")
    func saveAutoContains() {
        subject.saveAutoContains(true)
        #expect(defaults.methodsCalled == ["set(_:forKey:)"])
        #expect(defaults.valuesSet["autoContains"] as? Bool == true)
    }

    @Test("loadAutoContains: loads bool for key autoContains")
    func loadAutoContains() {
        defaults.valuesToReturn["autoContains"] = true
        let result = subject.loadAutoContains()
        #expect(defaults.methodsCalled == ["bool(forKey:)"])
        #expect(result == true)
    }

}
