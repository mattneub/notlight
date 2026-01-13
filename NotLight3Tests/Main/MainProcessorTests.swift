import Testing
@testable import NotLight3
import Foundation

private struct MainProcessorTests {
    let subject = MainProcessor()
    let searcher = MockSearcher()
    let coordinator = MockRootCoordinator()

    init() {
        subject.coordinator = coordinator
        services.searcher = searcher
    }

    @Test("receive returnInSearchField: calls searcher doSearch")
    func returnInSearchField() async {
        let result = SearchInfo(queryString: "query", results: [SearchResult(displayName: "name", path: "path")])
        searcher.resultToReturn = result
        await subject.receive(.returnInSearchField("howdy"))
        #expect(searcher.methodsCalled == ["doSearch(_:)"])
        #expect(searcher.term == "howdy")
        #expect(coordinator.methodsCalled == ["showResults(state:)"])
        #expect(coordinator.resultsState?.queryString == result.queryString)
        #expect(coordinator.resultsState?.results == result.results)
    }

    @Test("receive returnInSearchField: if term is empty, does nothing")
    func returnInSearchFieldEmpty() async {
        await subject.receive(.returnInSearchField(""))
        #expect(searcher.methodsCalled.isEmpty)
        #expect(coordinator.methodsCalled.isEmpty)
    }

    @Test("receive returnInSearchField: if search throws, does nothing")
    func returnInSearchFieldThrow() async {
        searcher.errorToThrow = .badQuery
        await subject.receive(.returnInSearchField("howdy"))
        #expect(searcher.methodsCalled == ["doSearch(_:)"])
        #expect(searcher.term == "howdy")
        #expect(coordinator.methodsCalled.isEmpty)
    }
}
