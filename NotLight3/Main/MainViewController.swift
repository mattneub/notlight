import AppKit

class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    override var nibName: String { "Main" }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func present(_ state: MainState) async {}

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.returnInSearchField(sender.stringValue))
        }
    }
}

