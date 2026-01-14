import Testing
@testable import NotLight3
import Foundation

private struct ResultsProcessorTests {
    let subject = ResultsProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, ResultsState>()
    let workspace = MockWorkspace()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        services.workspace = workspace
    }

    @Test("receive close: calls coordinator dismiss()")
    func close() async {
        await subject.receive(.close)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("receive initialData: presents state")
    func initialData() async {
        subject.state.results = [.init(displayName: "name", path: "path")]
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive revealItems: calls workspace activate with urls for paths")
    func revealItems() async {
        subject.state.results = [
            .init(displayName: "name1", path: "/container1/path1"),
            .init(displayName: "name2", path: "/container2/path2"),
        ]
        let indexSet = IndexSet([0])
        await subject.receive(.revealItems(forRows: indexSet))
        #expect(workspace.methodsCalled == ["activateFileViewerSelecting(_:)"])
        #expect(workspace.urls == [URL(string: "file:///container1/path1")])
    }

    @Test("receive selectedRow: sets state selectedPath, presents")
    func selectedRow() async {
        subject.state.results = [.init(displayName: "name", path: "path")]
        await subject.receive(.selectedRow(0))
        #expect(subject.state.selectedPath == "path")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("updateResults: sorts results according to sort descriptor, presents")
    func updateResults() async {
        let result1 = SearchResult(displayName: "harpo", path: "/container1/path1")
        let result2 = SearchResult(displayName: "groucho", path: "/container2/path2")
        subject.state.results = [result1, result2]
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: true)
        await subject.receive(.updateResults([sortDescriptor]))
        #expect(subject.state.results.map(\.displayName) == ["groucho", "harpo"])
        #expect(presenter.statesPresented == [subject.state])
    }
}
