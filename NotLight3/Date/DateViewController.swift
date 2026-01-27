import AppKit

final class DateViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<DateAction>)?

    override var nibName: String? { "Date" }

    override func viewDidAppear() {
        super.viewDidAppear()
        if let window = view.window {
            window.styleMask.remove(.resizable)
            window.minSize = CGSize(width: 316, height: 222)
        }
    }

    func present(_ state: DateState) async {}
}

