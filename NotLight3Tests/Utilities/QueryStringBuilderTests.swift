import Testing
@testable import NotLight3

private struct QueryStringBuilderTests {
    let subject = QueryStringBuilder()

    @Test("makeQuery: currently uses display name")
    func makeQueryDisplayName() throws {
        let result = try subject.makeQuery(term: "testing", caseInsensitive: false, diacriticInsensitive: false, wordBased: false)
        #expect(result == "kMDItemDisplayName == \"testing\"")
    }

    @Test("makeQuery: if caseInsensitive, adds c")
    func makeQueryDisplayNameC() throws {
        let result = try subject.makeQuery(term: "testing", caseInsensitive: true, diacriticInsensitive: false, wordBased: false)
        #expect(result == "kMDItemDisplayName == \"testing\"c")
    }

    @Test("makeQuery: if diacriticInsensitive, adds d")
    func makeQueryDisplayNameD() throws {
        let result = try subject.makeQuery(term: "testing", caseInsensitive: false, diacriticInsensitive: true, wordBased: false)
        #expect(result == "kMDItemDisplayName == \"testing\"d")
    }

    @Test("makeQuery: if wordBased, adds w")
    func makeQueryDisplayNameW() throws {
        let result = try subject.makeQuery(term: "testing", caseInsensitive: false, diacriticInsensitive: false, wordBased: true)
        #expect(result == "kMDItemDisplayName == \"testing\"w")
    }

    @Test("makeQuery: if all three, adds cdw")
    func makeQueryDisplayNameCDW() throws {
        let result = try subject.makeQuery(term: "testing", caseInsensitive: true, diacriticInsensitive: true, wordBased: true)
        #expect(result == "kMDItemDisplayName == \"testing\"cdw")
    }


}
