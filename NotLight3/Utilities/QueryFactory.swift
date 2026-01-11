import AppKit

final class QueryFactory {
    var factory: () -> NSMetadataQuery = { NSMetadataQuery() }
    func makeQuery() -> NSMetadataQuery {
        factory()
    }
}
