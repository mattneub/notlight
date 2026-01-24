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
