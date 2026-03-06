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

    @IBOutlet var progressSpinner: MyProgressIndicator! {
        didSet {
            progressSpinner?.isHidden = true
            progressSpinner?.isDisplayedWhenStopped = true
            progressSpinner?.usesThreadedAnimation = false
        }
    }

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

    @IBOutlet var stackView: NSStackView!

    var folderTextFields: [FolderTextField] {
        view.subviews(ofType: FolderTextField.self, recursing: true)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialState)
        }
    }

// I was having trouble getting the main window not to resize when the results sheet appears,
// and this seemed to fix it, but now it seems I can manage without it, so I'm leaving it here
// commented out just in case and let's see what happens.
//    override func viewWillLayout() {
//        super.viewWillLayout()
//        preferredContentSize = view.bounds.size // CGSize(width: 480, height: 272)
//    }

    func present(_ state: MainState) async {
        if searchTypePopup.itemArray.map(\.title) != state.keyPopupContents.map(\.title) {
            searchTypePopup.removeAllItems()
            for item in state.keyPopupContents {
                searchTypePopup.addItem(withTitle: item.title)
            }
        }
        let currentSearchType = searchTypePopup.titleOfSelectedItem
        if currentSearchType != state.currentKey.title {
            searchTypePopup.selectItem(at: state.keyPopupIndex)
        }

        blurbLabel.stringValue = state.currentKey.blurb

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
            if let total = state.progressTotal, total != 0 {
                progressLabel.stringValue = "\(String(state.progress)) results processed..."
                progressSpinner.isIndeterminate = false
                progressSpinner.doubleValue = Double(state.progress) / Double(total) * 100
            } else {
                progressLabel.stringValue = "\(String(state.progress)) results found..."
                progressSpinner.isIndeterminate = true
                progressSpinner.startAnimation(self)
            }
            stopButton.isEnabled = true
        } else {
            progressLabel.stringValue = ""
            stopButton.isEnabled = false
            progressSpinner.isIndeterminate = true
            progressSpinner.startAnimation(self)
        }

        if progressSpinner.isHidden != !state.progressVisible {
            progressSpinner.isHidden = !state.progressVisible
        }

        reconcileScopes(state.scopes)
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

    func reconcileScopes(_ scopes: [URL]) {
        let folderTextFieldsCount = folderTextFields.count
        let neededCount = scopes.count + 1
        if neededCount > folderTextFieldsCount { // add text fields
            for _ in folderTextFieldsCount ..< neededCount {
                let containerView = MyContainerView()
                stackView.addArrangedSubview(containerView)
                containerView.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
            }
        } else if neededCount < folderTextFieldsCount { // remove text fields
            for _ in neededCount ..< folderTextFieldsCount {
                if let lastContainerView = stackView.arrangedSubviews.last {
                    stackView.removeView(lastContainerView)
                }
            }
        }
        // now apply values
        let fields = folderTextFields
        for (url, field) in zip(scopes, fields) {
            field.objectValue = url
        }
        fields.last?.objectValue = nil
    }

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.performSearch(sender.objectValue as? String ?? "", .noJoiner))
        }
    }

    @IBAction func doSearchButton(_ sender: NSButton) {
        Task {
            await processor?.receive(.performSearch(termField.objectValue as? String ?? "", .noJoiner))
        }
    }

    @IBAction func doSearchWithinButton(_ sender: NSButton) {
        Task {
            await processor?.receive(.performSearch(termField.objectValue as? String ?? "", .and))
        }
    }

    @IBAction func doSearchAlsoButton(_ sender: NSButton) {
        Task {
            await processor?.receive(.performSearch(termField.objectValue as? String ?? "", .or))
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
            await processor?.receive(.keyPopupIndex(sender.indexOfSelectedItem))
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

    @IBAction func doFinder(_ sender: NSButton) {
        Task {
            await processor?.receive(.finder)
        }
    }

    @IBAction func doDate(_ sender: NSButton) {
        Task {
            await processor?.receive(.showDateAssistant)
        }
    }

    /// nil-targeted from MyContainerView!
    @objc func folderTextFieldChanged(_ sender: NSTextField) {
        let urls = folderTextFields.compactMap { $0.objectValue as? URL }
        Task {
            await processor?.receive(.scopes(urls))
        }
    }

    @objc func showFileIcons(_ sender: NSMenuItem) {
        Task {
            await processor?.receive(.showFileIcons)
        }
    }

    @objc func showModDates(_ sender: NSMenuItem) {
        Task {
            await processor?.receive(.showModDates)
        }
    }

    @objc func showFileSizes(_ sender: NSMenuItem) {
        Task {
            await processor?.receive(.showFileSizes)
        }
    }

    @IBAction func showSearchKeys(_ sender: NSMenuItem) {
        Task {
            await processor?.receive(.showSearchKeys)
        }
    }

    @objc func showDateAssistant(_ sender: NSMenuItem) {
        Task {
            await processor?.receive(.showDateAssistant)
        }
    }

    @IBAction func showImportExport(_ sender: NSButton) {
        Task {
            await processor?.receive(.showImportExport(sender, sender.bounds))
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
