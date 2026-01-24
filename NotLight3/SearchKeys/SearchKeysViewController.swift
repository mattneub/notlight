import AppKit

final class SearchKeysViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<SearchKeysAction>)?

    override var nibName: String { "SearchKeys" }

    @IBOutlet weak var tableView: NSTableView!

    lazy var datasource: (any SearchKeysDatasourceType<Void, SearchKeysState>) = SearchKeysDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    func present(_ state: SearchKeysState) async {
        await datasource.present(state)
    }
}
