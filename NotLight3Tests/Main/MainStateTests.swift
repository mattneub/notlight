import Testing
@testable import NotLight3

private struct MainStateTests {
    @Test("currentKey behaves correctly")
    func searchType() {
        var subject = MainState()
        subject.keyPopupContents = [["hey": "ho"], ["hoo": "ha"]]
        subject.keyPopupIndex = 0
        #expect(subject.currentKey == ["hey": "ho"])
        subject.keyPopupIndex = 1
        #expect(subject.currentKey == ["hoo": "ha"])
        subject.keyPopupIndex = 2
        #expect(subject.currentKey == ["key": "value"])
    }
}
