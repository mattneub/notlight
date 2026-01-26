final class ImportExportProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, ImportExportState>)?

    weak var coordinator: (any RootCoordinatorType)?

    weak var delegate: (any ImportExportDelegate)?

    var state = ImportExportState()

    func receive(_ action: ImportExportAction) async {
        switch action {
        case .doSearch:
            coordinator?.dismiss()
            await delegate?.doSearch()
        case .initialData:
            state.currentSearch = services.persistence.loadCurrentSearch()
            await presenter?.present(state)
        case .loadSearch:
            coordinator?.dismiss()
            await delegate?.loadSearch()
        case .saveSearch:
            coordinator?.dismiss()
            await delegate?.saveSearch()
        }
    }
}

protocol ImportExportDelegate: AnyObject {
    func doSearch() async
    func loadSearch() async
    func saveSearch() async
}
