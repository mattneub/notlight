enum ResultsAction: Equatable {
    case close
    case columnWidths([ColumnWidth]) // meaning, here they are
    case copy(IndexSet, Bool) // Bool means force copy display name
    case initialData
    case requestColumnWidths([String])
    case revealItem(forRow: Int)
    case selectedRow(Int)
    case updateResults([NSSortDescriptor])
}

struct ColumnWidth: Equatable, Codable {
    let name: String
    let width: CGFloat
}
