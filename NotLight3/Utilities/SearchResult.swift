import AppKit

struct SearchResult: Equatable {
    let id = UUID()
    var image: NSImage?
    let displayName: String
    let path: String
    let date: Date?
    let size: Int64?

    mutating func updateImage(_ newImage: NSImage?) {
        newImage?.size = CGSize(width: 16, height: 16)
        self.image = newImage
    }
}

/// Objective-C compatible version of SearchResult, so we can sort the data using the
/// sort descriptor provided by the table view; it is a class, it is an NSObject, and
/// its members are marked `@objc` so Objective-C can see them. We don't want SearchResult
/// _itself_ to be anything but a struct, so we just convert back and forth when sorting.
@objcMembers
class SortableSearchResult: NSObject {
    let id: UUID
    let image: NSImage?
    let displayName: String
    let path: String
    let date: Date?
    let size: Int64 // for some reason, an Optional doesn't work for sorting here
    nonisolated init(searchResult: SearchResult) {
        self.id = searchResult.id
        self.image = searchResult.image
        self.displayName = searchResult.displayName
        self.path = searchResult.path
        self.date = searchResult.date
        self.size = searchResult.size ?? 0
    }
}

/// Convert back from SortableSearchResult class instance to normal SearchResult struct instance.
extension SearchResult {
    nonisolated init(sortableSearchResult: SortableSearchResult) {
        self.image = sortableSearchResult.image
        self.displayName = sortableSearchResult.displayName
        self.path = sortableSearchResult.path
        self.date = sortableSearchResult.date
        self.size = sortableSearchResult.size
    }
}
