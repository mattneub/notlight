import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct ResultsViewControllerTests: ~Copyable {
    let subject = ResultsViewController()
    let processor = MockProcessor<ResultsAction, ResultsState, Void>()
    let datasource = MockResultsDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    deinit {
        closeWindows()
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Results")
    }

    @Test("initialization: sets up the datasource and table view")
    func initialization() throws {
        let subject = ResultsViewController()
        let processor = MockProcessor<ResultsAction, ResultsState, Void>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let datasource = try #require(subject.datasource as? ResultsDatasource)
        #expect(subject.tableView != nil)
        #expect(datasource.processor === subject.processor)
        #expect(datasource.tableView === subject.tableView)
    }

    @Test("viewDidLoad: sets things up, sends processor initialData")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        #expect(subject.itemsFoundLabel?.stringValue == "")
        #expect(subject.itemsFoundLabel?.maximumNumberOfLines == 1)
        #expect(subject.queryStringLabel?.stringValue == "")
        #expect(subject.pathLabel?.stringValue == "")
        #expect(subject.pathLabel?.maximumNumberOfLines == 2)
        #expect(subject.tableView.doubleAction == #selector(subject.doDoubleAction))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewWillAppear: sets window's minSize")
    func viewWillAppear() {
        let window = makeWindow(viewController: subject)
        #expect(window.minSize == CGSize(width: 800, height: 360))
        #expect(window.frameAutosaveName == "NotLight_Results_Window")
    }

    @Test("viewWillDisappear: gathers table column info, sends tableColumns to processor")
    func viewWillDisappear() async {
        subject.loadViewIfNeeded()
        subject.tableView.tableColumn(withIdentifier: .init("icon"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("displayName"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("size"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("date"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("path"))?.width = 250
        subject.viewWillDisappear()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .columnWidths([ColumnWidth(name: "path", width: 250)]))
    }

    @Test("present: presents to the datasource")
    func present() async {
        subject.loadViewIfNeeded()
        let state = ResultsState(results: [.init(displayName: "name", path: "path", date: .distantPast, size: 10)])
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.statePresented == state)
    }

    @Test("present: configures the items found label")
    func presentItemsFound() async {
        subject.loadViewIfNeeded()
        var state = ResultsState(results: [.init(displayName: "name", path: "path", date: .distantPast, size: 10)])
        await subject.present(state)
        #expect(subject.itemsFoundLabel.stringValue == "1 item found:")
        state = ResultsState(results: [
            .init(displayName: "name", path: "path", date: .distantPast, size: 10),
            .init(displayName: "name", path: "path", date: .distantPast, size: 10)
        ])
        await subject.present(state)
        #expect(subject.itemsFoundLabel.stringValue == "2 items found:")
    }

    @Test("present: configures the query string label")
    func presentQueryString() async {
        subject.loadViewIfNeeded()
        let state = ResultsState(queryString: "howdy")
        await subject.present(state)
        #expect(subject.queryStringLabel.stringValue == "howdy")
    }

    @Test("present: configures the path label")
    func presentPath() async {
        subject.loadViewIfNeeded()
        let state = ResultsState(selectedPath: "howdy")
        await subject.present(state)
        #expect(subject.pathLabel.stringValue == "howdy")
    }

    @Test("present: shows / hides table view columns")
    func presentColumns() async {
        subject.loadViewIfNeeded()
        let state = ResultsState(columnVisibility: ["icon": false, "size": true])
        await subject.present(state)
        #expect(subject.tableView.tableColumn(withIdentifier: .init("icon"))?.isHidden == true)
        #expect(subject.tableView.tableColumn(withIdentifier: .init("size"))?.isHidden == false)
    }

    @Test("present: asks for table column widths for visible columns, just once")
    func requestColumnWidths() async {
        subject.loadViewIfNeeded()
        let state = ResultsState(columnVisibility: ["icon": false, "size": false, "date": false])
        await subject.present(state)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.first == .requestColumnWidths(["displayName", "path"]))
        await subject.present(state)
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived.filter { $0 == .requestColumnWidths(["displayName", "path"]) }.count == 1)
    }

    @Test("doClose: sends processor close")
    func close() async {
        subject.doClose(subject)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.close])
    }

    @Test("doDoubleAction: sends table selected rows to revealItems")
    func doDoubleAction() async {
        let tableView = MockTableView()
        subject.doDoubleAction(tableView)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.revealItems(forRows: [0, 1, 2])])
    }

    @Test("doDoubleAction: if table clicked row is -1, does nothing")
    func doDoubleActionNoRow() async {
        let tableView = MockTableView()
        tableView._clickedRow = -1
        subject.doDoubleAction(tableView)
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived.isEmpty)
    }
}

private final class MockTableView: NSTableView {
    var _clickedRow = 0
    var _selectedRowIndexes: IndexSet = [0, 1, 2]
    override var clickedRow: Int { _clickedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
}
