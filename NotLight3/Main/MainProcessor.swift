final class MainProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, MainState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = MainState()

    var progressWatchingTask: Task<(), Never>?

    /// The AppleScripter object, instantiated only after receiving `.initialState` so that the
    /// user sees the interface and then the system dialog asking to script the Finder.
    var appleScripter: (any AppleScripterType)?

    func receive(_ action: MainAction) async {
        switch action {
        case .autoContainsMode(let on):
            state.autoContainsMode = on
            await presenter?.present(state)
            services.persistence.saveAutoContains(on)
        case .caseInsensitive(let on):
            state.caseInsensitive = on
            services.persistence.saveCaseInsensitive(on)
        case .diacriticInsensitive(let on):
            state.diacriticInsensitive = on
            services.persistence.saveDiacriticInsensitive(on)
        case .finder:
            guard let result = appleScripter?.executeScript(), !result.isEmpty else {
                services.beeper.beep()
                return
            }
            let url = URL(filePath: result, directoryHint: .isDirectory, relativeTo: nil)
            let exists = try? url.checkResourceIsReachable()
            if exists == true {
                state.scopes = [url]
                await presenter?.present(state)
            } else {
                services.beeper.beep()
            }
        case .initialState:
            if let url = services.bundle.url(forResource: "popup", withExtension: "plist") {
                if let data = try? Data(contentsOf: url, options: .uncached) {
                    if let contents = try? PropertyListDecoder().decode([SearchKey].self, from: data) {
                        state.keyPopupContents = contents + services.persistence.loadAdditionalKeys()
                        state.keyPopupIndex = services.persistence.loadKeyPopupIndex()
                    }
                }
            }
            state.autoContainsMode = services.persistence.loadAutoContains()
            state.caseInsensitive = services.persistence.loadCaseInsensitive()
            state.diacriticInsensitive = services.persistence.loadDiacriticInsensitive()
            state.wordBased = services.persistence.loadWordBased()
            state.term = services.persistence.loadTerm()
            state.searchOperator = services.persistence.loadSearchOperator()
            services.searcher.setPreviousQueryString(services.persistence.loadCurrentSearch())
            await presenter?.present(state)
            self.appleScripter = AppleScripter() // create the instance now that we're up and running
        case .insertContains:
            let term = state.term.trimmingCharacters(in: CharacterSet(charactersIn: "*"))
            state.term = "*" + term + "*"
            await presenter?.present(state)
        case .keyPopupIndex(let index):
            state.keyPopupIndex = index
            await presenter?.present(state)
            services.persistence.saveKeyPopupIndex(index)
        case .operator(let searchOperator):
            state.searchOperator = searchOperator
            await presenter?.present(state)
            services.persistence.saveSearchOperator(searchOperator)
        case .performSearch(let term, let joiner):
            if term.isEmpty {
                services.beeper.beep()
                return
            }
            state.progressSpinner = true
            await presenter?.present(state)
            watchProgress()
            let queryString = services.queryStringBuilder.makeQuery(
                term: term,
                caseInsensitive: state.caseInsensitive,
                diacriticInsensitive: state.diacriticInsensitive,
                wordBased: state.wordBased,
                type: state.currentKey.key,
                operator: state.searchOperator
            )
            if let result = try? await services.searcher.doSearch(
                queryString,
                scopes: state.scopes,
                joiner: joiner
            ), !result.results.isEmpty {
                let resultsState = ResultsState(
                    queryString: result.queryString,
                    results: result.results
                )
                coordinator?.showResults(state: resultsState)
                services.persistence.saveTerm(term)
                services.persistence.saveCurrentSearch(queryString)
            } else {
                services.beeper.beep()
            }
            progressWatchingTask?.cancel()
            state.progress = 0
            state.progressSpinner = false
            await presenter?.present(state)
        case .scopes(let urls):
            state.scopes = urls
            await presenter?.present(state)
        case .showDateAssistant:
            coordinator?.showDateAssistant()
        case .showFileIcons:
            let oldValue = services.persistence.loadShowFileIcons()
            services.persistence.saveShowFileIcons(!oldValue)
        case .showFileSizes:
            let oldValue = services.persistence.loadShowFileSizes()
            services.persistence.saveShowFileSizes(!oldValue)
        case .showModDates:
            let oldValue = services.persistence.loadShowModDates()
            services.persistence.saveShowModDates(!oldValue)
        case .showSearchKeys:
            coordinator?.showSearchKeys()
        case .stop:
            services.searcher.stop()
        case .termChanged(let term):
            state.term = term // and do not present
        case .wordBased(let on):
            state.wordBased = on
            services.persistence.saveWordBased(on)
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

extension MainProcessor: SearchKeysDelegate {
    func done() async {
        if let url = services.bundle.url(forResource: "popup", withExtension: "plist") {
            if let data = try? Data(contentsOf: url, options: .uncached) {
                if let contents = try? PropertyListDecoder().decode([SearchKey].self, from: data) {
                    state.keyPopupContents = contents + services.persistence.loadAdditionalKeys()
                    state.keyPopupIndex = 0
                }
            }
        }
        await presenter?.present(state)
    }
}

extension MainProcessor: DateDelegate {
    func dateChosen(_ text: String) async {
        state.term = text
        await presenter?.present(state)
        coordinator?.bringMainToFront()
    }
}
