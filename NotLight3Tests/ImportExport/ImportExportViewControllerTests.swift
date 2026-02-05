import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct ImportExportViewControllerTests: ~Copyable {
    let subject = ImportExportViewController()
    let processor = MockProcessor<ImportExportAction, ImportExportState, Void>()

    init() {
        subject.processor = processor
    }

    deinit {
        closeWindows()
    }

    @Test("nibName is correct")
    func nibName() {
        #expect(subject.nibName == "ImportExport")
    }

    @Test("currentSearchLabel is correctly prepared")
    func currentSearchLabel() throws {
        subject.loadViewIfNeeded()
        let tapper = try #require(subject.currentSearchLabel.gestureRecognizers.first as? NSClickGestureRecognizer)
        #expect(tapper.numberOfClicksRequired == 2)
        #expect(tapper.target === subject)
        #expect(tapper.action == #selector(subject.doubleClick))
    }

    @Test("viewDidLoad: sends initialData")
    func viewDidLoad() async {
        subject.viewDidLoad()
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewDidAppear: sets up window")
    func viewDidAppear() {
        let window = makeWindow(viewController: subject)
        #expect(window.isResizable == false)
    }

    @Test("present: sets currentSearchLabel text")
    func present() async {
        subject.loadViewIfNeeded()
        await subject.present(ImportExportState(currentSearch: "howdy"))
        #expect(subject.currentSearchLabel.stringValue == "howdy")
    }

    @Test("doLoadSearch: sends loadSearch")
    func doLoadSearch() async {
        subject.doLoadSearch(NSButton())
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.loadSearch])
    }

    @Test("doSaveThisSearch: stops editing, sends saveSearch")
    func doSaveThisSearch() async {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.currentSearchLabel.isEditable = true
        subject.currentSearchLabel.becomeFirstResponder()
        #expect(subject.currentSearchLabel.currentEditor() != nil)
        subject.currentSearchLabel.stringValue = "howdy"
        subject.doSaveThisSearch(NSButton())
        #expect(subject.currentSearchLabel.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .saveSearch("howdy"))
    }

    @Test("doDoThisSearch: stops editing, sends doSearch")
    func doDoThisSearch() async {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        subject.currentSearchLabel.isEditable = true
        subject.currentSearchLabel.becomeFirstResponder()
        #expect(subject.currentSearchLabel.currentEditor() != nil)
        subject.currentSearchLabel.stringValue = "howdy"
        subject.doDoThisSearch(NSButton())
        #expect(subject.currentSearchLabel.currentEditor() == nil)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived.last == .doSearch("howdy"))
    }

    @Test("doubleClick: makes search label editable")
    func doubleClick() throws {
        makeWindow(viewController: subject)
        subject.loadViewIfNeeded()
        let tapper = try #require(subject.currentSearchLabel.gestureRecognizers.first)
        subject.doubleClick(tapper)
        #expect(subject.currentSearchLabel.isEditable == true)
        #expect(subject.currentSearchLabel.isBordered == true)
        #expect(subject.currentSearchLabel.drawsBackground == true)
        #expect(subject.currentSearchLabel.backgroundColor == .textBackgroundColor)
        #expect(subject.currentSearchLabel.focusRingType == .none)
        #expect(subject.currentSearchLabel.currentEditor() != nil)
        #expect(tapper.isEnabled == false)
    }
}
