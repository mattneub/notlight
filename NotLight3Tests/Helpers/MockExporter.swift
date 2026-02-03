@testable import NotLight3

final class MockExporter: ExporterType {
    var methodsCalled = [String]()
    var term: String?
    var paths = [URL]()

    func saveSearch(search: String, paths: [URL]) {
        methodsCalled.append(#function)
        self.term = search
        self.paths = paths
    }
}
