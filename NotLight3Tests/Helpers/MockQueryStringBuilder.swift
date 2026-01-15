@testable import NotLight3

final class MockQueryStringBuilder: QueryStringBuilderType {
    var methodsCalled = [String]()
    var term: String?
    var caseInsensitive: Bool?
    var diacriticInsensitive: Bool?
    var wordBased: Bool?
    var queryStringToReturn = ""
    var errorToThrow: (any Error)?

    func makeQuery(
        term: String,
        caseInsensitive: Bool,
        diacriticInsensitive: Bool,
        wordBased: Bool
    ) throws -> String {
        methodsCalled.append(#function)
        self.term = term
        self.caseInsensitive = caseInsensitive
        self.diacriticInsensitive = diacriticInsensitive
        self.wordBased = wordBased
        if let errorToThrow {
            throw errorToThrow
        }
        return queryStringToReturn
    }

}
