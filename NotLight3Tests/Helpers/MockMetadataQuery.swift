@testable import NotLight3

nonisolated
final class MockMetadataQuery: NSMetadataQuery {
    override init() { super.init() }

    var _predicate: NSPredicate?
    var _searchScopes: [Any] = []
    var _resultCount: Int = 0
    var _results: [QueryItemType] = []

    var methodsCalled = [String]()

    override var predicate: NSPredicate? {
        get { nil }
        set { _predicate = newValue }
    }

    override var searchScopes: [Any] {
        get { [] }
        set { _searchScopes = newValue }
    }

    override var resultCount: Int {
        _resultCount
    }

    override func start() -> Bool {
        methodsCalled.append(#function)
        return true
    }

    override func stop() {
        methodsCalled.append(#function)
    }

    override func result(at index: Int) -> Any {
        if _results.indices.contains(index) {
            return _results[index]
        } else {
            return MockQueryItem(displayName: nil, path: nil)
        }
    }

}
