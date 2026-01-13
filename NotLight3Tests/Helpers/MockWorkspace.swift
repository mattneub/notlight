@testable import NotLight3
import Foundation

final class MockWorkspace: WorkspaceType {
    var methodsCalled = [String]()
    var urls = [URL]()

    func activateFileViewerSelecting(_ urls: [URL]) {
        methodsCalled.append(#function)
        self.urls = urls
    }
}
