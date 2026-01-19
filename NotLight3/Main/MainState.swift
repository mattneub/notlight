struct MainState: Equatable {
    /// If zero, no search is in progress. If more than zero, search is in progress and this is
    /// how many results we've accumulated so far.
    var progress: Int = 0

    var searchTypePopupContents = [[String: String]]()
    var searchTypePopupCurrentItemIndex: Int = 0
    var searchType: [String: String] {
        if searchTypePopupCurrentItemIndex < searchTypePopupContents.count {
            return searchTypePopupContents[searchTypePopupCurrentItemIndex]
        }
        return ["key": "value"]
    }

    var searchOperator: String = "=="

    var wordBased: Bool = false
    var caseInsensitive: Bool = false
    var diacriticInsensitive: Bool = false
    var autoContainsMode: Bool = false

    var scopes = [URL]()

    var term: String = ""
}
