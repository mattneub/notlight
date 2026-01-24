final class SearchKeysProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<SearchKeysEffect, SearchKeysState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = SearchKeysState()

    func receive(_ action: SearchKeysAction) async {
        switch action {
        case .add:
            state.keys.append(.init(key: "", title: "", blurb: ""))
            await presenter?.present(state)
            await presenter?.receive(.editLastRow)
        case .changed(let row, let column, let text):
            state.keys[row].update(text, forColumn: column)
            await presenter?.receive(.changed(row: row, column: column, text: text))
        case .delete(let row):
            state.keys.remove(at: row)
            await presenter?.receive(.delete(row))
        case .initialData:
            await presenter?.present(state)
        }
    }

}
