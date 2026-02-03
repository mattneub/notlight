struct MainState: Equatable {
    var progress: Int = 0
    var progressTotal: Int? // nil means indefinite
    var progressVisible = false

    var keyPopupContents = [SearchKey]()
    var keyPopupIndex: Int = 0
    var currentKey: SearchKey {
        if (0..<keyPopupContents.count).contains(keyPopupIndex) {
            return keyPopupContents[keyPopupIndex]
        }
        return keyPopupContents.first ?? .init(key: "", title: "", blurb: "") // shouldn't happen
    }

    var searchOperator: String = "=="

    var wordBased: Bool = false
    var caseInsensitive: Bool = false
    var diacriticInsensitive: Bool = false
    var autoContainsMode: Bool = false

    var scopes = [URL]()

    var term: String = ""
}
