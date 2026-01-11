import AppKit

class MainViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<MainAction>)?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

//    override var representedObject: Any? {
//        didSet {
//        // Update the view, if already loaded.
//        }
//    }

    func present(_ state: MainState) async {}

    @IBAction func doSearchTextField(_ sender: NSTextField) {
        Task {
            await processor?.receive(.returnInSearchField(sender.stringValue))
        }
    }

}

