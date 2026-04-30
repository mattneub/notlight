@testable import NotLight3
import Testing
import AppKit

private struct SearchKeysDatasourceTests: ~Copyable {
    let subject: SearchKeysDatasource!
    let processor = MockReceiver<SearchKeysAction>()
    let tableView: NSTableView!

    init() {
        // Dumpster-dive the SearchKeys nib to get the table view that is configured there.
        let viewController = MyViewController()
        viewController.loadViewIfNeeded()
        tableView = viewController.tableView
        subject = SearchKeysDatasource(tableView: tableView, processor: processor)
    }

    deinit {
        closeWindows()
    }

    @Test("Initialization: creates and configures the data source, configures the table view")
    func initialize() throws {
        let datasource = try #require(subject.datasource)
        #expect(tableView.dataSource === datasource)
        #expect(tableView.delegate === subject)
    }

    @Test("present: configures the contents of the data source")
    func present() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        await subject.present(SearchKeysState(keys: [key]))
        #expect(subject.data == [key])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == [key.id])
    }

    @Test("present: if keys are effectively the same, does not change the data or the datasource")
    func presentSameData() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        await subject.present(SearchKeysState(keys: [key]))
        let key2 = SearchKey(key: "key", title: "title", blurb: "blurb")
        await subject.present(SearchKeysState(keys: [key2]))
        #expect(subject.data == [key])
        let snapshot = subject.datasource.snapshot()
        #expect(snapshot.sectionIdentifiers == ["dummy"])
        #expect(snapshot.itemIdentifiers(inSection: "dummy") == [key.id])
    }

    @Test("present: selects table row")
    func presentTableRow() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        var state = SearchKeysState(keys: [key])
        await subject.present(state)
        #expect(tableView.selectedRow == -1)
        state.selectedRow = 0
        await subject.present(state)
        #expect(tableView.selectedRow == 0)
    }

    @Test("receive blurb: updates the data and table view while keeping the selection")
    func receiveBlurb() async throws {
        makeWindow(view: tableView)
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        let state = SearchKeysState(keys: [key], selectedRow: 0)
        await subject.present(state)
        #expect(tableView.selectedRow == 0)
        do {
            let view = try #require(tableView.view(atColumn: 2, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "blurb")
        }
        await subject.receive(.blurb("howdy"))
        #expect(subject.data[0].blurb == "howdy")
        #expect(tableView.selectedRow == 0)
        do {
            let view = try #require(tableView.view(atColumn: 2, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "howdy")
        }
    }

    @Test("receive changed: updates the data")
    func receiveChanged() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        let state = SearchKeysState(keys: [key])
        await subject.present(state)
        await subject.receive(.changed(row: 0, column: 0, text: "howdy"))
        #expect(subject.data[0] == SearchKey(key: "key", title: "howdy", blurb: "blurb"))
    }

    @Test("receive editLastRow: edits the first column of the last row")
    func editLastRow() async throws {
        makeWindow(view: tableView)
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        let state = SearchKeysState(keys: [key])
        await subject.present(state)
        await subject.receive(.editLastRow)
        let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
        let field = try #require(view.textField)
        #expect(field.currentEditor() != nil)
        #expect(field.currentEditor()?.selectedRange == .init(location: 0, length: 5))
    }

    @Test("rows are correctly constructed")
    func rows() async throws {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        await subject.present(SearchKeysState(keys: [key]))
        do {
            let view = try #require(tableView.view(atColumn: 0, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "title")
            #expect(view.textField?.action == #selector(SearchKeysViewController.didEndEditing(_:)))
            #expect(view.textField?.maximumNumberOfLines == 1)
        }
        do {
            let view = try #require(tableView.view(atColumn: 1, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "key")
            #expect(view.textField?.action == #selector(SearchKeysViewController.didEndEditing(_:)))
            #expect(view.textField?.maximumNumberOfLines == 1)
        }
        do {
            let view = try #require(tableView.view(atColumn: 2, row: 0, makeIfNecessary: false) as? NSTableCellView)
            #expect(view.textField?.stringValue == "blurb")
            #expect(view.textField?.maximumNumberOfLines == 1)
        }
    }

    @Test("selectionDidChange: sends selectedRow")
    func selectionDidChange() async {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        let state = SearchKeysState(keys: [key])
        await subject.present(state)
        tableView.selectRowIndexes([0], byExtendingSelection: false) // calls selectionDidChange!
        #expect(processor.thingsReceived == [.selectedRow(0)])
    }
}

/// Ersatz view controller used to dumpster-dive the Results nib.
private final class MyViewController: NSViewController {
    override var nibName: String? { get {"SearchKeys"} set {}}
    @IBOutlet var tableView: NSTableView!
    @IBOutlet var blurbField: NSTextField!
    @IBAction func doAdd(_: AnyObject) {}
    @IBAction func doDelete(_: AnyObject) {}
    @IBAction func doDone(_: AnyObject) {}
}
