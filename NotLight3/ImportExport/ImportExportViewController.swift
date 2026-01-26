import AppKit

final class ImportExportViewController: NSViewController, ReceiverPresenter {

    weak var processor: (any Receiver<ImportExportAction>)?

    override var nibName: String { "ImportExport" }

    @IBOutlet weak var currentSearchLabel: NSTextField!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        view.window?.styleMask.remove(.resizable)
    }

    func present(_ state: ImportExportState) async {
        currentSearchLabel.stringValue = state.currentSearch
    }

    @IBAction func doLoadSearch(_: NSButton) {
        Task {
            await processor?.receive(.loadSearch)
        }
    }

    @IBAction func doSaveThisSearch(_: NSButton) {
        Task {
            await processor?.receive(.saveSearch)
        }
    }

    @IBAction func doDoThisSearch(_: NSButton) {
        Task {
            await processor?.receive(.doSearch)
        }
    }
}
