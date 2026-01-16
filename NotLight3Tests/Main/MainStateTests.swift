import Testing
@testable import NotLight3

private struct MainStateTests {
    @Test("searchType behaves correctly")
    func searchType() {
        var subject = MainState()
        subject.searchTypePopupContents = [["hey": "ho"], ["hoo": "ha"]]
        subject.searchTypePopupCurrentItemIndex = 0
        #expect(subject.searchType == ["hey": "ho"])
        subject.searchTypePopupCurrentItemIndex = 1
        #expect(subject.searchType == ["hoo": "ha"])
        subject.searchTypePopupCurrentItemIndex = 2
        #expect(subject.searchType == ["key": "value"])
    }
}
