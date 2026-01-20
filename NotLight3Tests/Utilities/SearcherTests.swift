import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct SearcherTests {
    let subject = Searcher()
    let query = MockMetadataQuery()
    let application = MockApplication()

    init() {
        services.queryFactory.factory = { [self] in return query }
        services.application = application
    }

    @Test("doSearch: constructs query from given term, starts it; when finished notif arrives, stops it and returns results")
    func doSearch() async throws {
        subject.previousQueryString = "dummy"
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path", date: .distantPast, size: 10)]
        // part one: the search begins
        var searchInfo: SearchInfo?
        Task {
            searchInfo = try await subject.doSearch(
                "kMDItemDisplayName == \"testing\"cdw",
                scopes: [],
                joiner: .noJoiner
            )
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(subject.previousQueryString == "kMDItemDisplayName == \"testing\"cdw")
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
        #expect(searchInfo?.results[0].date == .distantPast)
        #expect(searchInfo?.results[0].size == 10)
    }

    @Test("doSearch: if option key is down, constructs previous query string but stops before searching")
    func doSearchOptionKeyDown() async throws {
        subject.previousQueryString = "dummy"
        Task {
            _ = try await subject.doSearch(
                "kMDItemDisplayName == \"testing\"cdw",
                scopes: [],
                joiner: .noJoiner
            )
        }
        application.optionKeyDownToReturn = true
        await #while(subject.previousQueryString == "dummy")
        #expect(subject.previousQueryString == "kMDItemDisplayName == \"testing\"cdw")
        #expect(query.methodsCalled.isEmpty)
    }

    @Test("doSearch: with scopes, uses scopes")
    func doSearchScopes() async throws {
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path", date: .distantPast, size: 10)]
        Task {
            _ = try await subject.doSearch(
                "kMDItemDisplayName == \"testing\"cdw",
                scopes: [URL(string: "file:///testing")!],
                joiner: .noJoiner
            )
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(query._searchScopes as? [URL] == [URL(string: "file:///testing")!]) // *
        subject.stop()
    }

    @Test("doSearch: with joiner, uses joiner .and")
    func doSearchJoinerAnd() async throws {
        subject.previousQueryString = "kMDItemDisplayName == \"previous\""
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path", date: .distantPast, size: 10)]
        Task {
            _ = try await subject.doSearch(
                "kMDItemDisplayName == \"testing\"cdw",
                scopes: [URL(string: "file:///testing")!],
                joiner: .and
            )
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(subject.previousQueryString == "(kMDItemDisplayName == \"previous\") && (kMDItemDisplayName == \"testing\"cdw)") // *
        subject.stop()
    }

    @Test("doSearch: with joiner, uses joiner .or")
    func doSearchJoinerOr() async throws {
        subject.previousQueryString = "kMDItemDisplayName == \"previous\""
        query._resultCount = 1
        query._results = [MockQueryItem(displayName: "name", path: "path", date: .distantPast, size: 10)]
        Task {
            _ = try await subject.doSearch(
                "kMDItemDisplayName == \"testing\"cdw",
                scopes: [URL(string: "file:///testing")!],
                joiner: .or
            )
        }
        await #while(query.methodsCalled.isEmpty)
        #expect(subject.previousQueryString == "(kMDItemDisplayName == \"previous\") || (kMDItemDisplayName == \"testing\"cdw)") // *
        subject.stop()
    }

    @Test("doSearch: with bad search, throws badQuery")
    func doSearchBad() async throws {
        await #expect(throws: SearcherError.badQuery) {
            _ = try await subject.doSearch(
                "howdy",
                scopes: [],
                joiner: .noJoiner
            )
        }
    }

    @Test("stop: stops search, throws into continuation")
    func stop() async throws {
        var searchError: (any Error)?
        Task {
            do {
                _ = try await subject.doSearch(
                    "kMDItemDisplayName == \"testing\"cdw",
                    scopes: [],
                    joiner: .noJoiner
                )
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
