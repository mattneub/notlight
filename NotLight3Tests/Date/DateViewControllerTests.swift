import Testing
@testable import NotLight3
import AppKit

private struct DateViewControllerTests: ~Copyable {
    let subject = DateViewController()
    let processor = MockReceiver<DateAction>()

    init() {
        subject.processor = processor
    }

    deinit {
        closeWindows()
    }

    @Test("nibName is correct")
    func nibName() {
        #expect(subject.nibName == "Date")
    }

    @Test("predefinedPopup: is correctly set up")
    func predefinedPopup() {
        subject.loadViewIfNeeded()
        #expect(subject.predefinedPopup.numberOfItems == 0)
        #expect(subject.predefinedPopup.action == #selector(subject.doPredefined))
    }

    @Test("relativePopup: is correctly set up")
    func relativePopup() {
        subject.loadViewIfNeeded()
        #expect(subject.relativePopup.numberOfItems == 0)
        #expect(subject.relativePopup.action == #selector(subject.doRelative))
    }

    @Test("relativeQuantityField is correctly set up")
    func relativeQuantity() {
        subject.loadViewIfNeeded()
        #expect(subject.relativeQuantityField.integerValue == 1)
    }

    @Test("agoPopup: is correctly set up")
    func agoPopup() {
        subject.loadViewIfNeeded()
        #expect(subject.agoPopup.numberOfItems == 0)
        #expect(subject.agoPopup.action == #selector(subject.doAgo))
    }

    @Test("viewDidLoad: sends initialData")
    func viewDidLoad() {
        subject.loadViewIfNeeded()
        #expect(processor.thingsReceived == [.initialData])
    }

    @Test("viewDidAppear: sets up window")
    func viewDidAppear() {
        let window = makeWindow(viewController: subject)
        #expect(window.minSize == CGSize(width: 316, height: 222))
        #expect(window.isResizable == false)
    }

    @Test("present: configures the three popups, sets the date picker")
    func present() async {
        subject.loadViewIfNeeded()
        await subject.present(.init(absoluteDate: .distantPast))
        #expect(subject.predefinedPopup.itemTitles == ["Now", "Today", "Yesterday", "This Week", "This Month", "This Year"])
        #expect(subject.relativePopup.itemTitles == ["Seconds", "Minutes", "Hours", "Days", "Weeks", "Months", "Years"])
        #expect(subject.agoPopup.itemTitles == ["Ago", "From Now"])
        #expect(subject.datePicker.dateValue == .distantPast)
    }

    @Test("doPredefined: sends predefinedPopup with the index")
    func doPredefined() {
        let menu = NSPopUpButton()
        menu.addItems(withTitles: ["manny", "moe", "jack"])
        menu.selectItem(at: 2)
        subject.doPredefined(menu)
        #expect(processor.thingsReceived == [.predefinedPopup(2)])
    }

    @Test("doRelative: sends relativePopup with the index")
    func doRelative() {
        let menu = NSPopUpButton()
        menu.addItems(withTitles: ["manny", "moe", "jack"])
        menu.selectItem(at: 2)
        subject.doRelative(menu)
        #expect(processor.thingsReceived == [.relativePopup(2)])
    }

    @Test("doAgo: sends agoPopup with the index")
    func doAgo() {
        let menu = NSPopUpButton()
        menu.addItems(withTitles: ["manny", "moe", "jack"])
        menu.selectItem(at: 2)
        subject.doAgo(menu)
        #expect(processor.thingsReceived == [.agoPopup(2)])
    }

    @Test("doRelativeQuantity: sets relativeQuantityField, sends relativeQuantity with the integer value")
    func doRelativeQuantity() {
        subject.loadViewIfNeeded()
        let stepper = NSStepper()
        stepper.integerValue = 42
        subject.doRelativeQuantity(stepper)
        #expect(processor.thingsReceived.last == .relativeQuantity(42))
        #expect(subject.relativeQuantityField.integerValue == 42)
    }

    @Test("doDatePicker: sends datePicker with the date")
    func doDatePicker() {
        let picker = NSDatePicker()
        picker.dateValue = .distantPast
        subject.doDatePicker(picker)
        #expect(processor.thingsReceived.last == .datePicker(.distantPast))
    }

    @Test("usePredefined: sends usePredefined")
    func usePredefined() {
        subject.usePredefined(NSButton())
        #expect(processor.thingsReceived == [.usePredefined])
    }

    @Test("useRelative: sends useRelative")
    func useRelative() {
        subject.useRelative(NSButton())
        #expect(processor.thingsReceived == [.useRelative])
    }

    @Test("useAbsolute: sends useAbsolute")
    func useAbsolute() {
        subject.useAbsolute(NSButton())
        #expect(processor.thingsReceived == [.useAbsolute])
    }
}
