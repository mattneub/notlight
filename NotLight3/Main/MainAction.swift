import AppKit

enum MainAction: Equatable {
    case autoContainsMode(Bool)
    case caseInsensitive(Bool)
    case diacriticInsensitive(Bool)
    case finder
    case initialState
    case insertContains
    case keyPopupIndex(Int)
    case `operator`(String)
    case performSearch(String, SearchJoiner)
    case scopes([URL])
    case showDateAssistant
    case showFileIcons
    case showFileSizes
    case showImportExport(NSView, NSRect)
    case showModDates
    case showSearchKeys
    case stop
    case termChanged(String)
    case wordBased(Bool)
}
