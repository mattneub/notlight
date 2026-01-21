@testable import NotLight3

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var boolSaved: Bool?
    var boolToReturn = false
    var columnWidthsSaved = [ColumnWidth]()
    var columnWidthsToReturn: [ColumnWidth]?
    var columns = [String]()

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

    func saveColumns(_ columns: [ColumnWidth]) {
        methodsCalled.append(#function)
        columnWidthsSaved = columns
    }

    func loadColumns(_ columns: [String]) -> [ColumnWidth]? {
        methodsCalled.append(#function)
        self.columns = columns
        return columnWidthsToReturn
    }
}
