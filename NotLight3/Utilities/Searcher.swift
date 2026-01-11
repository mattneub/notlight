import AppKit

protocol SearcherType {
    func doSearch(_ term: String) async throws(SearcherError) -> [SearchResult]
}

final class Searcher: SearcherType {
    /// The query, held while we are performing it. This has two purposes: it keeps the query
    /// alive, and it maintains it in a place where multiple methods can access it, so we don't
    /// have to worry about the fact that an NSMetadataQuery is not Sendable.
    var query: NSMetadataQuery?

    /// Observer that notifies us that the query has finished.
    var finishedObserver: NotificationCenter.ObservationToken?

    /// Public method.
    func doSearch(_ term: String) async throws(SearcherError) -> [SearchResult] {
        let query = services.queryFactory.makeQuery()
        self.query = query
        let queryString = "kMDItemDisplayName == \"\(term)\"cdw" // NB! no space before modifiers!!!!!
        // unfortunately there's a long-standing bug: NSPredicate `init?(forMetadataQueryString)`
        // with a bad string does not gracefully return nil but raises an NSException
        // so we dry run the proposed string in the domain of our Objective-C exception catcher
        // and if it raises, we throw in good order
        do {
            try ExceptionCatcher.catchException {
                _ = NSPredicate(fromMetadataQueryString: queryString)
            }
        } catch {
            throw .badQuery
        }
        query.predicate = NSPredicate(fromMetadataQueryString: queryString)
        query.searchScopes = [NSMetadataQueryLocalComputerScope]
        query.start()
        let results = await withCheckedContinuation { continuation in
            finishedObserver = NotificationCenter.default.addObserver(
                of: query,
                for: NSMetadataQuery.DidFinishGatheringMessage.self
            ) { [unowned self] _ in
                continuation.resume(returning: await gatherResults())
            }
        }
        // clean up and we're out of here
        query.stop()
        if let finishedObserver {
            NotificationCenter.default.removeObserver(finishedObserver)
        }
        return results
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
            if let result = query.result(at: index) as? QueryItemType {
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
}

enum SearcherError: Error {
    case badQuery
}


