enum SearchKeysAction: Equatable {
    case add
    case blurb(String)
    case changed(row: Int, column: Int, text: String)
    case delete(Int)
    case done
    case initialData
    case selectedRow(Int)
}
