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

    @Test("receive add: appends an empty search key, resets selected row, presents, sends editLastRow")
    func add() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        subject.state.selectedRow = 10
        await subject.receive(.add)
        #expect(subject.state.keys.count == 2)
        #expect(subject.state.keys[1] == SearchKey(key: "", title: "", blurb: ""))
        #expect(subject.state.selectedRow == -1)
        #expect(presenter.statesPresented == [subject.state])
        #expect(presenter.thingsReceived == [.editLastRow])
    }

    @Test("receive blurb: updates blurb for selected row, sends blurb")
    func blurb() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        subject.state.selectedRow = 0
        await subject.receive(.blurb("howdy"))
        #expect(subject.state.keys[0].blurb == "howdy")
        #expect(presenter.thingsReceived == [.blurb("howdy")])
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

    @Test("receive delete: deletes the given row in the state, resets selection, presents")
    func delete() async {
        let key1 = SearchKey(key: "key", title: "title", blurb: "blurb")
        let key2 = SearchKey(key: "key2", title: "title2", blurb: "blurb2")
        subject.state.keys = [key1, key2]
        subject.state.selectedRow = 0
        await subject.receive(.delete(1))
        #expect(subject.state.keys == [key1])
        #expect(subject.state.selectedRow == -1)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive initialData: presents")
    func initialData() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive selectedRow: sets selection in state, presents")
    func selectedRow() async {
        await subject.receive(.selectedRow(42))
        #expect(subject.state.selectedRow == 42)
        #expect(presenter.statesPresented == [subject.state])
    }
}
