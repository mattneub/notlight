import Testing
@testable import NotLight3
import AppKit

private struct SearchKeysProcessorTests {
    let subject = SearchKeysProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<SearchKeysEffect, SearchKeysState>()
    
    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
    }

    @Test("receive add: appends an empty search key, presents, sends editLastRow")
    func add() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        await subject.receive(.add)
        #expect(subject.state.keys.count == 2)
        #expect(subject.state.keys[1].key == "")
        #expect(subject.state.keys[1].title == "")
        #expect(subject.state.keys[1].blurb == "")
        #expect(presenter.statesPresented == [subject.state])
        #expect(presenter.thingsReceived == [.editLastRow])
    }

    @Test("receive changed: updates the relevant property of the given row in the state, sends changed")
    func changed() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        subject.state.keys = [key]
        await subject.receive(.changed(row: 0, column: 2, text: "howdy"))
        var expected = key
        expected.blurb = "howdy"
        #expect(subject.state.keys == [expected])
        #expect(presenter.thingsReceived == [.changed(row: 0, column: 2, text: "howdy")])
    }

    @Test("receive delete: deletes the given row in the state, sends delete")
    func delete() async {
        let key1 = SearchKey(key: "key", title: "title", blurb: "blurb")
        let key2 = SearchKey(key: "key2", title: "title2", blurb: "blurb2")
        subject.state.keys = [key1, key2]
        await subject.receive(.delete(1))
        #expect(subject.state.keys == [key1])
        #expect(presenter.thingsReceived == [.delete(1)])
    }

    @Test("receive initialData: presents")
    func initialData() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }
}
