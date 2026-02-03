@testable import NotLight3

final class MockImporter: ImporterType {
    var methodsCalled = [String]()
    var term: String?
    var paths = [String]()

    func loadSearch() throws -> (String, [String]) {
        methodsCalled.append(#function)
        let term = self.term ?? ""
        return (term, paths)
    }
}
