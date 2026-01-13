final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    func receive(_ action: MainAction) async {
        switch action {
        case .returnInSearchField(let term):
            if term.isEmpty {
                return
            }
            if let result = try? await services.searcher.doSearch(term) {
                let resultsState = ResultsState(queryString: result.queryString, results: result.results)
                coordinator?.showResults(state: resultsState)
            }
        }
    }
}
