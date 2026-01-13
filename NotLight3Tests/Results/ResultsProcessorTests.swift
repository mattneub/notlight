import Testing
@testable import NotLight3
import Foundation

private struct ResultsProcessorTests {
    let subject = ResultsProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, ResultsState>()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
    }

    @Test("receive close: calls coordinator dismiss()")
    func close() async {
        await subject.receive(.close)
        #expect(coordinator.methodsCalled == ["dismiss()"])
    }

    @Test("receive initialData: presents state")
    func initialData() async {
        subject.state.results = [.init(displayName: "name", path: "path")]
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }
}
