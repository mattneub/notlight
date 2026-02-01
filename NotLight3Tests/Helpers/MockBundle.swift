@testable import NotLight3

final class MockBundle: BundleType {
    var methodsCalled = [String]()
    var name: String?
    var ext: String?
    var subdirectory: String?
    var urlToReturn: URL?

    func url(
        forResource name: String?,
        withExtension ext: String?
    ) -> URL? {
        methodsCalled.append(#function)
        self.name = name
        self.ext = ext
        return urlToReturn
    }

    func url(
        forResource name: String?,
        withExtension ext: String?,
        subdirectory: String?,
    ) -> URL? {
        methodsCalled.append(#function)
        self.name = name
        self.ext = ext
        self.subdirectory = subdirectory
        return urlToReturn
    }
}
