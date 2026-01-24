enum SearchKeysEffect: Equatable {
    case changed(row: Int, column: Int, text: String)
    case delete(Int)
    case editLastRow
}
