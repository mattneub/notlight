import Testing
@testable import NotLight3
import Foundation
import WaitWhile

private struct MainProcessorTests {
    let subject = MainProcessor()
    let builder = MockQueryStringBuilder()
    let searcher = MockSearcher()
    let bundle = MockBundle()
    let persistence = MockPersistence()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, MainState>()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        services.bundle = bundle
        services.searcher = searcher
        services.queryStringBuilder = builder
        services.persistence = persistence
    }

    @Test("receive autoContainsMode: sets the state autoContainsMode and presents")
    func autoContainsMode() async {
        await subject.receive(.autoContainsMode(true))
        #expect(subject.state.autoContainsMode == true)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive caseInsensitive: sets the state caseInsensitive")
    func caseInsensitive() async {
        await subject.receive(.caseInsensitive(true))
        #expect(subject.state.caseInsensitive == true)
        await subject.receive(.caseInsensitive(false))
        #expect(subject.state.caseInsensitive == false)
    }
    
    @Test("receive diacriticInsensitive: sets the state diacriticInsensisive")
    func diacriticInsensitive() async {
        await subject.receive(.diacriticInsensitive(true))
        #expect(subject.state.diacriticInsensitive == true)
        await subject.receive(.diacriticInsensitive(false))
        #expect(subject.state.diacriticInsensitive == false)
    }

    @Test("receive initialState: fetches popup plist, sets state, presents")
    func initialState() async {
        let list: [[String: String]] = [["hey": "ho"]]
        let url = Bundle(for: MockBundle.self).url(forResource: "fake", withExtension: "plist")!
        bundle.urlToReturn = url
        subject.state.caseInsensitive = true
        await subject.receive(.initialState)
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.name == "popup")
        #expect(bundle.ext == "plist")
        #expect(subject.state.searchTypePopupContents == list)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive insertContains: inserts asterisks in state term, presents")
    func insertContains() async {
        subject.state.term = "howdy"
        await subject.receive(.insertContains)
        #expect(subject.state.term == "*howdy*")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive operator: sets state operator, presents")
    func searchOperator() async {
        await subject.receive(.operator("op"))
        #expect(subject.state.searchOperator == "op")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive performSearch: calls builder makeQuery with term and state values")
    func performSearchBuilder() async {
        subject.state.caseInsensitive = true
        subject.state.searchTypePopupContents = [["key": "kMDItemDisplayName"]]
        subject.state.searchOperator = "!="
        builder.queryStringToReturn = "queryString"
        await subject.receive(.performSearch("howdy", .noJoiner))
        #expect(builder.methodsCalled == ["makeQuery(term:caseInsensitive:diacriticInsensitive:wordBased:type:operator:)"])
        #expect(builder.term == "howdy")
        #expect(builder.caseInsensitive == true)
        #expect(builder.diacriticInsensitive == false)
        #expect(builder.wordBased == false)
        #expect(builder.type == "kMDItemDisplayName")
        #expect(builder.operatorString == "!=")
    }

    @Test("receive performSearch: calls searcher doSearch with builder's query string and joiner")
    func performSearch() async {
        subject.state.scopes = [URL(string: "file:///testing")!]
        builder.queryStringToReturn = "queryString"
        let result = SearchInfo(queryString: "query", results: [SearchResult(displayName: "name", path: "path", date: .distantPast, size: 10)])
        searcher.resultToReturn = result
        await subject.receive(.performSearch("howdy", .and))
        #expect(searcher.methodsCalled == ["doSearch(_:scopes:joiner:)"])
        #expect(searcher.term == "queryString")
        #expect(searcher.scopes == [URL(string: "file:///testing")!])
        #expect(searcher.joiner == .and)
        #expect(coordinator.methodsCalled == ["showResults(state:)"])
        #expect(coordinator.resultsState?.queryString == result.queryString)
        #expect(coordinator.resultsState?.results == result.results)
    }

    @Test("receive performSearch: if searcher searchProgress publishes, updates state progress, presents")
    func performSearchProgress() async {
        let result = SearchInfo(queryString: "query", results: [SearchResult(displayName: "name", path: "path", date: .distantPast, size: 10)])
        searcher.resultToReturn = result
        searcher.timeToSleep = 1
        Task {
            await subject.receive(.performSearch("howdy", .noJoiner))
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

    @Test("receive performSearch: if term is empty, does nothing")
    func performSearchEmpty() async {
        await subject.receive(.performSearch("", .noJoiner))
        #expect(builder.methodsCalled.isEmpty)
        #expect(searcher.methodsCalled.isEmpty)
        #expect(coordinator.methodsCalled.isEmpty)
    }

    @Test("receive performSearch: if search throws, does nothing")
    func performSearchThrow() async {
        searcher.errorToThrow = .badQuery
        await subject.receive(.performSearch("howdy", .noJoiner))
        #expect(searcher.methodsCalled == ["doSearch(_:scopes:joiner:)"])
        #expect(searcher.term == "")
        #expect(coordinator.methodsCalled.isEmpty)
    }

    @Test("receive scopes: sets state scopes")
    func scopes() async {
        await subject.receive(.scopes([URL(string: "file:///testing")!]))
        #expect(subject.state.scopes == [URL(string: "file:///testing")!])
    }

    @Test("receive searchType: changes state popup index, presents")
    func searchType() async {
        await subject.receive(.searchType(3))
        #expect(subject.state.searchTypePopupCurrentItemIndex == 3)
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive showFileIcons: toggles persistence showFileIcons")
    func showFileIcons() async {
        persistence.boolToReturn = true
        await subject.receive(.showFileIcons)
        #expect(persistence.methodsCalled == ["loadShowFileIcons()", "saveShowFileIcons(_:)"])
        #expect(persistence.boolSaved == false)
    }

    @Test("receive showFileSizes: toggles persistence showFilSizess")
    func showFileSizes() async {
        persistence.boolToReturn = true
        await subject.receive(.showFileSizes)
        #expect(persistence.methodsCalled == ["loadShowFileSizes()", "saveShowFileSizes(_:)"])
        #expect(persistence.boolSaved == false)
    }

    @Test("receive showModDates: toggles persistence showModDates")
    func showModDates() async {
        persistence.boolToReturn = true
        await subject.receive(.showModDates)
        #expect(persistence.methodsCalled == ["loadShowModDates()", "saveShowModDates(_:)"])
        #expect(persistence.boolSaved == false)
    }

    @Test("receive stop: calls searcher stop")
    func stop() async {
        await subject.receive(.stop)
        #expect(searcher.methodsCalled == ["stop()"])
    }

    @Test("receive termChanged: sets state term, does not present")
    func termChanged() async {
        await subject.receive(.termChanged("howdy"))
        #expect(subject.state.term == "howdy")
        #expect(presenter.statesPresented.isEmpty)
    }

    @Test("receive wordBased: sets the state wordBased")
    func wordBased() async {
        await subject.receive(.wordBased(true))
        #expect(subject.state.wordBased == true)
        await subject.receive(.wordBased(false))
        #expect(subject.state.wordBased == false)
    }

}
