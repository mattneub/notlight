protocol QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool
    ) throws -> String
}

final class QueryStringBuilder: QueryStringBuilderType {
    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool
    ) throws -> String {
        var queryString = "kMDItemDisplayName == \"\(term)\""
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
        // unfortunately there's a long-standing bug: NSPredicate `init?(forMetadataQueryString)`
        // with a bad string does not gracefully return nil but raises an NSException
        // so we dry run the proposed string in the domain of our Objective-C exception catcher
        // and if it raises, we throw in good order
        do {
            try ExceptionCatcher.catchException {
                _ = NSPredicate(fromMetadataQueryString: queryString)
            }
        } catch {
            throw SearcherError.badQuery
        }
        return queryString
    }
}
