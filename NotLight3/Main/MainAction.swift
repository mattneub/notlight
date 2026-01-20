
enum MainAction: Equatable {
    case autoContainsMode(Bool)
    case caseInsensitive(Bool)
    case diacriticInsensitive(Bool)
    case initialState
    case insertContains
    case `operator`(String)
    case performSearch(String, SearchJoiner)
    case scopes([URL])
    case searchType(Int)
    case showFileIcons
    case showFileSizes
    case showModDates
    case stop
    case termChanged(String)
    case wordBased(Bool)
}
