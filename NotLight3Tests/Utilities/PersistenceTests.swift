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

}
