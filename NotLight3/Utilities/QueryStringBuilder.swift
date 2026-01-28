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

// TODO: translate content type, type code, creator code
/*
 case "kMDItemContentType" :
 let uti = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
 self.term as CFString, nil)
 if let uti = uti {
 let utiString = uti.takeRetainedValue() as String
 if !(utiString.hasPrefix("dyn.")) { // "dyn." means LS had to make up something
 translatedTerm = utiString // got it
 break
 }
 }
 // if we get here, we tried and failed to convert to UTI
 let err = NSError(domain: "NotLight", code: 0, userInfo: [
 NSLocalizedDescriptionKey : "Invalid Extension",
 NSLocalizedRecoverySuggestionErrorKey : "Could not resolve extension to UTI."
 ])
 NSApp.presentError(err)
 return
 case "kMDItemFSTypeCode", "kMDItemFSCreatorCode":
 let n = NSNumber.from_fourcc(self.term) // extension, see AppDelegate
 translatedTerm = n.stringValue

 */
