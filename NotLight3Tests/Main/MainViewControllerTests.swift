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
        state.searchTypePopupContents = [["title": "ho"], ["title": "ha"]]
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.searchTypePopup.itemArray.map {$0.title} == ["ho", "ha"])
    }

    @Test("present: sets search type popup selection")
    func presentSearchTypePopupSelection() async {
        var state = MainState()
        state.searchTypePopupContents = [["title": "ho"], ["title": "ha"]]
        state.searchTypePopupCurrentItemIndex = 1
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.searchTypePopup.titleOfSelectedItem == "ha")
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
        state.searchTypePopupContents = [["blurb": "ho"], ["blurb": "ha"]]
        subject.loadViewIfNeeded()
        await subject.present(state)
        #expect(subject.blurbLabel.stringValue == "ho")
        state.searchTypePopupCurrentItemIndex = 1
        await subject.present(state)
        #expect(subject.blurbLabel.stringValue == "ha")
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

    @Test("present: sets progress spinner and label")
    func presentProgressSpinnerLabel() async throws {
        subject.loadViewIfNeeded()
        let spinner = try #require(subject.progressSpinner as? MyProgressIndicator) // purely to give it an `isAnimating` property!
        #expect(spinner.isAnimating == false)
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
        await subject.present(MainState(progress: 2))
        #expect(spinner.isAnimating == true)
        #expect(subject.progressLabel.stringValue == "2 results found...")
        #expect(subject.stopButton.isEnabled == true)
        await subject.present(MainState(progress: 0))
        #expect(spinner.isAnimating == false)
        #expect(subject.progressLabel.stringValue == "")
        #expect(subject.stopButton.isEnabled == false)
    }

    @Test("doSearchTextField: sends processor returnInSearchField with text field string value")
    func doSearchTextField() async {
        let field = NSTextField()
        field.stringValue = "howdy"
        subject.doSearchTextField(field)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.returnInSearchField("howdy")])
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

    @Test("doSearchTypePopup: sends searchType")
    func searchTypePopup() async {
        let button = NSPopUpButton()
        button.addItem(withTitle: "hey")
        button.addItem(withTitle: "ho")
        button.selectItem(at: 1)
        subject.doSearchTypePopup(button)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.searchType(1)])
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
        subject.view.addSubview(field1)
        subject.view.addSubview(field2)
        field1.stringValue = "/top/testing"
        field2.stringValue = "/top/testing with space"
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
}
