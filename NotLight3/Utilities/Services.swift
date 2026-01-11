import AppKit

final class Services {
    var queryFactory = QueryFactory()
    var searcher: any SearcherType = Searcher()
}
