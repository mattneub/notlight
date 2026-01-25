import Testing
@testable import NotLight3

private struct SearchKeyTests {
    @Test("update updates the correct property")
    func update() {
        do {
            var subject = SearchKey(key: "key", title: "title", blurb: "blurb")
            subject.update("howdy", forColumn: 0)
            #expect(subject == SearchKey(key: "key", title: "howdy", blurb: "blurb"))
        }
        do {
            var subject = SearchKey(key: "key", title: "title", blurb: "blurb")
            subject.update("howdy", forColumn: 1)
            #expect(subject == SearchKey(key: "howdy", title: "title", blurb: "blurb"))
        }
        do {
            var subject = SearchKey(key: "key", title: "title", blurb: "blurb")
            subject.update("howdy", forColumn: 2)
            #expect(subject == SearchKey(key: "key", title: "title", blurb: "howdy"))
        }
    }

    @Test("equality behaves correctly")
    func equality() {
        let subject1 = SearchKey(key: "key", title: "title", blurb: "blurb")
        let subject2 = SearchKey(key: "key", title: "title", blurb: "blurb")
        #expect(subject1.id != subject2.id)
        #expect(subject1 == subject2)
        var subject3 = subject1
        subject3.title = "yoho"
        #expect(subject1.id == subject3.id)
        #expect(subject1 != subject3)
    }
}
