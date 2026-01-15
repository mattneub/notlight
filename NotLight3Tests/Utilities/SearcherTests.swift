import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct SearcherTests {
    let subject = Searcher()
    let query = MockMetadataQuery()

    init() {
        services.queryFactory.factory = { [self] in return query }
    }

    @Test("doSearch: constructs query from given term, starts it; when finished notif arrives, stops it and returns results")
    func doSearch() async throws {
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path")]
        // part one: the search begins
        var searchInfo: SearchInfo?
        Task {
            searchInfo = try await subject.doSearch("testing")
        }
        await #while(query.methodsCalled.isEmpty)
        let predicate = try #require(query._predicate)
        #expect(predicate.description == "kMDItemDisplayName ==[cdlw] \"testing\"")
        #expect(query._searchScopes as? [String] == [NSMetadataQueryLocalComputerScope])
        #expect(query.methodsCalled == ["start()"])
        // part two: gathering progress
        NotificationCenter.default.post(name: .NSMetadataQueryGatheringProgress, object: query)
        await #while(subject.searchProgress.count == 0)
        #expect(subject.searchProgress.count == 1)
        // part three: the search ends
        query.methodsCalled = []
        NotificationCenter.default.post(NSMetadataQuery.DidFinishGatheringMessage(), subject: query)
        await #while(query.methodsCalled.isEmpty)
        #expect(query.methodsCalled == ["stop()"])
        #expect(searchInfo?.queryString == "kMDItemDisplayName == \"testing\"cdw")
        #expect(searchInfo?.results.count == 1)
        #expect(searchInfo?.results[0].displayName == "name")
        #expect(searchInfo?.results[0].path == "path")
    }
}
