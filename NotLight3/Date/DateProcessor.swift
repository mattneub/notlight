final class DateProcessor: Processor {
    weak var coordinator: (any RootCoordinatorType)?

    weak var presenter: (any ReceiverPresenter<Void, DateState>)?

    var state = DateState()

    func receive(_ action: DateAction) async {}
}
