struct MainState: Equatable {
    /// If zero, no search is in progress. If more than zero, search is in progress and this is
    /// how many results we've accumulated so far.
    var progress: Int = 0
}
