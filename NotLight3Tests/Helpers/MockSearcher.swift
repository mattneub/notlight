@testable import NotLight3

final class MockSearcher: SearcherType {
    var methodsCalled = [String]()
    var term: String?
    var resultToReturn = SearchInfo(queryString: "", results: [])
    var errorToThrow: SearcherError?
    var timeToSleep: Double = 0

    var searchProgress = SearchProgress()

    func doSearch(_ term: String) async throws(SearcherError) -> SearchInfo {
        methodsCalled.append(#function)
        self.term = term
        if timeToSleep > 0 {
            try? await Task.sleep(for: .seconds(timeToSleep))
        }
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }

}
