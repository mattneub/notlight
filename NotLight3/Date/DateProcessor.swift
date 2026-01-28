final class DateProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, DateState>)?

    var state = DateState()

    func receive(_ action: DateAction) async {
        switch action {
        case .agoPopup(let index):
            state.agoIndex = index
        case .datePicker(let date):
            state.absoluteDate = date
        case .initialData:
            await presenter?.present(state)
        case .predefinedPopup(let index):
            state.predefinedIndex = index
        case .relativePopup(let index):
            state.relativeIndex = index
        case .relativeQuantity(let value):
            state.relativeQuantity = value
        case .useAbsolute: break
        case .usePredefined: break
        case .useRelative: break
        }
    }
}
