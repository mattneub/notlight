@testable import NotLight3

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var boolSaved: Bool?
    var boolToReturn = false

    func saveShowFileIcons(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadShowFileIcons() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveShowModDates(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadShowModDates() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveShowFileSizes(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadShowFileSizes() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

}
