@testable import NotLight3

final class MockSearcher: SearcherType {
    var methodsCalled = [String]()
    var term: String?
    var resultToReturn = SearchInfo(queryString: "", results: [])
    var errorToThrow: SearcherError?
    var timeToSleep: Double = 0
    var scopes = [URL]()
    var joiner: SearchJoiner?

    var searchProgress = SearchProgress()

    func doSearch(_ term: String, scopes: [URL], joiner: SearchJoiner) async throws -> SearchInfo {
        methodsCalled.append(#function)
        self.term = term
        self.scopes = scopes
        self.joiner = joiner
        if timeToSleep > 0 {
            try? await Task.sleep(for: .seconds(timeToSleep))
        }
        if let errorToThrow {
            throw errorToThrow
        }
        return resultToReturn
    }

    func stop() {
        methodsCalled.append(#function)
    }

}
