import Testing
@testable import NotLight3

private struct SearchResultTests {
    @Test("SearchResults round-trips with SortableSearchResult, except for UUID")
    func sortable() {
        let subject = SearchResult(displayName: "hey", path: "ho")
        let sortableResult = SortableSearchResult(searchResult: subject)
        #expect(sortableResult.displayName == "hey")
        #expect(sortableResult.path == "ho")
        let subject2 = SearchResult(sortableSearchResult: sortableResult)
        #expect(subject2.displayName == "hey")
        #expect(subject2.path == "ho")
    }
}
