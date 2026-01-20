@testable import NotLight3

struct MockQueryItem: QueryItemType, Equatable {
    let displayName: String?
    let path: String?
    let date: Date?
    let size: Int64?
}
