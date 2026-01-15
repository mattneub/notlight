import AppKit

final class Services {
    var queryFactory = QueryFactory()
    var queryStringBuilder: any QueryStringBuilderType = QueryStringBuilder()
    var searcher: any SearcherType = Searcher()
    var workspace: any WorkspaceType = NSWorkspace.shared
}
