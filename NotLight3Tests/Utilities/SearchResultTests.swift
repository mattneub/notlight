import Testing
@testable import NotLight3
import AppKit

private struct SearchResultTests {
    @Test("SearchResults round-trips with SortableSearchResult, except for UUID")
    func sortable() {
        let image = NSImage(systemSymbolName: "1.calendar", accessibilityDescription: nil)
        let subject = SearchResult(image: image, displayName: "hey", path: "ho", date: .distantPast, size: 10)
        let sortableResult = SortableSearchResult(searchResult: subject)
        #expect(sortableResult.image == image)
        #expect(sortableResult.displayName == "hey")
        #expect(sortableResult.path == "ho")
        #expect(sortableResult.date == .distantPast)
        #expect(sortableResult.size == 10)
        let subject2 = SearchResult(sortableSearchResult: sortableResult)
        #expect(subject2.image == image)
        #expect(subject2.displayName == "hey")
        #expect(subject2.path == "ho")
        #expect(subject2.date == .distantPast)
        #expect(subject2.size == 10)
    }

    @Test("updateImage: updates image")
    func updateImage() {
        let image = NSImage(systemSymbolName: "1.calendar", accessibilityDescription: nil)
        var subject = SearchResult(image: nil, displayName: "hey", path: "ho", date: .distantPast, size: 10)
        subject.updateImage(image)
        #expect(subject.image == image)
        #expect(subject.image?.size == CGSize(width: 16, height: 16))
    }
}
