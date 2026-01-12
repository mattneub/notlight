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

    @Test("doSearchTextField: sends processor returnInSearchField with text field string value")
    func doSearchTextField() async {
        let field = NSTextField()
        field.stringValue = "howdy"
        subject.doSearchTextField(field)
        await #while(processor.thingsReceived.isEmpty)
        #expect(processor.thingsReceived == [.returnInSearchField("howdy")])
    }
}
