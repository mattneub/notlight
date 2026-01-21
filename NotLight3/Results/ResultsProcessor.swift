final class ResultsProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<ResultsEffect, ResultsState>)?
    
    weak var coordinator: (any RootCoordinatorType)?
    
    var state = ResultsState()
    
    func receive(_ action: ResultsAction) async {
        switch action {
        case .close:
            coordinator?.dismiss()
        case .columnWidths(let array):
            services.persistence.saveColumns(array)
        case .initialData:
            if services.persistence.loadShowFileIcons() {
                // the searcher didn't fetch icons, so to display them we must fetch them now
                state.results.modifyEach { result in
                    result.updateImage(services.workspace.icon(forFile: result.path))
                }
            }
            state.columnVisibility["icon"] = services.persistence.loadShowFileIcons()
            state.columnVisibility["date"] = services.persistence.loadShowModDates()
            state.columnVisibility["size"] = services.persistence.loadShowFileSizes()
            await presenter?.present(state)
        case .requestColumnWidths(let array):
            if let columns = services.persistence.loadColumns(array) {
                await presenter?.receive(.columnWidths(columns))
            }
        case .revealItems(let rows):
            let paths = rows.map { state.results[$0] }.map(\.path)
            // TODO: deal with possible multiple selection being too large
            services.workspace.activateFileViewerSelecting(
                paths.map { URL(filePath: $0, directoryHint: .inferFromPath, relativeTo: nil) }
            )
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
