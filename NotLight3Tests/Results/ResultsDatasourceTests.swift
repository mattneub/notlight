@testable import NotLight3
import Testing
import AppKit

private struct ResultsDatasourceTests {
    let subject: ResultsDatasource!
    let processor = MockReceiver<ResultsAction>()
    let tableView: NSTableView!

    init() {
        // Dumpster-dive the Results nib to get the table view that is configured there.
        let viewController = MyViewController()
        viewController.loadViewIfNeeded()
        tableView = viewController.tableView
        subject = ResultsDatasource(tableView: tableView, processor: processor)
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let result = SearchResult(displayName: "name", path: "path", date: .distantPast, size: 10)
        await subject.present(ResultsState(results: [result]))
        #expect(subject.data == [result])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == [result.id])
    }

    @Test("rows are correctly constructed")
    func rows() async throws {
        let image = NSImage(systemSymbolName: "1.calendar", accessibilityDescription: nil)!
        let result = SearchResult(image: image, displayName: "name", path: "path", date: .init(timeIntervalSince1970: 0), size: 1024)
        await subject.present(ResultsState(results: [result]))
        do {
            let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.imageView?.image == image)
        }
        do {
            let view = try #require(tableView.view(atColumn: 1, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "name")
        }
        do {
            let view = try #require(tableView.view(atColumn: 2, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "path")
        }
        do {
            let view = try #require(tableView.view(atColumn: 3, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "12/31/1969, 4:00 PM")
        }
        do {
            let view = try #require(tableView.view(atColumn: 4, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "1 KB")
        }
    }

    @Test("selectionChanged: sends selectedRow to processor")
    func selectionChanged() {
        let tableView = MockTableView()
        tableView._selectedRow = 3
        subject.tableView = tableView
        subject.tableViewSelectionDidChange(Notification(name: .init("dummy")))
        #expect(processor.thingsReceived == [.selectedRow(3)])
    }

    @Test("datasource sortDescriptorsDidChange: sends updateResults to processor")
    func sortDescriptorsDidChange() throws {
        let tableView = MockTableView()
        let sortDescriptor = NSSortDescriptor(key: "howdy", ascending: false)
        tableView._sortDescriptors = [sortDescriptor]
        let datasource = try #require(subject.datasource)
        let datasourceProcessor = try #require(datasource.processor)
        #expect(datasourceProcessor === processor)
        datasource.tableView(tableView, sortDescriptorsDidChange: [])
        #expect(processor.thingsReceived == [.updateResults([sortDescriptor])])
    }
}

/// Ersatz view controller used to dumpster-dive the Results nib.
private final class MyViewController: NSViewController {
    override var nibName: String? { get {"Results"} set {}}
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var itemsFoundLabel: NSTextField!
    @IBOutlet var queryStringLabel: NSTextField!
    @IBOutlet var pathLabel: NSTextField!
    @IBAction func doClose(_ sender: Any) {}
}

private final class MockTableView: NSTableView {
    var _selectedRow: Int = 0
    var _sortDescriptors: [NSSortDescriptor] = []
    override var selectedRow: Int { _selectedRow }
    override var sortDescriptors: [NSSortDescriptor] {
        get { _sortDescriptors }
        set {}
    }
}
