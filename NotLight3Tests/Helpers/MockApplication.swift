@testable import NotLight3
import AppKit

final class MockApplication: ApplicationType {
    var optionKeyDownToReturn = false
    var methodsCalled = [String]()
    var error: (any Error)?
    var window: NSWindow?
    var title: String?
    var filename: Bool?

    var optionKeyDown: Bool {
        optionKeyDownToReturn
    }

    func presentError(_ error: any Error) -> Bool {
        methodsCalled.append(#function)
        self.error = error
        return true
    }

    func addWindowsItem(_ window: NSWindow, title: String, filename: Bool) {
        methodsCalled.append(#function)
        self.window = window
        self.title = title
        self.filename = filename
    }

}
