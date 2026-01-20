import AppKit

/// Protocol describing the view controller's interaction with the datasource, so we can
/// mock it for testing.
protocol ResultsDatasourceType<Received, State>: ReceiverPresenter, NSTableViewDelegate {
    associatedtype State
    associatedtype Received
}

/// Table view data source and delegate for the view controller's table view.
final class ResultsDatasource: NSObject, @MainActor ResultsDatasourceType {
    typealias State = ResultsState
    typealias Received = Void

    /// Processor to whom we can send action messages.
    weak var processor: (any Receiver<ResultsAction>)?

    /// Weak reference to the table view.
    weak var tableView: NSTableView?

    init(tableView: NSTableView, processor: (any Receiver<ResultsAction>)?) {
        self.tableView = tableView
        self.processor = processor
        super.init()
        datasource = createDataSource(tableView: tableView)
        tableView.dataSource = datasource
        tableView.delegate = self
    }

    /// Type alias for the type of the data source, for convenience.
    typealias DatasourceType = SortableDiffableDataSource

    /// Retain the diffable data source.
    var datasource: DatasourceType!

    func createDataSource(tableView: NSTableView) -> DatasourceType {
        let datasource = DatasourceType.init(
            tableView: tableView
        ) { [unowned self] tableView, tableColumn, row, identifier in
            viewProvider(tableView, tableColumn, row, identifier)
        }
        datasource.processor = processor
        return datasource
    }

    var data = [SearchResult]()

    func present(_ state: ResultsState) async {
        configureData(state)
    }

    func configureData(_ state: ResultsState) {
        let data = state.results
        if data == self.data {
            return // nothing to do, don't update the table unnecessarily
        }
        self.data = data
        var snapshot = datasource.snapshot()
        snapshot.deleteAllItems()
        snapshot.appendSections(["dummy"])
        snapshot.appendItems(data.map(\.id))
        datasource.apply(snapshot, animatingDifferences: false)
    }

    func viewProvider(_ tableView: NSTableView, _ tableColumn: NSTableColumn, _ row: Int, _ identifier: UUID) -> NSView {
        let view = tableView.makeView(withIdentifier: tableColumn.identifier, owner: tableView) as? NSTableCellView
        let result = data[row]
        switch tableColumn.identifier.rawValue {
        case "icon":
            view?.imageView?.image = result.image
        case "displayName":
            view?.textField?.stringValue = result.displayName
        case "path":
            view?.textField?.stringValue = result.path
        case "date":
            view?.textField?.stringValue = result.date?.formatted(date: .numeric, time: .shortened) ?? ""
        case "size":
            guard let size = result.size, size != 0 else { // we don't want any zeros
                view?.textField?.stringValue = ""
                break
            }
            guard size >= 1024 else { // we don't want any individual bytes either
                view?.textField?.stringValue = "1 KB"
                break
            }
            view?.textField?.stringValue = size.formatted(.byteCount(style: .file)).uppercased()
        default: break
        }
        return view ?? NSView()
    }
}

extension ResultsDatasource { // table view delegate methods
    func tableViewSelectionDidChange(_ notification: Notification) {
        Task {
            await processor?.receive(.selectedRow(tableView?.selectedRow ?? -1))
        }
    }
}

final class SortableDiffableDataSource: NSTableViewDiffableDataSource<String, UUID> {
    weak var processor: (any Receiver<ResultsAction>)?

    /// We have to implement this to prevent the compiler throwing a wobbly.
    nonisolated
    override init(tableView: NSTableView, cellProvider: @escaping NSTableViewDiffableDataSource<String, UUID>.CellProvider) {
        super.init(tableView: tableView, cellProvider: cellProvider)
    }

    /// NSTableViewDataSource optional method.
    @objc func tableView(_ tableView: NSTableView, sortDescriptorsDidChange _: [NSSortDescriptor]) {
        Task {
            await processor?.receive(.updateResults(tableView.sortDescriptors))
        }
    }
}
