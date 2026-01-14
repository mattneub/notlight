enum ResultsAction: Equatable {
    case close
    case initialData
    case revealItems(forRows: IndexSet)
    case selectedRow(Int)
    case updateResults([NSSortDescriptor])
}
