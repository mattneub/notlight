import AppKit

protocol SearcherType {
    var searchProgress: SearchProgress { get }
    func doSearch(_ term: String, scopes: [URL], joiner: SearchJoiner) async throws -> SearchInfo
    func stop()
}

final class Searcher: SearcherType {
    /// The query, held while we are performing it. This has two purposes: it keeps the query
    /// alive, and it maintains it in a place where multiple methods can access it, so we don't
    /// have to worry about the fact that an NSMetadataQuery is not Sendable.
    var query: NSMetadataQuery?

    /// Query string most recently submitted. This persists between searches, allowing us to
    /// build successive cumulative queries with AND and OR.
    var previousQueryString: String?

    /// Public observable object that publishes the growing count of found results.
    let searchProgress = SearchProgress()

    /// Observer that notifies us periodically that the query is ongoing.
    var gatheringObserver: (any NSObjectProtocol)?

    /// Observer that notifies us that the query has finished.
    var finishedObserver: NotificationCenter.ObservationToken?

    /// Private exposure of the finished observer continuation, so we can interrupt by throwing.
    var continuation: CheckedContinuation<[SearchResult], any Error>?

    /// Public method.
    func doSearch(_ queryString: String, scopes: [URL], joiner: SearchJoiner) async throws -> SearchInfo {
        let stopBeforeSearching = services.application.optionKeyDown
        searchProgress.count = 0
        let query = services.queryFactory.makeQuery()
        self.query = query
        var queryString = queryString
        if let previousQueryString {
            queryString = switch joiner {
            case .and: "(\(previousQueryString)) && (\(queryString))"
            case .noJoiner: queryString
            case .or: "(\(previousQueryString)) || (\(queryString))"
            }
        }
        do {
            try ExceptionCatcher.catchException {
                // unfortunately there's a long-standing bug: NSPredicate `init?(forMetadataQueryString)`
                // with a bad string does not gracefully return nil but raises an NSException
                // so we form the predicate in the domain of our Objective-C exception catcher
                // and if _that_ raises, we throw in good order
                query.predicate = NSPredicate(fromMetadataQueryString: queryString)
            }
        } catch {
            throw SearcherError.badQuery
        }
        previousQueryString = queryString
        query.searchScopes = scopes.isEmpty ? [NSMetadataQueryLocalComputerScope] : scopes
        if stopBeforeSearching {
            throw SearcherError.userStopped
        }
        query.start()
        gatheringObserver = NotificationCenter.default.addObserver(
            forName: .NSMetadataQueryGatheringProgress, object: query, queue: nil
        ) { [unowned self] _ in
            Task {
                await updateProgress()
            }
        }
        let results = try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation // so that `stop` can throw into it
            finishedObserver = NotificationCenter.default.addObserver(
                of: query,
                for: NSMetadataQuery.DidFinishGatheringMessage.self
            ) { [unowned self] _ in
                continuation.resume(returning: await gatherResults())
            }
        }
        // clean up and we're out of here
        cleanup()
        return SearchInfo(queryString: queryString, results: results)
    }

    /// Ancillary method that gathers the results from the query and reduces them into
    /// an array of our sendable result struct, suitable for passing across isolation boundaries
    /// and ultimately for displaying to the user.
    func gatherResults() async -> [SearchResult] {
        var searchResults = [SearchResult]()
        guard let query else {
            return searchResults
        }
        // how to cycle; do _not_ retain the `results` property
        for index in 0..<query.resultCount {
            if let result = query.result(at: index) as? any QueryItemType {
                guard let displayName = result.displayName else {
                    continue
                }
                guard let path = result.path else {
                    continue
                }
                searchResults.append(SearchResult(displayName: displayName, path: path))
            }
        }
        return searchResults
    }

    /// Method called periodically during a search, to update our observable progress.
    func updateProgress() {
        searchProgress.count = query?.resultCount ?? 0
    }

    /// Public method that interrupts a search in progress.
    func stop() {
        continuation?.resume(throwing: SearcherError.userStopped)
        cleanup()
    }

    /// Utility method that provides the coda to a search, completed or interrupted.
    func cleanup() {
        if let finishedObserver {
            NotificationCenter.default.removeObserver(finishedObserver)
        }
        if let gatheringObserver {
            NotificationCenter.default.removeObserver(gatheringObserver)
        }
        query?.stop()
    }
}

enum SearcherError: Error {
    case badQuery
    case userStopped
}

enum SearchJoiner {
    case and
    case noJoiner
    case or
}

@Observable
final class SearchProgress {
    var count: Int = 0
}
