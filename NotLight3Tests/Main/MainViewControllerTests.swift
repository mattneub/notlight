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
}
