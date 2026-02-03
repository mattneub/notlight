@testable import NotLight3
import AppKit

final class MockAlert: NSAlert {
    var methodsCalled = [String]()
    var forWindow: NSWindow?

    override func beginSheetModal(for window: NSWindow) async -> NSApplication.ModalResponse {
        methodsCalled.append(#function)
        self.forWindow = window
        return .OK
    }
}

