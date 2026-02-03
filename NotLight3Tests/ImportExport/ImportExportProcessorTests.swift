import Testing
@testable import NotLight3
import Foundation
import WaitWhile

private struct ImportExportProcessorTests {
    let subject = ImportExportProcessor()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, ImportExportState>()
    let delegate = MockDelegate()
    let persistence = MockPersistence()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        subject.delegate = delegate
        services.persistence = persistence
    }

    @Test("receive doSearch: calls coordinator dismiss, calls delegate doSearch")
    func doSearch() async {
        await subject.receive(.doSearch("howdy"))
        #expect(coordinator.methodsCalled == ["dismiss()"])
        #expect(delegate.methodsCalled == ["doSearch(_:)"])
        #expect(delegate.search == "howdy")
    }

    @Test("receive initialData: fetches current search from persistence, presents it")
    func initialData() async {
        persistence.search = "search"
        await subject.receive(.initialData)
        #expect(persistence.methodsCalled == ["loadCurrentSearch()"])
        #expect(subject.state.currentSearch == "search")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive loadSearch: calls coordinator dismiss, calls delegate loadSearch")
    func loadSearch() async {
        await subject.receive(.loadSearch)
        #expect(coordinator.methodsCalled == ["dismiss()"])
        #expect(delegate.methodsCalled == ["loadSearch()"])
    }

    @Test("receive saveSearch: calls coordinator dismiss, calls delegate saveSearch")
    func saveSearch() async {
        await subject.receive(.saveSearch("howdy"))
        #expect(coordinator.methodsCalled == ["dismiss()"])
        #expect(delegate.methodsCalled == ["saveSearch(_:)"])
        #expect(delegate.search == "howdy")
    }
}

private final class MockDelegate: ImportExportDelegate {
    var methodsCalled = [String]()
    var search: String?

    func doSearch(_ search: String) async {
        methodsCalled.append(#function)
        self.search = search
    }

    func loadSearch() async {
        methodsCalled.append(#function)
    }

    func saveSearch(_ search: String) async {
        methodsCalled.append(#function)
        self.search = search
    }

}
