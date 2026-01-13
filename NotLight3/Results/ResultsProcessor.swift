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
        }
    }
}
