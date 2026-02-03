final class ImportExportProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, ImportExportState>)?

    weak var coordinator: (any RootCoordinatorType)?

    weak var delegate: (any ImportExportDelegate)?

    var state = ImportExportState()

    func receive(_ action: ImportExportAction) async {
        switch action {
        case .doSearch(let searchString):
            coordinator?.dismiss()
            await delegate?.doSearch(searchString)
        case .initialData:
            state.currentSearch = services.persistence.loadCurrentSearch()
            await presenter?.present(state)
        case .loadSearch:
            coordinator?.dismiss()
            await delegate?.loadSearch()
        case .saveSearch(let searchString):
            coordinator?.dismiss()
            await delegate?.saveSearch(searchString)
        }
    }
}

protocol ImportExportDelegate: AnyObject {
    func doSearch(_: String) async
    func loadSearch() async
    func saveSearch(_: String) async
}
