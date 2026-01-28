import Testing
@testable import NotLight3
import Foundation

private struct DateProcessorTests {
    let subject = DateProcessor()
    let presenter = MockReceiverPresenter<Void, DateState>()
    let delegate = MockDelegate()

    init() {
        subject.presenter = presenter
        subject.delegate = delegate
    }

    @Test("receive agoPopup: sets the state agoIndex")
    func agoPopup() async {
        await subject.receive(.agoPopup(42))
        #expect(subject.state.agoIndex == 42)
    }

    @Test("receive datePicker: sets the state absoluteDate")
    func datePicker() async {
        await subject.receive(.datePicker(.distantPast))
        #expect(subject.state.absoluteDate == .distantPast)
    }

    @Test("receive initialData: sets date to now, presents")
    func initialData() async {
        subject.state.absoluteDate = .distantPast
        await subject.receive(.initialData)
        #expect(abs(subject.state.absoluteDate.timeIntervalSinceNow) < 0.01) // close enough :)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive predefinedPopup: sets the state predefinedIndex")
    func predefinedPopup() async {
        await subject.receive(.predefinedPopup(42))
        #expect(subject.state.predefinedIndex == 42)
    }

    @Test("receive relativePopup: sets the state relativeIndex")
    func relativePopup() async {
        await subject.receive(.relativePopup(42))
        #expect(subject.state.relativeIndex == 42)
    }

    @Test("receive relativeQuantity: sets the state relativeQuantity")
    func relativeQuantity() async {
        await subject.receive(.relativeQuantity(42))
        #expect(subject.state.relativeQuantity == 42)
    }

    @Test("receive useAbsolute: calls delegate dateChosen with seconds since 1970")
    func useAbsolute() async {
        let dateComponents = DateComponents(
            calendar: .init(identifier: .gregorian),
            year: 1954,
            month: 8,
            day: 10,
            hour: 3,
            minute: 0,
            second: 0
        )
        let date = dateComponents.date!
        subject.state.absoluteDate = date
        await subject.receive(.useAbsolute)
        #expect(delegate.methodsCalled == ["dateChosen(_:)"])
        #expect(delegate.text == "-1464098400.0")
    }

    @Test("receive usePredefined: calls delegate dateChosen with predefined key")
    func usePredefined() async {
        subject.state.predefinedIndex = 3
        await subject.receive(.usePredefined)
        #expect(delegate.methodsCalled == ["dateChosen(_:)"])
        #expect(delegate.text == "$time.this_week")
    }

    @Test("receive useRelative: calls delegate dateChosen with relative key plus ago key plus adjusted amount")
    func useRelative() async {
        subject.state.agoIndex = 0
        subject.state.relativeIndex = 2
        subject.state.relativeQuantity = 3
        await subject.receive(.useRelative)
        #expect(delegate.methodsCalled == ["dateChosen(_:)"])
        #expect(delegate.text == "$time.now(-10800)") // 3*60*60
        // and another
        subject.state.agoIndex = 1
        subject.state.relativeIndex = 4
        subject.state.relativeQuantity = 2
        await subject.receive(.useRelative)
        #expect(delegate.text == "$time.this_week(2)")
    }
}

private class MockDelegate: DateDelegate {
    var methodsCalled = [String]()
    var text: String?
    func dateChosen(_ text: String) async {
        methodsCalled.append(#function)
        self.text = text
    }

}

