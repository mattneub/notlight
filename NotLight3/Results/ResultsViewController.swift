import AppKit

class ResultsViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<ResultsAction>)?

    override var nibName: String { "Results" }

    @IBOutlet weak var tableView: NSTableView!

    lazy var datasource: (any ResultsDatasourceType<Void, ResultsState>) = ResultsDatasource(tableView: tableView, processor: processor)

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        view.window?.minSize = CGSize(width: 1000, height: 500)
    }

    func present(_ state: ResultsState) async {
        await datasource.present(state)
    }

    @IBAction func doClose(_ sender: Any) {
        Task {
            await processor?.receive(.close)
        }
    }
}
