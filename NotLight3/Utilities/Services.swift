import AppKit

final class Services {
    var alertFactory: any AlertFactoryType = AlertFactory()
    var application: any ApplicationType = NSApplication.shared
    var beeper: any BeeperType = Beeper()
    var bundle: any BundleType = Bundle.main
    var exporter: any ExporterType = Exporter()
    var importer: any ImporterType = Importer()
    var openPanelFactory: any OpenPanelFactoryType = OpenPanelFactory()
    var pasteboarder: any PasteboarderType = Pasteboarder()
    var persistence: any PersistenceType = Persistence()
    var queryFactory = QueryFactory()
    var queryStringBuilder: any QueryStringBuilderType = QueryStringBuilder()
    var savePanelFactory: any SavePanelFactoryType = SavePanelFactory()
    var searcher: any SearcherType = Searcher()
    var userDefaults: any UserDefaultsType = UserDefaults.standard
    var workspace: any WorkspaceType = NSWorkspace.shared
}
