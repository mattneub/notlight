@testable import NotLight3
import AppKit

final class MockWorkspace: WorkspaceType {
    var methodsCalled = [String]()
    var urls = [URL]()
    var file: String?
    var imageToReturn = NSImage()
    var urlToOpen: URL?

    func activateFileViewerSelecting(_ urls: [URL]) {
        methodsCalled.append(#function)
        self.urls = urls
    }

    func icon(forFile file: String) -> NSImage {
        methodsCalled.append(#function)
        self.file = file
        return imageToReturn
    }

    func open(_ urlToOpen: URL) -> Bool {
        methodsCalled.append(#function)
        self.urlToOpen = urlToOpen
        return true
    }

}
