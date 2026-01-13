@testable import NotLight3

final class MockSearcher: SearcherType {
    var methodsCalled = [String]()
    var term: String?
    var resultToReturn = [SearchResult]()
    var errorToThrow: SearcherError?

    func doSearch(_ term: String) async throws(SearcherError) -> [SearchResult] {
        methodsCalled.append(#function)
        self.term = term
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }

}
