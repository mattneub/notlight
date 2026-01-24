@testable import NotLight3
import Testing
import AppKit
import WaitWhile

private struct SearchKeysDatasourceTests {
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

    @Test("rows are correctly constructed")
    func rows() async throws {
        let key = SearchKey(key: "key", title: "title", blurb: "blurb")
        await subject.present(SearchKeysState(keys: [key]))
        await #while(tableView.numberOfRows < 1)
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
            #expect(view.textField?.maximumNumberOfLines == 1)
        }
    }
}

/// Ersatz view controller used to dumpster-dive the Results nib.
private final class MyViewController: NSViewController {
    override var nibName: String? { get {"SearchKeys"} set {}}
    @IBOutlet var tableView: NSTableView!
    @IBAction func doAdd(_: AnyObject) {}
    @IBAction func doDelete(_: AnyObject) {}
}
