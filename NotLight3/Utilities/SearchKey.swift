struct SearchKey: Equatable, Codable {
    var key: String
    var title: String
    var blurb: String
    let id: UUID = UUID()

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case title = "title"
        case blurb = "blurb"
    }

    /// The UUID is merely so we have something unique to stick into the diffable datasource,
    /// but it does not bear upon the essential question of whether the _data_ are the same.
    /// So implement `==` explicitly to exclude the UUID.
    static func ==(rhs: SearchKey, lhs: SearchKey) -> Bool {
        lhs.key == rhs.key && lhs.title == rhs.title && lhs.blurb == rhs.blurb
    }
}

extension SearchKey {
    mutating func update(_ text: String, forColumn column: Int) {
        switch column {
        case 0: title = text
        case 1: key = text
        case 2: blurb = text
        default: break
        }
    }
}
