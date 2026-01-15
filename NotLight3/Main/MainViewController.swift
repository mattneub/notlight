import AppKit

class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    override var nibName: String { "Main" }

    @IBOutlet var progressSpinner: NSProgressIndicator!

    @IBOutlet var progressLabel: NSTextField! {
        didSet {
            progressLabel?.stringValue = "" // Prevent user seeing value from nib.
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func present(_ state: MainState) async {
        if state.progress > 0 {
            progressLabel.stringValue = "\(String(state.progress)) results found..."
            progressSpinner.startAnimation(self)
        } else {
            progressLabel.stringValue = ""
            progressSpinner.stopAnimation(self)
        }
    }

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.returnInSearchField(sender.stringValue))
        }
    }
}

