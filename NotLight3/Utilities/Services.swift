import AppKit

final class Services {
    var bundle: any BundleType = Bundle.main
    var queryFactory = QueryFactory()
    var queryStringBuilder: any QueryStringBuilderType = QueryStringBuilder()
    var searcher: any SearcherType = Searcher()
    var workspace: any WorkspaceType = NSWorkspace.shared
}
