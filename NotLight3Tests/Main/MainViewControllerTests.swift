import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct MainViewControllerTests {
    let subject = MainViewController()
    let processor = MockProcessor<MainAction, MainState, Void>()

    init() {
        subject.processor = processor
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

    @Test("blurbLabel: is correctly prepared")
    func blurbLabel() {
        subject.loadViewIfNeeded()
        #expect(subject.blurbLabel.stringValue == "")
        #expect(subject.blurbLabel.maximumNumberOfLines == 3)
    }

    @Test("viewDidLoad: sends initialState")
    func viewDidLoad() async {
        subject.loadViewIfNeeded()
        await #while(processor.thingsReceived.isEmpty)
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
        await #while(processor.thingsReceived.isEmpty)
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
        await #while(processor.thingsReceived.isEmpty)
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
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .termChanged("*howdy*"))
    }

    @Test("present: sets progress label and stop button")
    func presentProgressLabel() async throws {
        subject.loadViewIfNeeded()
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
        await subject.present(MainState(progress: 2))
        #expect(subject.progressLabel.stringValue == "2 results found...")
        #expect(subject.stopButton.isEnabled == true)
        await subject.present(MainState(progress: 0))
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
    }

    @Test("present: sets progress spinner")
    func presentProgressSpinner() async throws {
        subject.loadViewIfNeeded()
        let spinner = try #require(subject.progressSpinner as? MyProgressIndicator) // purely to give it an `isAnimating` property!
        #expect(spinner.isAnimating == false)
        await subject.present(MainState(progressSpinner: true))
        #expect(spinner.isAnimating == true)
        await subject.present(MainState(progressSpinner: false))
        #expect(spinner.isAnimating == false)
    }

    @Test("present: sets folder text field quantity and values")
    func presentFolderTextField() async throws {
        makeWindow(viewController: subject)
        let scopes = [URL(string: "file:///testing")!, URL(string: "file:///testing2")!]
        await subject.present(MainState(scopes: scopes))
        await #while(subject.folderTextFields.count < 3)
        try #require(subject.folderTextFields.count == 3)
        let fields = subject.folderTextFields
        #expect(fields.count == 3)
        #expect(fields[0].objectValue as? URL == URL(string: "file:///testing")!)
        #expect(fields[1].objectValue as? URL == URL(string: "file:///testing2")!)
        #expect(fields[2].objectValue as? URL == nil)
    }

    @Test("doSearchTextField: sends processor performSearch with text field object value and no joiner")
    func doSearchTextField() async {
        let field = NSTextField()
        field.objectValue = "howdy"
        subject.doSearchTextField(field)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.performSearch("howdy", .noJoiner)])
    }

    @Test("doSearchButton: sends processor performSearch with text field object value and no joiner")
    func doSearchButton() async {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchButton(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .performSearch("howdy", .noJoiner))
    }

    @Test("doSearchWithButton: sends processor performSearch with text field object value and .and joiner")
    func doSearchWithinButton() async {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchWithinButton(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .performSearch("howdy", .and))
    }

    @Test("doSearchAlsoButton: sends processor performSearch with text field object value and .or joiner")
    func doSearchAlsoButton() async {
        subject.loadViewIfNeeded()
        subject.termField.objectValue = "howdy"
        subject.doSearchAlsoButton(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .performSearch("howdy", .or))
    }

    @Test("doStop: sends processor stop")
    func doStop() async {
        subject.doStop(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.stop])
    }

    @Test("doCaseInsensitive: sends caseInsensitive")
    func caseInsensitive() async {
        let button = NSButton()
        button.state = .off
        subject.doCaseInsensitive(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.caseInsensitive(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doCaseInsensitive(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.caseInsensitive(true)])
    }

    @Test("doDiacriticInsensitive: sends diacriticInsensitive")
    func diacriticInsensitive() async {
        let button = NSButton()
        button.state = .off
        subject.doDiacriticInsensitive(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.diacriticInsensitive(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doDiacriticInsensitive(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.diacriticInsensitive(true)])
    }

    @Test("doWordBased: sends wordBased")
    func wordBased() async {
        let button = NSButton()
        button.state = .off
        subject.doWordBased(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.wordBased(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doWordBased(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.wordBased(true)])
    }

    @Test("doAutoContainsMode: sends autoContainsMode")
    func autoContainsMode() async {
        let button = NSButton()
        button.state = .off
        subject.doAutoContainsMode(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.autoContainsMode(false)])
        processor.thingsReceived = []
        button.state = .on
        subject.doAutoContainsMode(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.autoContainsMode(true)])
    }

    @Test("doSearchTypePopup: sends keyPopupIndex")
    func searchTypePopup() async {
        let button = NSPopUpButton()
        button.addItem(withTitle: "hey")
        button.addItem(withTitle: "ho")
        button.selectItem(at: 1)
        subject.doSearchTypePopup(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.keyPopupIndex(1)])
    }

    @Test("doOperatorPopup: sends operator")
    func operatorPopup() async {
        let button = NSPopUpButton()
        button.addItem(withTitle: "hey")
        button.addItem(withTitle: "ho")
        button.selectItem(at: 1)
        subject.doOperatorPopup(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.operator("ho")])
    }

    @Test("insertContains: sends insertContains")
    func insertContains() async {
        let button = NSButton()
        subject.insertContains(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.insertContains])
    }

    @Test("folderTextFieldChanged: sends scopes with file URLs from paths of FolderTextFields")
    func folderTextFieldChanged() async {
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
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .scopes([
            URL(string: "file:///top/testing/")!, // file path, and in particular a directory
            URL(string: "file:///top/testing%20with%20space/")!,
        ]))
    }

    @Test("controlTextDidChange: sends termChanged")
    func controlTextDidChange() async {
        let window = makeWindow(viewController: subject)
        subject.termField.stringValue = "howdy"
        subject.termField.becomeFirstResponder()
        let textView = window.firstResponder
        let notification = Notification(name: NSText.didChangeNotification, userInfo: ["NSFieldEditor": textView as Any])
        subject.controlTextDidChange(notification)
        await #while(processor.thingsReceived.count < 2)
        #expect(processor.thingsReceived.last == .termChanged("howdy"))
    }

    @Test("showFileIcons: sends showFileIcons")
    func showFileIcons() async {
        subject.showFileIcons(NSMenuItem())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showFileIcons])
    }

    @Test("showFileSizes: sends showFileSizes")
    func showFileSizes() async {
        subject.showFileSizes(NSMenuItem())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showFileSizes])
    }

    @Test("showModDates: sends showModDates")
    func showModDates() async {
        subject.showModDates(NSMenuItem())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showModDates])
    }

    @Test("doFinder: sends finder")
    func doFinder() async {
        subject.doFinder(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.finder])
    }

    @Test("doDate: sends showDateAssistant")
    func doDate() async {
        subject.doDate(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showDateAssistant])
    }

    @Test("showSearchKeys: sends showSearchKeys")
    func showSearchKeys() async {
        subject.showSearchKeys(NSMenuItem())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showSearchKeys])
    }

    @Test("showDateAssistant: sends showDateAssistant")
    func showDateAssistant() async {
        subject.showDateAssistant(NSMenuItem())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.showDateAssistant])
    }
}
