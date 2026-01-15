final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    var progressWatchingTask: Task<(), Never>?

    func receive(_ action: MainAction) async {
        switch action {
        case .caseInsensitive(let on):
            state.caseInsensitive = on
        case .diacriticInsensitive(let on):
            state.diacriticInsensitive = on
        case .initialState:
            await presenter?.present(state)
        case .returnInSearchField(let term):
            if term.isEmpty {
                return
            }
            watchProgress()
            // TODO: If we get a bad query error here, show an alert
            let queryString = try? services.queryStringBuilder.makeQuery(
                term: term,
                caseInsensitive: state.caseInsensitive,
                diacriticInsensitive: state.diacriticInsensitive,
                wordBased: state.wordBased
            )
            if let queryString, let result = try? await services.searcher.doSearch(queryString) {
                let resultsState = ResultsState(queryString: result.queryString, results: result.results)
                coordinator?.showResults(state: resultsState)
            }
            progressWatchingTask?.cancel()
            state.progress = 0
            await presenter?.present(state)
        case .stop:
            services.searcher.stop()
        case .wordBased(let on):
            state.wordBased = on
        }
    }

    /// Method which, while a search is ongoing, keeps us apprised periodically of the number
    /// of gathered results, so that we can show the user.
    func watchProgress() {
        let progresses = Observations {
            services.searcher.searchProgress.count
        }
        progressWatchingTask?.cancel()
        progressWatchingTask = Task {
            for await progress in progresses {
                if Task.isCancelled {
                    break
                }
                state.progress = progress
                await presenter?.present(state)
            }
        }
    }
}
