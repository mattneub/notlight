final class SearchKeysProcessor: Processor {
    weak var presenter: (any ReceiverPresenter<SearchKeysEffect, SearchKeysState>)?

    weak var coordinator: (any RootCoordinatorType)?

    var state = SearchKeysState()

    func receive(_ action: SearchKeysAction) async {
        switch action {
        case .add:
            state.keys.append(.init(key: "", title: "", blurb: ""))
            state.selectedRow = -1
            await presenter?.present(state)
            await presenter?.receive(.editLastRow)
        case .blurb (let text):
            if state.selectedRow > -1 {
                state.keys[state.selectedRow].blurb = text
                await presenter?.receive(.blurb(text))
            }
        case .changed(let row, let column, let text):
            state.keys[row].update(text, forColumn: column)
            await presenter?.receive(.changed(row: row, column: column, text: text))
        case .delete(let row):
            state.keys.remove(at: row)
            state.selectedRow = -1
            await presenter?.present(state)
        case .initialData:
            await presenter?.present(state)
        case .selectedRow(let row):
            state.selectedRow = row
            await presenter?.present(state)
        }
    }

}
