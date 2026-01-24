import Testing
@testable import NotLight3

private struct MainStateTests {
    @Test("currentKey behaves correctly")
    func searchType() {
        var subject = MainState()
        let key1 = SearchKey(key: "1", title: "1", blurb: "1")
        let key2 = SearchKey(key: "2", title: "2", blurb: "2")
        subject.keyPopupContents = [key1, key2]
        subject.keyPopupIndex = 0
        #expect(subject.currentKey == key1)
        subject.keyPopupIndex = 1
        #expect(subject.currentKey == key2)
        subject.keyPopupIndex = 2
        #expect(subject.currentKey == key1)
    }
}
