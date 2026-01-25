enum SearchKeysEffect: Equatable {
    case blurb(String)
    case changed(row: Int, column: Int, text: String)
    case editLastRow
}
