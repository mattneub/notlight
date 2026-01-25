enum SearchKeysAction: Equatable {
    case add
    case blurb(String)
    case changed(row: Int, column: Int, text: String)
    case delete(Int)
    case initialData
    case selectedRow(Int)
}
