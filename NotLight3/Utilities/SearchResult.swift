struct SearchResult: Equatable {
    let id = UUID()
    let displayName: String
    let path: String
}

/// Objective-C compatible version of SearchResult, so we can sort the data using the
/// sort descriptor provided by the table view.
@objcMembers
class SortableSearchResult: NSObject {
    let id: UUID
    let displayName: String
    let path: String
    nonisolated init(searchResult: SearchResult) {
        self.id = searchResult.id
        self.displayName = searchResult.displayName
        self.path = searchResult.path
    }
}

/// Convert back from SortableSearchResult class instance to normal SearchResult struct instance.
extension SearchResult {
    nonisolated init(sortableSearchResult: SortableSearchResult) {
        self.displayName = sortableSearchResult.displayName
        self.path = sortableSearchResult.path
    }
}
