import AppKit

final class SearchKeysViewController: NSViewController, ReceiverPresenter {
    weak var processor: (any Receiver<SearchKeysAction>)?

    override var nibName: String { "SearchKeys" }

    @IBOutlet weak var tableView: NSTableView!

    @IBOutlet weak var blurbField: NSTextField! {
        didSet {
            blurbField?.maximumNumberOfLines = 3
            blurbField?.cell?.truncatesLastVisibleLine = true
            blurbField?.delegate = self
        }
    }

    lazy var datasource: (any TableViewDatasourceType<SearchKeysEffect, SearchKeysState>) = SearchKeysDatasource(
        tableView: tableView,
        processor: processor
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await processor?.receive(.initialData)
        }
    }

    override func viewDidAppear() {
        view.window?.styleMask.remove(.resizable)
    }

    func present(_ state: SearchKeysState) async {
        if state.selectedRow > -1 {
            blurbField.stringValue = state.keys[state.selectedRow].blurb
            blurbField.isEnabled = true
        } else {
            blurbField.stringValue = ""
            blurbField.isEnabled = false
        }
        await datasource.present(state)
    }

    func receive(_ effect: SearchKeysEffect) async {
        await datasource.receive(effect)
    }

    @IBAction func doAdd(_ sender: NSButton) {
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.add)
        }
    }

    @IBAction func doDelete(_ sender: NSButton) {
        let row = tableView.selectedRow
        guard row > -1 else {
            return
        }
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.delete(row))
        }
    }

    @IBAction func doDone(_ sender: NSButton) {
        view.window?.endEditing(for: nil)
        Task {
            await processor?.receive(.done)
        }
    }

    @objc func didEndEditing(_ sender: NSTextField) {
        let row = tableView.row(for: sender)
        let column = tableView.column(for: sender)
        let text = sender.stringValue
        Task {
            await processor?.receive(.changed(row: row, column: column, text: text))
        }
    }
}

extension SearchKeysViewController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        Task {
            await processor?.receive(.blurb(blurbField.stringValue))
        }
    }
}
