import AppKit

final class Services {
    var application: any ApplicationType = NSApplication.shared
    var bundle: any BundleType = Bundle.main
    var queryFactory = QueryFactory()
    var queryStringBuilder: any QueryStringBuilderType = QueryStringBuilder()
    var searcher: any SearcherType = Searcher()
    var workspace: any WorkspaceType = NSWorkspace.shared
}
