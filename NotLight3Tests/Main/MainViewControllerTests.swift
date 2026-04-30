import Testing
@testable import NotLight3
import AppKit

private struct MainViewControllerTests: ~Copyable {
    let subject = MainViewController()
    let processor = MockProcessor<MainAction, MainState, Void>()

    init() {
        subject.processor = processor
    }

    deinit {
        closeWindows()
    }

    @Test("nibName: is correct")
    func nibName() {
        #expect(subject.nibName == "Main")
    }

    @Test("termField: is correctly prepared")
    func termField() {
        subject.loadViewIfNeeded()
        #expect(subject.termField.delegate === subject)
    }

    @Test("progressSpinner: is correctly prepared")
    func progressSpinner() {
        subject.loadViewIfNeeded()
        #expect(subject.progressSpinner.isHidden)
        #expect(subject.progressSpinner.isDisplayedWhenStopped == true)
        #expect(subject.progressSpinner.usesThreadedAnimation == false)
    }

    @Test("progressLabel: is correctly prepared")
    func progressLabel() {
        subject.loadViewIfNeeded()
        #expect(subject.progressLabel.stringValue == "")
    }

    @Test("blurbLabel: is correctly prepared")
    func blurbLabel() {
        subject.loadViewIfNeeded()
        #expect(subject.blurbLabel.stringValue == "")
        #expect(subject.blurbLabel.maximumNumberOfLines == 3)
    }

    @Test("stopButton: is correctly prepared")
    func stopButton() {
        subject.loadViewIfNeeded()
        #expect(subject.stopButton.isEnabled == false)
    }

    @Test("viewDidLoad: sends initialState")
    func viewDidLoad() {
        subject.loadViewIfNeeded()
        #expect(processor.thingsReceived == [.initialState])
    }

