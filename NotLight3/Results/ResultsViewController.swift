import AppKit

class ResultsViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<ResultsAction>)?

    override var nibName: String { "Results" }

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var itemsFoundLabel: NSTextField!

    lazy var datasource: (any ResultsDatasourceType<Void, ResultsState>) = ResultsDatasource(tableView: tableView, processor: processor)

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

    func present(_ state: ResultsState) async {
        configureItemsFoundLabel(state)
        await datasource.present(state)
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
