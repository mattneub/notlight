import Testing
@testable import NotLight3

private struct SearchKeyTests {
    @Test("update updates the correct property")
    func update() {
        var subject = SearchKey(key: "key", title: "title", blurb: "blurb")
        subject.update("howdy", forColumn: 0)
        #expect(subject.title == "howdy")
        #expect(subject.key == "key")
        #expect(subject.blurb == "blurb")
        subject.update("howdy", forColumn: 1)
        #expect(subject.title == "howdy")
        #expect(subject.key == "howdy")
        #expect(subject.blurb == "blurb")
        subject.update("howdy", forColumn: 2)
        #expect(subject.title == "howdy")
        #expect(subject.key == "howdy")
        #expect(subject.blurb == "howdy")
    }
}
