import Testing
@testable import NotLight3
import AppKit

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

    @Test("contextual menu: is correctly set up")
    func contextualMenu() {
        #expect(subject.contextualMenu.delegate === subject)
    }

    @Test("viewDidLoad: sets things up, sends processor initialData")
    func viewDidLoad() {
        subject.loadViewIfNeeded()
        #expect(subject.itemsFoundLabel?.stringValue == "")
        #expect(subject.itemsFoundLabel?.maximumNumberOfLines == 1)
        #expect(subject.queryStringLabel?.stringValue == "")
        #expect(subject.pathLabel?.stringValue == "")
        #expect(subject.pathLabel?.maximumNumberOfLines == 2)
        #expect(subject.tableView.doubleAction == #selector(subject.doDoubleAction))
        #expect(subject.tableView.menu === subject.contextualMenu)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewWillAppear: sets window's minSize")
    func viewWillAppear() {
        let window = makeWindow(viewController: subject)
        #expect(window.minSize == CGSize(width: 800, height: 360))
        #expect(window.frameAutosaveName == "NotLight_Results_Window")
    }

    @Test("viewWillDisappear: gathers table column info, sends tableColumns to processor")
    func viewWillDisappear() {
        subject.loadViewIfNeeded()
        subject.tableView.tableColumn(withIdentifier: .init("icon"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("displayName"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("size"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("date"))?.isHidden = true
        subject.tableView.tableColumn(withIdentifier: .init("path"))?.width = 250
        subject.viewWillDisappear()
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
        #expect(processor.thingsReceived.last == .requestColumnWidths(["displayName", "path"]))
        await subject.present(state)
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived.filter { $0 == .requestColumnWidths(["displayName", "path"]) }.count == 1)
    }

    @Test("doClose: sends processor close")
    func close() {
        subject.doClose(subject)
        #expect(processor.thingsReceived == [.close])
    }

    @Test("doDoubleAction: sends table selected row to revealItem")
    func doDoubleAction() {
        let tableView = MockTableView()
        tableView._selectedRow = 0
        subject.doDoubleAction(tableView)
        #expect(processor.thingsReceived == [.revealItem(forRow: 0)])
    }

    @Test("doDoubleAction: if table clicked row is -1, does nothing")
    func doDoubleActionNoRow() async {
        let tableView = MockTableView()
        tableView._clickedRow = -1
        subject.doDoubleAction(tableView)
        try? await Task.sleep(for: .seconds(0.1))
        #expect(processor.thingsReceived.isEmpty)
    }

    @Test("validateUserInterfaceItem: for copy and revealInFinder, depends on table selection count")
    func validate() {
        let tableView = MockTableView()
        tableView._selectedRowIndexes = []
        subject.tableView = tableView
        let item1 = NSMenuItem(title: "dummy", action: #selector(subject.copy(_:)), keyEquivalent: "")
        var result = subject.validateUserInterfaceItem(item1)
        #expect(result == false)
        let item2 = NSMenuItem(title: "dummy", action: #selector(subject.revealInFinder(_:)), keyEquivalent: "")
        result = subject.validateUserInterfaceItem(item2)
        #expect(result == false)
        tableView._selectedRowIndexes = [1]
        result = subject.validateUserInterfaceItem(item1)
        #expect(result == true)
        result = subject.validateUserInterfaceItem(item2)
        #expect(result == true)
    }

    @Test("copy: sends copy with selected row indexes and whether menu title contains Display Name")
    func copy() {
        let tableView = MockTableView()
        subject.tableView = tableView
        let item = NSMenuItem(title: "dummy", action: #selector(subject.copy(_:)), keyEquivalent: "")
        subject.copy(item)
        #expect(processor.thingsReceived == [.copy([0, 1, 2], false)])
        processor.thingsReceived = []
        item.title = "The Display Name Please"
        subject.copy(item)
        #expect(processor.thingsReceived == [.copy([0, 1, 2], true)])
    }

    @Test("revealInFinder: sends revealItem for table view selected row")
    func revealInFinder() {
        let tableView = MockTableView()
        tableView._selectedRow = 42
        subject.tableView = tableView
        let item = NSMenuItem(title: "dummy", action: #selector(subject.revealInFinder(_:)), keyEquivalent: "")
        subject.revealInFinder(item)
        #expect(processor.thingsReceived == [.revealItem(forRow: 42)])
    }

    @Test("menuNeedsUpdate: empties the table view menu and constructs it unless clickedRow or selectedRow is -1")
    func menuNeedsUpdate() {
        let tableView = MockTableView()
        tableView._clickedRow = 42
        tableView._selectedRow = 42
        subject.tableView = tableView
        let menu = NSMenu()
        subject.menuNeedsUpdate(menu)
        #expect(menu.items.count == 3)
        let item1 = menu.item(at: 0)!
        #expect(item1.title == "Copy Paths")
        #expect(item1.action == #selector(subject.copy(_:)))
        let item2 = menu.item(at: 1)!
        #expect(item2.title == "Copy Display Names")
        #expect(item2.action == #selector(subject.copy(_:)))
        let item3 = menu.item(at: 2)!
        #expect(item3.title == "Reveal In Finder")
        #expect(item3.action == #selector(subject.revealInFinder(_:)))
        //
        tableView._clickedRow = -1
        tableView._selectedRow = 42
        subject.menuNeedsUpdate(menu)
        #expect(menu.items.count == 0)
        //
        tableView._clickedRow = 42
        tableView._selectedRow = -1
        subject.menuNeedsUpdate(menu)
        #expect(menu.items.count == 0)
    }
}

private final class MockTableView: NSTableView {
    var _clickedRow = 0
    var _selectedRowIndexes: IndexSet = [0, 1, 2]
    var _selectedRow: Int = -1
    override var clickedRow: Int { _clickedRow }
    override var selectedRow: Int { _selectedRow }
    override var selectedRowIndexes: IndexSet { _selectedRowIndexes }
}
