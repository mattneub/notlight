final class DateProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, DateState>)?

    weak var delegate: (any DateDelegate)?

    var state = DateState()

    func receive(_ action: DateAction) async {
        switch action {
        case .agoPopup(let index):
            state.agoIndex = index
        case .datePicker(let date):
            state.absoluteDate = date
        case .initialData:
            state.absoluteDate = Date.now
            await presenter?.present(state)
        case .predefinedPopup(let index):
            state.predefinedIndex = index
        case .relativePopup(let index):
            state.relativeIndex = index
        case .relativeQuantity(let value):
            state.relativeQuantity = value
        case .useAbsolute:
            await delegate?.dateChosen(String(state.absoluteDate.timeIntervalSinceReferenceDate.rounded()))
        case .usePredefined:
            await delegate?.dateChosen(state.predefinedKey)
        case .useRelative:
            await delegate?.dateChosen(state.relativeKey + "(\(state.agoKey)\(state.relativeQuantityAdjusted))")
        }
    }
}

protocol DateDelegate: AnyObject {
    func dateChosen(_: String) async
}
