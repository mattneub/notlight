import Testing
@testable import NotLight3
import AppKit
import UniformTypeIdentifiers

private struct ImporterTests {
    let subject = Importer()
    let panel = MockOpenSavePanel()
    let application = MockApplication()
    let bundle = MockBundle()

    init() {
        services.openPanelFactory = MockOpenPanelFactory(mockPanel: panel)
        services.application = application
        services.bundle = bundle
        bundle.urlToReturn = Bundle.main.url(forResource: "search", withExtension: "dtd") // need real dtd
    }

    @Test("loadSearch: prepares panel correctly")
    func loadSearch() async throws {
        panel.response = .cancel
        #expect(throws: XMLAnalysisError.general) {
            _ = try subject.loadSearch()
        }
        #expect(panel.allowedContentTypes == [.xml])
        #expect(panel.title == "Load Search")
        #expect(panel.message == "Load a saved search (an XML file):")
        #expect(panel.methodsCalled == ["runModal()"])
    }

    @Test("loadSearch: loads correctly constructed XML file as a search")
    func loadSearchLoad() throws {
        panel.response = .OK
        let url = URL.temporaryDirectory.appendingPathComponent("test.xml")
        panel._url = url
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <search>
            <query>howdy</query>
            <paths>
                <path>file:///a/b/c/</path>
            </paths>
        </search>
        """
        try? FileManager.default.removeItem(at: url)
        try xml.write(to: url, atomically: false, encoding: .utf8)
        let result = try subject.loadSearch()
        #expect(result.0 == "howdy")
        #expect(result.1 == ["file:///a/b/c/"])
    }

    @Test("loadSearch: if no dtd validation, throws dtd error")
    func loadSearchDTD() throws {
        panel.response = .OK
        let url = URL.temporaryDirectory.appendingPathComponent("test.xml")
        panel._url = url
        let xml = """
        <?xml version="1.0" encoding="UTF-8"?>
        <search>
            <querynot>howdy</querynot>
            <paths>
                <path>file:///a/b/c/</path>
            </paths>
        </search>
        """
        try? FileManager.default.removeItem(at: url)
        try xml.write(to: url, atomically: false, encoding: .utf8)
        #expect(throws: XMLAnalysisError.general) {
            _ = try subject.loadSearch()
        }
        #expect(application.methodsCalled == ["presentError(_:)"])
        let error = try #require(application.error as? XMLAnalysisError)
        #expect(error == .dtd)
    }

    @Test("loadSearch: if other problem, throws general error")
    func loadSearchGeneral() throws {
        panel.response = .OK
        let url = URL.temporaryDirectory.appendingPathComponent("test.xml")
        panel._url = url
        let xml = """
        not xml
        """
        try? FileManager.default.removeItem(at: url)
        try xml.write(to: url, atomically: true, encoding: .utf8)
        #expect(throws: XMLAnalysisError.general) {
            _ = try subject.loadSearch()
        }
        #expect(application.methodsCalled == ["presentError(_:)"])
        let error = try #require(application.error as? XMLAnalysisError)
        #expect(error == .general)
    }
}

private final class MockOpenPanelFactory: OpenPanelFactoryType {
    let mockPanel: NSOpenPanel

    init(mockPanel: NSOpenPanel) {
        self.mockPanel = mockPanel
    }

    func makeOpenPanel() -> NSOpenPanel {
        mockPanel
    }
}
