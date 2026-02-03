import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct SearchKeysViewControllerTests {
    let subject = SearchKeysViewController()
    let processor = MockProcessor<SearchKeysAction, SearchKeysState, SearchKeysEffect>()
    let datasource = MockSearchKeysDatasource()

    init() {
        subject.processor = processor
        subject.datasource = datasource
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "SearchKeys")
    }

    @Test("blurbField: is correctly configured")
    func blurbField() {
        subject.loadViewIfNeeded()
        #expect(subject.blurbField.maximumNumberOfLines == 3)
        #expect(subject.blurbField.cell?.truncatesLastVisibleLine == true)
        #expect(subject.blurbField?.delegate === subject)
    }

    @Test("initialization: sets up the datasource and table view")
    func initialization() throws {
        let subject = SearchKeysViewController()
        let processor = MockProcessor<SearchKeysAction, SearchKeysState, Void>()
        subject.processor = processor
        subject.loadViewIfNeeded()
        let datasource = try #require(subject.datasource as? SearchKeysDatasource)
        #expect(subject.tableView != nil)
        #expect(datasource.processor === subject.processor)
        #expect(datasource.tableView === subject.tableView)
    }

    @Test("viewDidLoad: sets things up, sends processor initialData")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewDidAppear: makes window not resizable, sets min size")
    func viewDidAppear() {
        let view = NSView()
        let window = makeWindow(view: view)
        #expect(window.isResizable == true)
        view.addSubview(subject.view)
        subject.viewDidAppear()
        #expect(window.isResizable == false)
        #expect(window.minSize == CGSize(width: 480, height: 272))
        window.close()
    }

    @Test("present: based on state selected row, configures blurbField")
    func presentBlurbField() async {
        subject.loadViewIfNeeded()
        var state = SearchKeysState(keys: [.init(key: "key", title: "title", blurb: "blurb")], selectedRow: 0)
        await subject.present(state)
        #expect(subject.blurbField.isEnabled == true)
        #expect(subject.blurbField.stringValue == "blurb")
        state.selectedRow = -1
        await subject.present(state)
        #expect(subject.blurbField.isEnabled == false)
        #expect(subject.blurbField.stringValue == "")
    }

    @Test("present: presents to the datasource")
    func present() async {
        subject.loadViewIfNeeded()
        let state = SearchKeysState(keys: [.init(key: "key", title: "title", blurb: "blurb")])
        await subject.present(state)
        #expect(datasource.methodsCalled == ["present(_:)"])
        #expect(datasource.statePresented == state)
    }

    @Test("receive: passes effect to the datasource")
    func receive() async {
        await subject.receive(.editLastRow)
        #expect(datasource.methodsCalled == ["receive(_:)"])
        #expect(datasource.thingsReceived == [.editLastRow])
    }

    @Test("doAdd: ends editing, sends add")
    func doAdd() async throws {
        let window = makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        let editor = try #require(window.fieldEditor(false, for: textField))
        #expect(window.firstResponder === editor)
        subject.doAdd(NSButton())
        #expect(window.firstResponder == window)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .add)
        window.close()
    }

    @Test("doDelete: deletes selected row, ends editing, sends delete")
    func doDelete() async throws {
        let window = makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        let tableView = MockTableView()
        tableView._selectedRow = 10
        subject.tableView = tableView
        subject.doDelete(NSButton())
        #expect(textField.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .delete(10))
        window.close()
    }

    @Test("doDelete: if no selected row, does nothing")
    func doDeleteNoSelection() async throws {
        let window = makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        let tableView = MockTableView()
        tableView._selectedRow = -1
        subject.tableView = tableView
        subject.doDelete(NSButton())
        try? await Task.sleep(for: .seconds(0.1))
        #expect(textField.currentEditor() != nil)
        #expect(processor.thingsReceived == [.initialData])
        window.close()
    }

    @Test("doDone: ends editing, sends done")
    func doDone() async throws {
        let window = makeWindow(viewController: subject)
        let textField = NSTextField()
        subject.view.addSubview(textField)
        textField.becomeFirstResponder()
        #expect(textField.currentEditor() != nil)
        subject.doDone(NSButton())
        #expect(textField.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .done)
        window.close()
    }

    @Test("didEndEditing: sends changed with row of sender, column of sender, text of sender")
    func didEndEditing() async throws {
        subject.loadViewIfNeeded()
        let tableView = MockTableView()
        tableView._rowForView = 20
        tableView._columnForView = 30
        subject.tableView = tableView
        let textField = NSTextField()
        textField.stringValue = "howdy"
        subject.didEndEditing(textField)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .changed(row: 20, column: 30, text: "howdy"))
    }

    @Test("controlTextDidChange: sends blurb with contents of blurb field")
    func controlTextDidChange() async {
        subject.loadViewIfNeeded()
        subject.blurbField.stringValue = "howdy"
        subject.controlTextDidChange(Notification(name: .init("dummy")))
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .blurb("howdy"))
    }
}

private final class MockTableView: NSTableView {
    var _selectedRow: Int = 0
    var _rowForView: Int = 0
    var _columnForView: Int = 0
    override var selectedRow: Int { _selectedRow }
    override func row(for: NSView) -> Int { _rowForView }
    override func column(for: NSView) -> Int { _columnForView }
}

