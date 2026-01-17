@testable import NotLight3

final class MockQueryStringBuilder: QueryStringBuilderType {
    var methodsCalled = [String]()
    var term: String?
    var caseInsensitive: Bool?
    var diacriticInsensitive: Bool?
    var wordBased: Bool?
    var type: String?
    var operatorString: String?
    var queryStringToReturn = ""

    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool,
        type: String,
        operator: String
    ) -> String {
        methodsCalled.append(#function)
        self.term = term
        self.caseInsensitive = caseInsensitive
        self.diacriticInsensitive = diacriticInsensitive
        self.wordBased = wordBased
        self.type = type
        self.operatorString = `operator`
        return queryStringToReturn
    }

}
