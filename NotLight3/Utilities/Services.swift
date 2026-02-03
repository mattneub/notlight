import AppKit

final class Services {
    var application: any ApplicationType = NSApplication.shared
    var beeper: any BeeperType = Beeper()
    var bundle: any BundleType = Bundle.main
    var exporter: any ExporterType = Exporter()
    var importer: any ImporterType = Importer()
    var persistence: any PersistenceType = Persistence()
    var queryFactory = QueryFactory()
    var queryStringBuilder: any QueryStringBuilderType = QueryStringBuilder()
    var searcher: any SearcherType = Searcher()
    var userDefaults: any UserDefaultsType = UserDefaults.standard
    var workspace: any WorkspaceType = NSWorkspace.shared
}
