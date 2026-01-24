final class SearchKeysProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<Void, SearchKeysState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = SearchKeysState()

    func receive(_ action: SearchKeysAction) async {
        switch action {
        case .initialData:
            await presenter?.present(state)
        }
    }

}
