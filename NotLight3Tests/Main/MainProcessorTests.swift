import Testing
@testable import NotLight3
import Foundation

private struct MainProcessorTests {
    let subject = MainProcessor()
    let searcher = MockSearcher()

    init() {
        services.searcher = searcher
    }

    @Test("receive returnInSearchField: calls searcher doSearch")
    func returnInSearchField() async {
        await subject.receive(.returnInSearchField("howdy"))
        #expect(searcher.methodsCalled == ["doSearch(_:)"])
        #expect(searcher.term == "howdy")
    }
}
