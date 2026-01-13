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
            let paths = rows.map { state.results[$0] }.map(\.path) // TODO: this will break with sort
            // TODO: deal with possible multiple selection being too large
            services.workspace.activateFileViewerSelecting(paths.map(URL.init(fileURLWithPath:)))
        }
    }
}
