@testable import NotLight3

final class MockSearcher: SearcherType {
    var methodsCalled = [String]()
    var term: String?
    var resultToReturn = [SearchResult]()

    func doSearch(_ term: String) async throws(SearcherError) -> [SearchResult] {
        methodsCalled.append(#function)
        self.term = term
        return resultToReturn
    }

}
