import UniformTypeIdentifiers

protocol QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool,
        type: String,
        operator: String
    ) -> String
}

final class QueryStringBuilder: QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool,
        type: String,
        operator: String
    ) -> String {
        var term = term
        // special case translations
        if type == "kMDItemFSCreatorCode" || type == "kMDItemFSTypeCode" {
            // https://stackoverflow.com/a/31320949/341994
            term = String(NSHFSTypeCodeFromFileType("'\(term)'"))
        } else if type == "kMDItemContentType" {
            if let uttype = UTType(filenameExtension: term) {
                term = uttype.identifier
            }
        }
        var queryString = "\(type) \(`operator`) \"\(term)\""
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
