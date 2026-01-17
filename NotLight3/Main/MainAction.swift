enum MainAction: Equatable {
    case caseInsensitive(Bool)
    case diacriticInsensitive(Bool)
    case initialState
    case `operator`(String)
    case returnInSearchField(String)
    case searchType(Int)
    case stop
    case wordBased(Bool)
}
