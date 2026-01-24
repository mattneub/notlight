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
    let appleScripter = MockAppleScripter()
    let beeper = MockBeeper()
    let coordinator = MockRootCoordinator()
    let presenter = MockReceiverPresenter<Void, MainState>()

    init() {
        subject.coordinator = coordinator
        subject.presenter = presenter
        subject.appleScripter = appleScripter
        services.bundle = bundle
        services.searcher = searcher
        services.queryStringBuilder = builder
        services.persistence = persistence
        services.beeper = beeper
    }

    @Test("receive autoContainsMode: sets the state autoContainsMode and presents, and persists")
    func autoContainsMode() async {
        await subject.receive(.autoContainsMode(true))
        #expect(subject.state.autoContainsMode == true)
        #expect(presenter.statesPresented == [subject.state])
        #expect(persistence.methodsCalled == ["saveAutoContains(_:)"])
        #expect(persistence.boolSaved == true)
    }

    @Test("receive caseInsensitive: sets the state caseInsensitive, and persists")
    func caseInsensitive() async {
        await subject.receive(.caseInsensitive(true))
        #expect(subject.state.caseInsensitive == true)
        #expect(persistence.methodsCalled == ["saveCaseInsensitive(_:)"])
        #expect(persistence.boolSaved == true)
    }
    
    @Test("receive diacriticInsensitive: sets the state diacriticInsensitive, and persists")
    func diacriticInsensitive() async {
        await subject.receive(.diacriticInsensitive(true))
        #expect(subject.state.diacriticInsensitive == true)
        #expect(persistence.methodsCalled == ["saveDiacriticInsensitive(_:)"])
        #expect(persistence.boolSaved == true)
    }

    @Test("receive initialState: fetches popup plist, checks persistence, sets state, presents")
    func initialState() async throws {
        let url = Bundle(for: MockBundle.self).url(forResource: "fake", withExtension: "plist")!
        bundle.urlToReturn = url
        persistence.boolToReturn = true // just say yes to everything
        persistence.intToReturn = 42
        persistence.term = "term"
        persistence.search = "search"
        persistence.searchOperator = "op"
        await subject.receive(.initialState)
        #expect(bundle.methodsCalled == ["url(forResource:withExtension:)"])
        #expect(bundle.name == "popup")
        #expect(bundle.ext == "plist")
        #expect(subject.state.keyPopupContents.count == 1)
        let searchKey = subject.state.keyPopupContents[0]
        #expect(searchKey.key == "this is the key")
        #expect(searchKey.title == "this is the title")
        #expect(searchKey.blurb == "this is the blurb")
        #expect(persistence.methodsCalled == [
            "loadKeyPopupIndex()",
            "loadAutoContains()",
            "loadCaseInsensitive()",
            "loadDiacriticInsensitive()",
            "loadWordBased()",
            "loadTerm()",
            "loadSearchOperator()",
            "loadCurrentSearch()"
        ])
        #expect(subject.state.keyPopupIndex == 42)
        #expect(subject.state.autoContainsMode)
        #expect(subject.state.caseInsensitive)
        #expect(subject.state.diacriticInsensitive)
        #expect(subject.state.wordBased)
        #expect(subject.state.term == "term")
        #expect(subject.state.searchOperator == "op")
        #expect(searcher.methodsCalled == ["setPreviousQueryString(_:)"])
        #expect(searcher.queryString == "search")
        #expect(presenter.statesPresented == [subject.state])
        #expect(subject.appleScripter is AppleScripter)
    }

    @Test("receive finder: executes script, if valid file path sets state scopes, presents")
    func finder() async {
        appleScripter.stringToReturn = URL.temporaryDirectory.path(percentEncoded: false)
        await subject.receive(.finder)
        #expect(appleScripter.methodsCalled == ["executeScript()"])
        #expect(subject.state.scopes == [URL.temporaryDirectory])
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive finder: executes script, if empty result, beeps")
    func finderEmptyScriptResult() async {
        appleScripter.stringToReturn = ""
        await subject.receive(.finder)
        #expect(appleScripter.methodsCalled == ["executeScript()"])
        #expect(subject.state.scopes == [])
        #expect(presenter.statesPresented.isEmpty)
        #expect(beeper.methodsCalled == ["beep()"])
    }

    @Test("receive finder: executes script, if bad path result, beeps")
    func finderBadScriptResult() async {
        appleScripter.stringToReturn = "hey babu riba"
        await subject.receive(.finder)
        #expect(appleScripter.methodsCalled == ["executeScript()"])
        #expect(subject.state.scopes == [])
        #expect(presenter.statesPresented.isEmpty)
        #expect(beeper.methodsCalled == ["beep()"])
    }

    @Test("receive insertContains: inserts asterisks in state term, presents")
    func insertContains() async {
        subject.state.term = "howdy"
        await subject.receive(.insertContains)
        #expect(subject.state.term == "*howdy*")
        #expect(presenter.statesPresented == [subject.state])
    }

    @Test("receive keyPopupIndex: changes state popup index, presents, persists")
    func searchType() async {
        await subject.receive(.keyPopupIndex(3))
        #expect(subject.state.keyPopupIndex == 3)
        #expect(presenter.statesPresented == [subject.state])
        #expect(persistence.methodsCalled == ["saveKeyPopupIndex(_:)"])
        #expect(persistence.intSaved == 3)
    }

    @Test("receive operator: sets state operator, presents, persists")
    func searchOperator() async {
        await subject.receive(.operator("op"))
        #expect(subject.state.searchOperator == "op")
        #expect(presenter.statesPresented == [subject.state])
        #expect(persistence.methodsCalled == ["saveSearchOperator(_:)"])
        #expect(persistence.searchOperator == "op")
    }

    @Test("receive performSearch: calls builder makeQuery with term and state values")
    func performSearchBuilder() async {
        subject.state.caseInsensitive = true
        subject.state.keyPopupContents = [SearchKey(key: "kMDItemDisplayName", title: "", blurb: "")]
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

    @Test("receive performSearch: calls searcher doSearch with builder's query string and joiner, persists")
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
        #expect(persistence.methodsCalled == ["saveTerm(_:)", "saveCurrentSearch(_:)"])
        #expect(persistence.term == "howdy")
        #expect(persistence.search == "queryString")
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
        #expect(presenter.statesPresented.count == 5)
        #expect(presenter.statesPresented[0].progress == 0)
        #expect(presenter.statesPresented[0].progressSpinner == true)
        #expect(presenter.statesPresented[1].progress == 0)
        #expect(presenter.statesPresented[2].progress == 1)
        #expect(presenter.statesPresented[3].progress == 2)
        #expect(presenter.statesPresented[4].progress == 3)
        await #while(subject.progressWatchingTask?.isCancelled == false)
        #expect(subject.progressWatchingTask?.isCancelled == true)
        #expect(presenter.statesPresented.count == 6)
        #expect(presenter.statesPresented[5].progress == 0)
        #expect(presenter.statesPresented[5].progressSpinner == false)
    }

    @Test("receive performSearch: if term is empty, beeps")
    func performSearchEmpty() async {
        await subject.receive(.performSearch("", .noJoiner))
        #expect(builder.methodsCalled.isEmpty)
        #expect(searcher.methodsCalled.isEmpty)
        #expect(coordinator.methodsCalled.isEmpty)
        #expect(persistence.methodsCalled.isEmpty)
        #expect(beeper.methodsCalled == ["beep()"])
    }

    @Test("receive performSearch: if search throws, beeps")
    func performSearchThrow() async {
        searcher.errorToThrow = .badQuery
        await subject.receive(.performSearch("howdy", .noJoiner))
        #expect(searcher.methodsCalled == ["doSearch(_:scopes:joiner:)"])
        #expect(searcher.term == "")
        #expect(coordinator.methodsCalled.isEmpty)
        #expect(persistence.methodsCalled.isEmpty)
        #expect(beeper.methodsCalled == ["beep()"])
    }

    @Test("receive performSearch: if search returns empty results, beeps")
    func performSearchEmptyResults() async {
        searcher.resultToReturn = SearchInfo(queryString: "", results: [])
        await subject.receive(.performSearch("howdy", .noJoiner))
        #expect(searcher.methodsCalled == ["doSearch(_:scopes:joiner:)"])
        #expect(coordinator.methodsCalled.isEmpty)
        #expect(beeper.methodsCalled == ["beep()"])
    }

    @Test("receive scopes: sets state scopes, presents")
    func scopes() async {
        await subject.receive(.scopes([URL(string: "file:///testing")!]))
        #expect(subject.state.scopes == [URL(string: "file:///testing")!])
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

    @Test("receive showSearchKeys: calls coordinator showSearchKeys")
    func showSearchKeys() async {
        await subject.receive(.showSearchKeys)
        #expect(coordinator.methodsCalled == ["showSearchKeys()"])
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
        #expect(persistence.methodsCalled == ["saveWordBased(_:)"])
        #expect(persistence.boolSaved == true)
    }

}
