import AppKit

class ResultsViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<ResultsAction>)?

    override var nibName: String { "Results" }

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var itemsFoundLabel: NSTextField! {
        didSet {
            itemsFoundLabel?.stringValue = "" // prevent nib value from appearing
            itemsFoundLabel?.maximumNumberOfLines = 1 // no place to set this in xib?
        }
    }

    @IBOutlet weak var queryStringLabel: NSTextField! {
        didSet {
            queryStringLabel?.stringValue = "" // prevent nib value from appearing
        }
    }

    @IBOutlet weak var pathLabel: NSTextField! {
        didSet {
            pathLabel?.stringValue = "" // prevent nib value from appearing
            pathLabel?.maximumNumberOfLines = 2 // no place to set this in xib?
        }
    }

    lazy var datasource: (any ResultsDatasourceType<Void, ResultsState>) = ResultsDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.doubleAction = #selector(doDoubleAction) // target is found via nil-targeting
        Task {
            await processor?.receive(.initialData)
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.minSize = CGSize(width: 1000, height: 500)
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        let visibleColumns = tableView.tableColumns.filter { !$0.isHidden }.map { $0.identifier }
        let array = visibleColumns.reduce(into: [ColumnWidth]()) { array, column in
            array.append(.init(
                name: column.rawValue,
                width: tableView.tableColumn(withIdentifier: column)?.width ?? 100
            ))
        }
        Task {
            await processor?.receive(.columnWidths(array))
        }
    }

    func present(_ state: ResultsState) async {
        configureItemsFoundLabel(state)
        queryStringLabel.stringValue = state.queryString
        pathLabel.stringValue = state.selectedPath
        for (key, value) in state.columnVisibility {
            tableView.tableColumn(withIdentifier: .init(key))?.isHidden = !value
        }
        await ensureColumnWidths()
        await datasource.present(state)
    }

    func receive(_ effect: ResultsEffect) async {
        switch effect {
        case .columnWidths(let columns):
            for column in columns {
                tableView.tableColumn(withIdentifier: .init(column.name))?.width = column.width
            }
        }
    }

    /// Flag so that we send `requestColumnWidths` only once.
    var requestedWidths = false

    func ensureColumnWidths() async {
        guard !requestedWidths else { return }
        requestedWidths = true
        let visibleColumns = tableView.tableColumns.filter { !$0.isHidden }.map { $0.identifier }
        let array = visibleColumns.reduce(into: [String]()) { array, column in
            array.append(column.rawValue)
        }
        await processor?.receive(.requestColumnWidths(array))
    }

    @IBAction func doClose(_ sender: Any) {
        Task {
            await processor?.receive(.close)
        }
    }

    func configureItemsFoundLabel(_ state: ResultsState) {
        itemsFoundLabel.stringValue = String(
            AttributedString(
                localized: "^[\(state.results.count) \("item")](inflect: true) found:"
            ).characters
        )
    }

    @objc func doDoubleAction(_ sender: NSTableView) {
        let row = sender.clickedRow
        guard row != -1 else { // e.g. maybe user double clicked a column header
            return
        }
        let selectedRows = sender.selectedRowIndexes
        Task {
            await processor?.receive(.revealItems(forRows: selectedRows))
        }
    }
}
