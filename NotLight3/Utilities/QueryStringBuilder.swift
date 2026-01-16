protocol QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool,
        type: String
    ) -> String
}

final class QueryStringBuilder: QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool,
        type: String
    ) -> String {
        var queryString = "\(type) == \"\(term)\""
        // add modifiers; NB! no space before modifiers!!!!!
        if caseInsensitive {
            queryString.append("c")
        }
        if diacriticInsensitive {
            queryString.append("d")
        }
        if wordBased {
            queryString.append("w")
        }
        return queryString
    }
}