    @Test("present: configures search type popup")
    func presentSearchTypePopup() async {
        var state = MainState()
        let key1 = SearchKey(key: "1", title: "title1", blurb: "1")
        let key2 = SearchKey(key: "2", title: "title2", blurb: "2")
        state.keyPopupContents = [key1, key2]
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.searchTypePopup.itemArray.map {$0.title} == ["title1", "title2"])
    }

    @Test("present: sets search type popup selection")
    func presentSearchTypePopupSelection() async {
        var state = MainState()
        let key1 = SearchKey(key: "1", title: "title1", blurb: "1")
        let key2 = SearchKey(key: "2", title: "title2", blurb: "2")
        state.keyPopupContents = [key1, key2]
        state.keyPopupIndex = 1
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.searchTypePopup.titleOfSelectedItem == "title2")
    }

    @Test("present: sets term field")
    func presentTermField() async {
        var state = MainState()
        state.term = "howdy"
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.termField.stringValue == "howdy")
    }

    @Test("present: sets blurb text")
    func presentBlurb() async {
        var state = MainState()
        let key1 = SearchKey(key: "1", title: "1", blurb: "blurb1")
        let key2 = SearchKey(key: "2", title: "2", blurb: "blurb2")
        state.keyPopupContents = [key1, key2]
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.blurbLabel.stringValue == "blurb1")
        state.keyPopupIndex = 1
        await subject.present(state)
        #expect(subject.blurbLabel.stringValue == "blurb2")
    }

    @Test("presents: sets operator popup selection")
    func presentOperator() async {
        var state = MainState()
        state.searchOperator = "<="
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.operatorPopup.titleOfSelectedItem == "<=")
    }

    @Test("present: sets the three checkboxes")
    func presentCheckBoxes() async {
        subject.loadViewIfNeeded()
        subject.wordBasedCheckbox.state = .on
        subject.caseInsensitiveCheckbox.state = .on
        subject.diacriticInsensitiveCheckbox.state = .on
        var state = MainState()
        await subject.present(state)
        #expect(subject.wordBasedCheckbox.state == .off)
        #expect(subject.caseInsensitiveCheckbox.state == .off)
        #expect(subject.diacriticInsensitiveCheckbox.state == .off)
        state.wordBased = true
        await subject.present(state)
        #expect(subject.wordBasedCheckbox.state == .on)
        #expect(subject.caseInsensitiveCheckbox.state == .off)
        #expect(subject.diacriticInsensitiveCheckbox.state == .off)
        state.caseInsensitive = true
        await subject.present(state)
        #expect(subject.wordBasedCheckbox.state == .on)
        #expect(subject.caseInsensitiveCheckbox.state == .on)
        #expect(subject.diacriticInsensitiveCheckbox.state == .off)
        state.diacriticInsensitive = true
        await subject.present(state)
        #expect(subject.wordBasedCheckbox.state == .on)
        #expect(subject.caseInsensitiveCheckbox.state == .on)
        #expect(subject.diacriticInsensitiveCheckbox.state == .on)
    }

    @Test("present: sets the autoContains checkbox and applies/removes formatter, sets value, sends termChanged")
    func presentAutoContains() async throws {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        #expect(subject.termField.formatter == nil)
        var state = MainState()
        state.autoContainsMode = true
        state.term = "howdy"
        await subject.present(state)
        #expect(subject.autoContainsModeCheckbox.state == .on)
        do {
            let formatter = try #require(subject.termField.formatter)
            #expect(formatter is MyStarFormatter)
        }
        #expect(subject.termField.objectValue as? String == "*howdy*")
        #expect(subject.termField.stringValue == "howdy")
        #expect(processor.thingsReceived.last == .termChanged("*howdy*"))
        // and now, the other way
        processor.thingsReceived = []
        state.autoContainsMode = false
        state.term = "*howdy*"
        await subject.present(state)
        #expect(subject.autoContainsModeCheckbox.state == .off)
        #expect(subject.termField.formatter == nil)
        #expect(subject.termField.objectValue as? String == "*howdy*")
        #expect(subject.termField.stringValue == "*howdy*")
        #expect(processor.thingsReceived.last == .termChanged("*howdy*"))
        // and now, the _other_ other way
        processor.thingsReceived = []
        state.autoContainsMode = true
        state.term = "*howdy*"
        await subject.present(state)
        #expect(subject.autoContainsModeCheckbox.state == .on)
        do {
            let formatter = try #require(subject.termField.formatter)
            #expect(formatter is MyStarFormatter)
        }
        #expect(subject.termField.objectValue as? String == "*howdy*")
        #expect(subject.termField.stringValue == "howdy")
        #expect(processor.thingsReceived.last == .termChanged("*howdy*"))
    }

    @Test("present: with progress and total sets progress label, spinner, and stop button")
    func presentProgressAndTotal() async {
        subject.loadViewIfNeeded()
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
        await subject.present(MainState(progress: 2, progressTotal: 4))
        #expect(subject.progressLabel.stringValue == "2 results processed...")
        #expect(subject.progressSpinner.isIndeterminate == false)
        #expect(subject.progressSpinner.doubleValue == 50) // percentage
        #expect(subject.stopButton.isEnabled == true)
        await subject.present(MainState(progress: 0, progressTotal: 4))
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
    }

    @Test("present: sets progress and nil total sets progress label, spinner, and stop button")
    func presentProgressLabel() async throws {
        subject.loadViewIfNeeded()
        let spinner = try #require(subject.progressSpinner)
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
        await subject.present(MainState(progress: 2, progressTotal: nil))
        #expect(subject.progressLabel.stringValue == "2 results found...")
        #expect(spinner.isIndeterminate == true)
        #expect(spinner.isAnimating == true)
        #expect(subject.stopButton.isEnabled == true)
        await subject.present(MainState(progress: 0, progressTotal: nil))
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
    }

    @Test("present: progressVisible sets progress spinner visibility")
    func presentProgressVisible() async throws {
        subject.loadViewIfNeeded()
        #expect(subject.progressSpinner.isHidden == true)
        await subject.present(MainState(progressVisible: true))
        #expect(subject.progressSpinner.isHidden == false)
        await subject.present(MainState(progressVisible: false))
        #expect(subject.progressSpinner.isHidden == true)
    }

    @Test("present: sets folder text field quantity and values")
    func presentFolderTextField() async throws {
        makeWindow(viewController: subject)
        let scopes = [URL(string: "file:///testing")!, URL(string: "file:///testing2")!]
        await subject.present(MainState(scopes: scopes))
        let fields = subject.folderTextFields
        #expect(fields.count == 3)
        #expect(fields[0].objectValue as? URL == URL(string: "file:///testing")!)
        #expect(fields[1].objectValue as? URL == URL(string: "file:///testing2")!)
        #expect(fields[2].objectValue as? URL == nil)
    }

    @Test("doSearchTextField: sends processor performSearch with text field object value and no joiner")
    func doSearchTextField() {
        let field = NSTextField()
        field.objectValue = "howdy"
        subject.doSearchTextField(field)
        #expect(processor.thingsReceived == [.performSearch("howdy", .noJoiner)])
    }

    @Test("doSearchButton: sends processor performSearch with text field object value and no joiner")
    func doSearchButton() {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchButton(NSButton())
        #expect(processor.thingsReceived.last == .performSearch("howdy", .noJoiner))
    }

    @Test("doSearchWithButton: sends processor performSearch with text field object value and .and joiner")
    func doSearchWithinButton() {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchWithinButton(NSButton())
        #expect(processor.thingsReceived.last == .performSearch("howdy", .and))
    }

    @Test("doSearchAlsoButton: sends processor performSearch with text field object value and .or joiner")
    func doSearchAlsoButton() {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchAlsoButton(NSButton())
        #expect(processor.thingsReceived.last == .performSearch("howdy", .or))
    }

    @Test("doStop: sends processor stop")
    func doStop() {
        subject.doStop(NSButton())
        #expect(processor.thingsReceived == [.stop])
    }

    @Test("doCaseInsensitive: sends caseInsensitive")
    func caseInsensitive() {
        let button = NSButton()
        button.state = .off
        subject.doCaseInsensitive(button)
        #expect(processor.thingsReceived == [.caseInsensitive(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doCaseInsensitive(button)
        #expect(processor.thingsReceived == [.caseInsensitive(true)])
    }

    @Test("doDiacriticInsensitive: sends diacriticInsensitive")
    func diacriticInsensitive() {
        let button = NSButton()
        button.state = .off
        subject.doDiacriticInsensitive(button)
        #expect(processor.thingsReceived == [.diacriticInsensitive(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doDiacriticInsensitive(button)
        #expect(processor.thingsReceived == [.diacriticInsensitive(true)])
    }

    @Test("doWordBased: sends wordBased")
    func wordBased() {
        let button = NSButton()
        button.state = .off
        subject.doWordBased(button)
        #expect(processor.thingsReceived == [.wordBased(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doWordBased(button)
        #expect(processor.thingsReceived == [.wordBased(true)])
    }

    @Test("doAutoContainsMode: sends autoContainsMode")
    func autoContainsMode() {
        let button = NSButton()
        button.state = .off
        subject.doAutoContainsMode(button)
        #expect(processor.thingsReceived == [.autoContainsMode(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doAutoContainsMode(button)
        #expect(processor.thingsReceived == [.autoContainsMode(true)])
    }

    @Test("doSearchTypePopup: sends keyPopupIndex")
    func searchTypePopup() {
        let button = NSPopUpButton()
        button.addItem(withTitle: "hey")
        button.addItem(withTitle: "ho")
        button.selectItem(at: 1)
        subject.doSearchTypePopup(button)
        #expect(processor.thingsReceived == [.keyPopupIndex(1)])
    }

    @Test("doOperatorPopup: sends operator")
    func operatorPopup() {
        let button = NSPopUpButton()
        button.addItem(withTitle: "hey")
        button.addItem(withTitle: "ho")
        button.selectItem(at: 1)
        subject.doOperatorPopup(button)
        #expect(processor.thingsReceived == [.operator("ho")])
    }

    @Test("insertContains: sends insertContains")
    func insertContains() {
        let button = NSButton()
        subject.insertContains(button)
        #expect(processor.thingsReceived == [.insertContains])
    }

    @Test("folderTextFieldChanged: sends scopes with file URLs from paths of FolderTextFields")
    func folderTextFieldChanged() {
        subject.loadViewIfNeeded()
        let field1 = FolderTextField(frame: .zero)
        let field2 = FolderTextField(frame: .zero)
        let field3 = FolderTextField(frame: .zero)
        subject.view.addSubview(field1)
        subject.view.addSubview(field2)
        subject.view.addSubview(field3)
        field1.objectValue = nil
        field2.stringValue = "/top/testing"
        field3.stringValue = "/top/testing with space"
        subject.folderTextFieldChanged(field1)
        #expect(processor.thingsReceived.last == .scopes([
            URL(string: "file:///top/testing/")!, // file path, and in particular a directory
            URL(string: "file:///top/testing%20with%20space/")!,
        ]))
    }

    @Test("controlTextDidChange: sends termChanged")
    func controlTextDidChange() {
        let window = makeWindow(viewController: subject)
        subject.termField.stringValue = "howdy"
        subject.termField.becomeFirstResponder()
        let textView = window.firstResponder
        let notification = Notification(name: NSText.didChangeNotification, userInfo: ["NSFieldEditor": textView as Any])
        subject.controlTextDidChange(notification)
        #expect(processor.thingsReceived.last == .termChanged("howdy"))
    }

    @Test("showFileIcons: sends showFileIcons")
    func showFileIcons() {
        subject.showFileIcons(NSMenuItem())
        #expect(processor.thingsReceived == [.showFileIcons])
    }

    @Test("showFileSizes: sends showFileSizes")
    func showFileSizes() {
        subject.showFileSizes(NSMenuItem())
        #expect(processor.thingsReceived == [.showFileSizes])
    }

    @Test("showModDates: sends showModDates")
    func showModDates() {
        subject.showModDates(NSMenuItem())
        #expect(processor.thingsReceived == [.showModDates])
    }

    @Test("doFinder: sends finder")
    func doFinder() {
        subject.doFinder(NSButton())
        #expect(processor.thingsReceived == [.finder])
    }

    @Test("doDate: sends showDateAssistant")
    func doDate() {
        subject.doDate(NSButton())
        #expect(processor.thingsReceived == [.showDateAssistant])
    }

    @Test("showSearchKeys: sends showSearchKeys")
    func showSearchKeys() {
        subject.showSearchKeys(NSMenuItem())
        #expect(processor.thingsReceived == [.showSearchKeys])
    }

    @Test("showDateAssistant: sends showDateAssistant")
    func showDateAssistant() {
        subject.showDateAssistant(NSMenuItem())
        #expect(processor.thingsReceived == [.showDateAssistant])
    }

    @Test("showImportExport: sends showImportExport with sender and its bounds")
    func showImportExport() {
        let button = NSButton()
        button.frame = NSRect(x: 10, y: 10, width: 100, height: 200)
        subject.showImportExport(button)
        #expect(processor.thingsReceived == [.showImportExport(button, NSRect(x: 0, y: 0, width: 100, height: 200))])
    }
}
