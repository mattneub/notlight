import AppKit

final class DateViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<DateAction>)?

    override var nibName: String? { "Date" }

    @IBOutlet weak var predefinedPopup: NSPopUpButton! {
        didSet {
            predefinedPopup?.removeAllItems()
            predefinedPopup?.action = #selector(doPredefined)
        }
    }

    @IBOutlet weak var relativePopup: NSPopUpButton! {
        didSet {
            relativePopup?.removeAllItems()
            relativePopup?.action = #selector(doRelative)
        }
    }

    @IBOutlet weak var relativeQuantityField: NSTextField! {
        didSet {
            relativeQuantityField?.integerValue = 1
        }
    }

    @IBOutlet weak var agoPopup: NSPopUpButton! {
        didSet {
            agoPopup?.removeAllItems()
            agoPopup?.action = #selector(doAgo)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.styleMask.remove(.resizable)
            window.minSize = CGSize(width: 316, height: 222)
            window.makeFirstResponder(nil)
        }
    }

    func present(_ state: DateState) async {
        if predefinedPopup.numberOfItems == 0 {
            for item in state.predefinedContent {
                predefinedPopup.addItem(withTitle: item["name"] ?? "")
            }
        }
        if relativePopup.numberOfItems == 0 {
            for item in state.relativeContent {
                relativePopup.addItem(withTitle: item["name"] ?? "")
            }
        }
        if agoPopup.numberOfItems == 0 {
            for item in state.agoContent {
                agoPopup.addItem(withTitle: item["name"] ?? "")
            }
        }
    }

    // popup menu choices

    @objc func doPredefined(_ sender: NSPopUpButton) {
        Task {
            await processor?.receive(.predefinedPopup(sender.indexOfSelectedItem))
        }
    }
    @objc func doRelative(_ sender: NSPopUpButton) {
        Task {
            await processor?.receive(.relativePopup(sender.indexOfSelectedItem))
        }
    }
    @objc func doAgo(_ sender: NSPopUpButton) {
        Task {
            await processor?.receive(.agoPopup(sender.indexOfSelectedItem))
        }
    }

    // relative field

    @IBAction func doRelativeQuantity(_ sender: NSStepper) {
        relativeQuantityField.integerValue = sender.integerValue
        Task {
            await processor?.receive(.relativeQuantity(sender.integerValue))
        }
    }

    // date picker

    @IBAction func doDatePicker(_ sender: NSDatePicker) {
        Task {
            await processor?.receive(.datePicker(sender.dateValue))
        }
    }

    // "use this" button clicks

    @IBAction func usePredefined(_ sender: NSButton) {
        Task {
            await processor?.receive(.usePredefined)
        }
    }

    @IBAction func useRelative(_ sender: NSButton) {
        Task {
            await processor?.receive(.useRelative)
        }
    }

    @IBAction func useAbsolute(_ sender: NSButton) {
        Task {
            await processor?.receive(.useAbsolute)
        }
    }

}

