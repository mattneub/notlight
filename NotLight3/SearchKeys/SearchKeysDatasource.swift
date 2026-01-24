import AppKit

/// Table view data source and delegate for the view controller's table view.
final class SearchKeysDatasource: NSObject, @MainActor TableViewDatasourceType {
    typealias State = SearchKeysState
    typealias Received = SearchKeysEffect

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<SearchKeysAction>)?

    /// Weak reference to the table view.
    weak var tableView: NSTableView?

    init(tableView: NSTableView, processor: (any Receiver<SearchKeysAction>)?) {
        self.tableView = tableView
        self.processor = processor
        super.init()
        datasource = createDataSource(tableView: tableView)
        tableView.dataSource = datasource
        tableView.delegate = self
    }

    /// Type alias for the type of the data source, for convenience.
    typealias DatasourceType = NSTableViewDiffableDataSource<String, UUID>

    /// Retain the diffable data source.
    var datasource: DatasourceType!

    func createDataSource(tableView: NSTableView) -> DatasourceType {
        let datasource = DatasourceType.init(
            tableView: tableView
        ) { [unowned self] tableView, tableColumn, row, identifier in
            viewProvider(tableView, tableColumn, row, identifier)
        }
        datasource.rowViewProvider = { _, _, _ in
            return MyRowView()
        }
        return datasource
    }

    var data = [SearchKey]()

    func present(_ state: SearchKeysState) async {
        configureData(state)
    }

    func receive(_ effect: SearchKeysEffect) async {
        switch effect {
        case .changed(let row, let column, let text):
            data[row].update(text, forColumn: column)
        case .delete(let row):
            data.remove(at: row)
            updateTableView()
        case .editLastRow:
            let lastRow = data.count - 1
            tableView?.editColumn(0, row: lastRow, with: nil, select: true)
        }
    }

    func configureData(_ state: SearchKeysState) {
        let fakeId = UUID()
        var stateKeys = state.keys
        var selfData = self.data
        stateKeys.modifyEach {
            $0.id = fakeId
        }
        selfData.modifyEach {
            $0.id = fakeId
        }
        if stateKeys == selfData {
            return // no point doing anything, it's the same data
        }
        self.data = state.keys
        updateTableView()
    }

    func updateTableView() {
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["dummy"])
        snapshot.appendItems(data.map { $0.id })
        datasource.apply(snapshot, animatingDifferences: false)
    }

    func viewProvider(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: UUID) -> NSView {
        let view = tableView.makeView(withIdentifier: tableColumn.identifier, owner: tableView) as? NSTableCellView
        let searchKey = data[row]
        switch tableColumn.identifier.rawValue {
        case "title":
            view?.textField?.stringValue = searchKey.title
        case "key":
            view?.textField?.stringValue = searchKey.key
        case "blurb":
            view?.textField?.stringValue = searchKey.blurb
        default: break
        }
        view?.textField?.action = Selector(("didEndEditing:"))
        view?.textField?.maximumNumberOfLines = 1
        return view ?? NSView()
    }
}

extension SearchKeysDatasource { // table view delegate methods
    func tableViewSelectionDidChange(_ notification: Notification) {
        Task {
            // await processor?.receive(.selectedRow(tableView?.selectedRow ?? -1))
        }
    }
}

