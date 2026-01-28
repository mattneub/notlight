import Testing
@testable import NotLight3
import Foundation

private struct DateProcessorTests {
    let subject = DateProcessor()
    let presenter = MockReceiverPresenter<Void, DateState>()

    init() {
        subject.presenter = presenter
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

    @Test("receive initialData: presents")
    func initialData() async {
        await subject.receive(.initialData)
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

}

