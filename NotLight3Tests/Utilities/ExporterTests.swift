import Testing
@testable import NotLight3
import AppKit
import UniformTypeIdentifiers

private struct ExporterTests {
    let subject = Exporter()
    let panel = MockOpenSavePanel()

    init() {
        services.savePanelFactory = MockSavePanelFactory(mockPanel: panel)
    }

    @Test("saveSearch: prepares panel correctly")
    func saveSearch() async {
        await subject.saveSearch(search: "howdy", paths: [URL(string: "file:///a/b/c/")!])
        #expect(panel.allowedContentTypes == [.xml])
        #expect(panel.title == "Save Search")
        #expect(panel.message == "Save the current search as an XML file:")
        #expect(panel.canSelectHiddenExtension == true)
        #expect(panel.methodsCalled == ["runModal()"])
    }

    @Test("saveSearch: saves to chosen url as correctly constructed XML file")
    func saveSearchSave() async throws {
        panel.response = .OK
        let url = URL.temporaryDirectory.appendingPathComponent("test.xml")
        panel._url = url
        await subject.saveSearch(search: "howdy", paths: [URL(string: "file:///a/b/c/")!])
        let xmlData = try Data(contentsOf: url)
        let xml = try #require(String(data: xmlData, encoding: .utf8))
        #expect(xml == """
        <?xml version="1.0" encoding="UTF-8"?>
        <search>
            <query>howdy</query>
            <paths>
                <path>file:///a/b/c/</path>
            </paths>
        </search>
        """) // it doesn't get any better than this
    }
}

private final class MockSavePanelFactory: SavePanelFactoryType {
    let mockPanel: NSSavePanel

    init(mockPanel: NSSavePanel) {
        self.mockPanel = mockPanel
    }

    func makeSavePanel() -> NSSavePanel {
        mockPanel
    }
}
