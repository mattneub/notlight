enum ResultsAction: Equatable {
    case close
    case initialData
    case selectedRow(Int)
    case revealItems(forRows: IndexSet)
}
