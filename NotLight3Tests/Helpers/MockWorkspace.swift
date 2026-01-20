@testable import NotLight3
import AppKit

final class MockWorkspace: WorkspaceType {
    var methodsCalled = [String]()
    var urls = [URL]()
    var file: String?
    var imageToReturn = NSImage()

    func activateFileViewerSelecting(_ urls: [URL]) {
        methodsCalled.append(#function)
        self.urls = urls
    }

    func icon(forFile file: String) -> NSImage {
        methodsCalled.append(#function)
        self.file = file
        return imageToReturn
    }

}
