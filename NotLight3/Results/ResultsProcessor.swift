final class ResultsProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, ResultsState>)?
    
    weak var coordinator: (any RootCoordinatorType)?
    
    var state = ResultsState()
    
    func receive(_ action: ResultsAction) async {
        switch action {
        case .close:
            coordinator?.dismiss()
        case .initialData:
            await presenter?.present(state)
        case .revealItems(let rows):
            let paths = rows.map { state.results[$0] }.map(\.path)
            // TODO: deal with possible multiple selection being too large
            services.workspace.activateFileViewerSelecting(paths.map(URL.init(fileURLWithPath:)))
        case .selectedRow(let row):
            state.selectedPath = state.results[row].path
            await presenter?.present(state)
        case .updateResults(let sortDescriptors):
            state.results = updatedResults(sortDescriptors)
            await presenter?.present(state)
        }
    }

    func updatedResults(_ sortDescriptors: [NSSortDescriptor]) -> [SearchResult] {
        let sortDescriptors = sortDescriptors.map {
            SortDescriptor.init($0, comparing: SortableSearchResult.self)
        }
        var sortableArray = state.results.map(SortableSearchResult.init(searchResult:))
        sortableArray.sort(using: sortDescriptors.compactMap {$0})
        return sortableArray.map(SearchResult.init(sortableSearchResult:))
    }
}
