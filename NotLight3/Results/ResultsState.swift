struct ResultsState: Equatable {
    var columnVisibility = [String: Bool]()
    var queryString: String = ""
    var results = [SearchResult]()
    var selectedPath: String = ""
}
