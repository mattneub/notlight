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

    @IBOutlet var stopButton: NSButton! {
        didSet {
            stopButton.isEnabled = false
        }
    }

    @IBOutlet var wordBasedCheckbox: NSButton!
    @IBOutlet var caseInsensitiveCheckbox: NSButton!
    @IBOutlet var diacriticInsensitiveCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialState)
        }
    }

    func present(_ state: MainState) async {
        wordBasedCheckbox.state = state.wordBased ? .on : .off
        caseInsensitiveCheckbox.state = state.caseInsensitive ? .on : .off
        diacriticInsensitiveCheckbox.state = state.diacriticInsensitive ? .on : .off

        if state.progress > 0 {
            progressLabel.stringValue = "\(String(state.progress)) results found..."
            progressSpinner.startAnimation(self)
            stopButton.isEnabled = true
        } else {
            progressLabel.stringValue = ""
            progressSpinner.stopAnimation(self)
            stopButton.isEnabled = false
        }
    }

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.returnInSearchField(sender.stringValue))
        }
    }

    @IBAction func doStop(_ sender: NSButton) {
        Task {
            await processor?.receive(.stop)
        }
    }

    @IBAction func doCaseInsensitive(_ sender: NSButton) {
        Task {
            await processor?.receive(.caseInsensitive(sender.state == .on))
        }
    }

    @IBAction func doDiacriticInsensitive(_ sender: NSButton) {
        Task {
            await processor?.receive(.diacriticInsensitive(sender.state == .on))
        }
    }

    @IBAction func doWordBased(_ sender: NSButton) {
        Task {
            await processor?.receive(.wordBased(sender.state == .on))
        }
    }
}

