import Testing
@testable import NotLight3
import AppKit

private struct SearchKeysProcessorTests {
    let subject = SearchKeysProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, SearchKeysState>()
    
    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
    }
    
    @Test("receive initialData: presents")
    func initialData() async {
        subject.state.keys = [SearchKey(key: "key", title: "title", blurb: "blurb")]
        await subject.receive(.initialData)
        #expect(presenter.statesPresented == [subject.state])
    }
}
