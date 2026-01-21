import Testing
@testable import NotLight3
import AppKit

private struct ResultsProcessorTests {
    let subject = ResultsProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<ResultsEffect, ResultsState>()
    let workspace = MockWorkspace()
    let persistence = MockPersistence()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        services.workspace = workspace
        services.persistence = persistence
    }

    @Test("receive close: calls coordinator dismiss()")
    func close() async {
        await subject.receive(.close)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("receive columnWidths: calls persistence saveColumns")
    func columnWidths() async {
        let columns = [ColumnWidth(name: "hey", width: 10)]
        await subject.receive(.columnWidths(columns))
        #expect(persistence.methodsCalled == ["saveColumns(_:)"])
        #expect(persistence.columnWidthsSaved == columns)
    }

    @Test("receive initialData: consults persistence, gets icons from workspace if needed, configures column visibility, presents")
    func initialDataPersistence() async {
        subject.state.results = [.init(displayName: "name", path: "path", date: .distantPast, size: 10)]
        let image = NSImage(systemSymbolName: "1.calendar", accessibilityDescription: nil)!
        workspace.imageToReturn = image
        persistence.boolToReturn = true // just say yes to everything
        await subject.receive(.initialData)
        #expect(persistence.methodsCalled == [
            "loadShowFileIcons()", "loadShowFileIcons()", "loadShowModDates()", "loadShowFileSizes()"
        ])
        #expect(workspace.methodsCalled == ["icon(forFile:)"])
        #expect(subject.state.results[0].image == image)
        #expect(subject.state.columnVisibility == ["icon": true, "date": true, "size": true])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive initialData: same as previous but this time persistence says no to everything")
    func initialDataPersistence2() async {
        subject.state.results = [.init(displayName: "name", path: "path", date: .distantPast, size: 10)]
        persistence.boolToReturn = false // just say no to everything
        await subject.receive(.initialData)
        #expect(persistence.methodsCalled == [
            "loadShowFileIcons()", "loadShowFileIcons()", "loadShowModDates()", "loadShowFileSizes()"
        ])
        #expect(workspace.methodsCalled.isEmpty)
        #expect(subject.state.results[0].image == nil)
        #expect(subject.state.columnVisibility == ["icon": false, "date": false, "size": false])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive requestColumnWidths: call persistence loadColumns, if not nil passes on to presenter")
    func requestColumnWidths() async {
        let columnWidths = [ColumnWidth(name: "hey", width: 10)]
        persistence.columnWidthsToReturn = columnWidths
        let columns = ["manny", "moe"]
        await subject.receive(.requestColumnWidths(columns))
        #expect(persistence.methodsCalled == ["loadColumns(_:)"])
        #expect(persistence.columns == columns)
        #expect(presenter.thingsReceived == [.columnWidths(columnWidths)])
    }

    @Test("receive requestColumnWidths: call persistence loadColumns, if nil does nothing")
    func requestColumnWidthsNil() async {
        persistence.columnWidthsToReturn = nil
        let columns = ["manny", "moe"]
        await subject.receive(.requestColumnWidths(columns))
        #expect(persistence.methodsCalled == ["loadColumns(_:)"])
        #expect(persistence.columns == columns)
        #expect(presenter.thingsReceived == [])
    }

    @Test("receive revealItems: calls workspace activate with urls for paths")
    func revealItems() async {
        subject.state.results = [
            .init(displayName: "name1", path: "/container1/path1", date: .distantPast, size: 10),
            .init(displayName: "name2", path: "/container2/path2", date: .distantPast, size: 10),
        ]
        let indexSet = IndexSet([0])
        await subject.receive(.revealItems(forRows: indexSet))
        #expect(workspace.methodsCalled == ["activateFileViewerSelecting(_:)"])
        #expect(workspace.urls == [URL(string: "file:///container1/path1")])
    }

    @Test("receive selectedRow: sets state selectedPath, presents")
    func selectedRow() async {
        subject.state.results = [.init(displayName: "name", path: "path", date: .distantPast, size: 10)]
        await subject.receive(.selectedRow(0))
        #expect(subject.state.selectedPath == "path")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("updateResults: sorts results according to sort descriptor, presents")
    func updateResults() async {
        let result1 = SearchResult(displayName: "harpo", path: "/container1/path1", date: .distantPast, size: 10)
        let result2 = SearchResult(displayName: "groucho", path: "/container2/path2", date: .distantPast, size: 10)
        subject.state.results = [result1, result2]
        let sortDescriptor = NSSortDescriptor(key: "displayName", ascending: true)
        await subject.receive(.updateResults([sortDescriptor]))
        #expect(subject.state.results.map(\.displayName) == ["groucho", "harpo"])
        #expect(presenter.statesPresented == [subject.state])
    }
}
