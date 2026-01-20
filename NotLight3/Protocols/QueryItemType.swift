import AppKit

/// Protocol that acts as a much nicer public face of NSMetadataItem — and also allows us to
/// mock NSMetadataItem for testing.
protocol QueryItemType {
    var displayName: String? { get }
    var path: String? { get }
    var date: Date? { get }
    var size: Int64? { get }
}

/// Extension that conforms NSMetadataItem to our protocol, hiding the ugliness of key names
/// and the `value(forAttribute:)` method.
extension NSMetadataItem: QueryItemType {
    var displayName: String? {
        value(forAttribute: NSMetadataItemDisplayNameKey) as? String
    }
    var path: String? {
        value(forAttribute: NSMetadataItemPathKey) as? String
    }
    var date: Date? {
        value(forAttribute: NSMetadataItemFSContentChangeDateKey) as? Date
    }
    var size: Int64? {
        value(forAttribute: NSMetadataItemFSSizeKey) as? Int64
    }
}
