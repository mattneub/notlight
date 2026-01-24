struct SearchKey: Equatable, Codable {
    var key: String
    var title: String
    var blurb: String
    var id: UUID = UUID()

    enum CodingKeys: String, CodingKey {
        case key = "key"
        case title = "title"
        case blurb = "blurb"
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
