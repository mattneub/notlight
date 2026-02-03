import AppKit

final class MockOpenSavePanel: NSOpenPanel {
    var _url: URL?
    var response: NSApplication.ModalResponse = .cancel
    var methodsCalled = [String]()
    override var url: URL? {
        get {
            _url
        }
        set {}
    }

    override func runModal() -> NSApplication.ModalResponse {
        methodsCalled.append(#function)
        return response
    }
}
