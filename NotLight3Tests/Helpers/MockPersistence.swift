@testable import NotLight3

final class MockPersistence: PersistenceType {
    var methodsCalled = [String]()
    var boolSaved: Bool?
    var boolToReturn = false
    var intSaved: Int?
    var intToReturn = -1
    var columnWidthsSaved = [ColumnWidth]()
    var columnWidthsToReturn: [ColumnWidth]?
    var columns = [String]()
    var term: String?
    var search: String?
    var searchOperator: String?

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

    func saveAutoContains(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadAutoContains() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveWordBased(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadWordBased() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveCaseInsensitive(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadCaseInsensitive() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveDiacriticInsensitive(_ value: Bool) {
        methodsCalled.append(#function)
        boolSaved = value
    }

    func loadDiacriticInsensitive() -> Bool {
        methodsCalled.append(#function)
        return boolToReturn
    }

    func saveKeyPopupIndex(_ value: Int) {
        methodsCalled.append(#function)
        intSaved = value
    }

    func loadKeyPopupIndex() -> Int {
        methodsCalled.append(#function)
        return intToReturn
    }

    func saveTerm(_ value: String) {
        methodsCalled.append(#function)
        term = value
    }

    func loadTerm() -> String {
        methodsCalled.append(#function)
        return term ?? ""
    }

    func saveCurrentSearch(_ value: String) {
        methodsCalled.append(#function)
        search = value
    }

    func loadCurrentSearch() -> String {
        methodsCalled.append(#function)
        return search ?? ""
    }

    func saveSearchOperator(_ value: String) {
        methodsCalled.append(#function)
        searchOperator = value
    }

    func loadSearchOperator() -> String {
        methodsCalled.append(#function)
        return searchOperator ?? ""
    }


}
