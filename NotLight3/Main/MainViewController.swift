import AppKit

class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    override var nibName: String { "Main" }

    /// This text field can have a formatter attached to it. This means that the field _displays_
    /// its `stringValue` but _contains_ its `objectValue`. Therefore it is crucial to communicate
    /// with the text field in terms of its `objectValue` and _not_ its `stringValue`.
    /// (The sole exception is when we want to transform the display at the moment
    /// the formatter is applied or removed.)
    @IBOutlet var termField: NSTextField! {
        didSet {
            termField?.delegate = self
        }
    }

    @IBOutlet var searchTypePopup: NSPopUpButton!

    @IBOutlet var operatorPopup: NSPopUpButton!

    @IBOutlet var progressSpinner: NSProgressIndicator!

    @IBOutlet var progressLabel: NSTextField! {
        didSet {
            progressLabel?.stringValue = "" // Prevent user seeing value from nib.
        }
    }

    @IBOutlet var blurbLabel: NSTextField! {
        didSet {
            blurbLabel?.stringValue = "" // Prevent user seeing value from nib.
            blurbLabel.maximumNumberOfLines = 3
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
    @IBOutlet var autoContainsModeCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialState)
        }
    }

    func present(_ state: MainState) async {
        if searchTypePopup.itemArray.count < 4 { // there are three in the nib
            searchTypePopup.removeAllItems()
            for item in state.searchTypePopupContents {
                searchTypePopup.addItem(withTitle: item["title"] ?? "Title")
            }
        }
        let currentSearchType = searchTypePopup.titleOfSelectedItem
        if currentSearchType != state.searchType["title"] {
            searchTypePopup.selectItem(at: state.searchTypePopupCurrentItemIndex)
        }

        blurbLabel.stringValue = state.searchType["blurb"] ?? ""

        let currentSearchTerm = termField.objectValue as? String ?? ""
        if currentSearchTerm != state.term {
            termField.objectValue = state.term
        }

        let currentOperator = operatorPopup.titleOfSelectedItem
        if currentOperator != state.searchOperator {
            operatorPopup.selectItem(withTitle: state.searchOperator)
        }

        wordBasedCheckbox.state = state.wordBased ? .on : .off
        caseInsensitiveCheckbox.state = state.caseInsensitive ? .on : .off
        diacriticInsensitiveCheckbox.state = state.diacriticInsensitive ? .on : .off

        autoContainsModeCheckbox.state = state.autoContainsMode ? .on : .off
        configureAutoContainsMode(state.autoContainsMode)

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

    func configureAutoContainsMode(_ isOn: Bool) {
        if isOn && termField.formatter == nil {
            let currentValue = termField.objectValue as? String ?? ""
            termField.formatter = MyStarFormatter()
            termField.stringValue = currentValue
            Task {
                await processor?.receive(.termChanged(termField.objectValue as? String ?? ""))
            }
        } else if !isOn && termField.formatter != nil {
            let currentValue = termField.objectValue as? String ?? ""
            termField.formatter = nil
            termField.stringValue = currentValue
            Task {
                await processor?.receive(.termChanged(termField.objectValue as? String ?? ""))
            }
        }
    }

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.returnInSearchField(sender.objectValue as? String ?? ""))
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

    @IBAction func doAutoContainsMode(_ sender: NSButton) {
        Task {
            await processor?.receive(.autoContainsMode(sender.state == .on))
        }
    }

    @IBAction func doSearchTypePopup(_ sender: NSPopUpButton) {
        Task {
            await processor?.receive(.searchType(sender.indexOfSelectedItem))
        }
    }

    @IBAction func doOperatorPopup(_ sender: NSPopUpButton) {
        Task {
            await processor?.receive(.operator(sender.titleOfSelectedItem ?? "=="))
        }
    }

    @IBAction func insertContains(_ sender: NSButton) {
        Task {
            await processor?.receive(.insertContains)
        }
    }
}

extension MainViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        guard let editor = obj.userInfo?["NSFieldEditor"] else {
            return
        }
        guard (editor as? NSTextView)?.delegate === termField else {
            return
        }
        Task {
            await processor?.receive(.termChanged(termField.objectValue as? String ?? ""))
        }
    }
}
