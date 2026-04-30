import AppKit

final class ImportExportViewController: NSViewController, ReceiverPresenter {

    weak var processor: (any Receiver<ImportExportAction>)?

    override var nibName: String { "ImportExport" }

    @IBOutlet weak var currentSearchLabel: NSTextField! {
        didSet {
            let gestureRecognizer = NSClickGestureRecognizer(target: self, action: #selector(doubleClick))
            gestureRecognizer.numberOfClicksRequired = 2
            currentSearchLabel?.addGestureRecognizer(gestureRecognizer)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task.immediate {
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
        Task.immediate {
            await processor?.receive(.loadSearch)
        }
    }

    @IBAction func doSaveThisSearch(_: NSButton) {
        view.window?.endEditing(for: currentSearchLabel)
        Task.immediate {
            await processor?.receive(.saveSearch(currentSearchLabel.stringValue))
        }
    }

    @IBAction func doDoThisSearch(_: NSButton) {
        view.window?.endEditing(for: currentSearchLabel)
        Task.immediate {
            await processor?.receive(.doSearch(currentSearchLabel.stringValue))
        }
    }

    @objc func doubleClick(_ sender: NSGestureRecognizer) {
        if let textField = sender.view as? NSTextField {
            textField.isEditable = true
            textField.isBordered = true
            textField.drawsBackground = true
            textField.backgroundColor = .textBackgroundColor
            textField.focusRingType = .none
            textField.becomeFirstResponder()
            sender.isEnabled = false // thanks for the g.r. but now your job is over
        }
    }

}
