import Testing
@testable import NotLight3
import Foundation
import WaitWhile

private struct MainProcessorTests {
    let subject = MainProcessor()
    let searcher = MockSearcher()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, MainState>()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        services.searcher = searcher
    }

    @Test("receive returnInSearchField: calls searcher doSearch")
    func returnInSearchField() async {
        let result = SearchInfo(queryString: "query", results: [SearchResult(displayName: "name", path: "path")])
        searcher.resultToReturn = result
        await subject.receive(.returnInSearchField("howdy"))
        #expect(searcher.methodsCalled == ["doSearch(_:)"])
        #expect(searcher.term == "howdy")
        #expect(coordinator.methodsCalled == ["showResults(state:)"])
        #expect(coordinator.resultsState?.queryString == result.queryString)
        #expect(coordinator.resultsState?.results == result.results)
    }

    @Test("receive returnInSearchField: if searcher searchProgress publishes, updates state progress, presents")
    func returnInSearchFieldProgress() async {
        let result = SearchInfo(queryString: "query", results: [SearchResult(displayName: "name", path: "path")])
        searcher.resultToReturn = result
        searcher.timeToSleep = 1
        Task {
            await subject.receive(.returnInSearchField("howdy"))
        }
        await #while(subject.progressWatchingTask == nil)
        try? await Task.sleep(for: .seconds(0.1))
        searcher.searchProgress.count = 1
        try? await Task.sleep(for: .seconds(0.1))
        searcher.searchProgress.count = 2
        try? await Task.sleep(for: .seconds(0.1))
        searcher.searchProgress.count = 3
        try? await Task.sleep(for: .seconds(0.1))
        #expect(presenter.statesPresented.count == 4)
        #expect(presenter.statesPresented[0].progress == 0)
        #expect(presenter.statesPresented[1].progress == 1)
        #expect(presenter.statesPresented[2].progress == 2)
        #expect(presenter.statesPresented[3].progress == 3)
        await #while(subject.progressWatchingTask?.isCancelled == false)
        #expect(subject.progressWatchingTask?.isCancelled == true)
    }

    @Test("receive returnInSearchField: if term is empty, does nothing")
    func returnInSearchFieldEmpty() async {
        await subject.receive(.returnInSearchField(""))
        #expect(searcher.methodsCalled.isEmpty)
        #expect(coordinator.methodsCalled.isEmpty)
    }

    @Test("receive returnInSearchField: if search throws, does nothing")
    func returnInSearchFieldThrow() async {
        searcher.errorToThrow = .badQuery
        await subject.receive(.returnInSearchField("howdy"))
        #expect(searcher.methodsCalled == ["doSearch(_:)"])
        #expect(searcher.term == "howdy")
        #expect(coordinator.methodsCalled.isEmpty)
    }

    @Test("receive stop: calls searcher stop")
    func stop() async {
        await subject.receive(.stop)
        #expect(searcher.methodsCalled == ["stop()"])
    }
}
