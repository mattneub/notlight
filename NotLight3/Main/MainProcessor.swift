final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    var progressWatchingTask: Task<(), Never>?

    func receive(_ action: MainAction) async {
        switch action {
        case .returnInSearchField(let term):
            if term.isEmpty {
                return
            }
            watchProgress()
            if let result = try? await services.searcher.doSearch(term) {
                let resultsState = ResultsState(queryString: result.queryString, results: result.results)
                coordinator?.showResults(state: resultsState)
            }
            progressWatchingTask?.cancel()
            state.progress = 0
            await presenter?.present(state)
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
