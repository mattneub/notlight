enum MainAction: Equatable {
    case caseInsensitive(Bool)
    case diacriticInsensitive(Bool)
    case initialState
    case returnInSearchField(String)
    case stop
    case wordBased(Bool)
}
