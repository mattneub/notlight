enum MainAction: Equatable {
    case autoContainsMode(Bool)
    case caseInsensitive(Bool)
    case diacriticInsensitive(Bool)
    case initialState
    case insertContains
    case `operator`(String)
    case returnInSearchField(String)
    case searchType(Int)
    case stop
    case termChanged(String)
    case wordBased(Bool)
}
