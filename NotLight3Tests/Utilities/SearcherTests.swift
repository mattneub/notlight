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
            searchInfo = try await subject.doSearch("kMDItemDisplayName == \"testing\"cdw", scopes: [])
        }
        await #while(query.methodsCalled.isEmpty)
        let predicate = try #require(query._predicate)
        #expect(predicate.description == "kMDItemDisplayName ==[cdlw] \"testing\"") // I have no idea what the "l" is
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

    @Test("doSearch: with scopes, uses scopes")
    func doSearchScopes() async throws {
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path")]
        Task {
            _ = try await subject.doSearch("kMDItemDisplayName == \"testing\"cdw", scopes: [URL(string: "file:///testing")!])
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(query._searchScopes as? [URL] == [URL(string: "file:///testing")!]) // *
        subject.stop()
    }

    @Test("doSearch: with bad search, throws badQuery")
    func doSearchBad() async throws {
        await #expect(throws: SearcherError.badQuery) {
            _ = try await subject.doSearch("howdy", scopes: [])
        }
    }

    @Test("stop: stops search, throws into continuation")
    func stop() async throws {
        var searchError: (any Error)?
        Task {
            do {
                _ = try await subject.doSearch("kMDItemDisplayName == \"testing\"cdw", scopes: [])
            } catch {
                searchError = error
            }
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(query.methodsCalled == ["start()"])
        query.methodsCalled = []
        subject.stop()
        await #while(searchError == nil)
        #expect(searchError as? SearcherError == .userStopped)
        #expect(query.methodsCalled == ["stop()"])
    }

}
