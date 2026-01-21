enum ResultsAction: Equatable {
    case close
    case columnWidths([ColumnWidth]) // meaning, here they are
    case initialData
    case requestColumnWidths([String])
    case revealItems(forRows: IndexSet)
    case selectedRow(Int)
    case updateResults([NSSortDescriptor])
}

struct ColumnWidth: Equatable, Codable {
    let name: String
    let width: CGFloat
}
