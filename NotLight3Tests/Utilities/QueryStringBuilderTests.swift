import Testing
@testable import NotLight3

private struct QueryStringBuilderTests {
    let subject = QueryStringBuilder()

    @Test("makeQuery: uses type")
    func makeQueryType() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: false,
            type: "howdy"
        )
        #expect(result == "howdy == \"testing\"")
    }

    @Test("makeQuery: if caseInsensitive, adds c")
    func makeQueryDisplayNameC() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: true,
            diacriticInsensitive: false,
            wordBased: false,
            type: "kMDItemDisplayName"
        )
        #expect(result == "kMDItemDisplayName == \"testing\"c")
    }

    @Test("makeQuery: if diacriticInsensitive, adds d")
    func makeQueryDisplayNameD() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: false,
            diacriticInsensitive: true,
            wordBased: false,
            type: "kMDItemDisplayName"
        )
        #expect(result == "kMDItemDisplayName == \"testing\"d")
    }

    @Test("makeQuery: if wordBased, adds w")
    func makeQueryDisplayNameW() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: true,
            type: "kMDItemDisplayName"
        )
        #expect(result == "kMDItemDisplayName == \"testing\"w")
    }

    @Test("makeQuery: if all three, adds cdw")
    func makeQueryDisplayNameCDW() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: true,
            diacriticInsensitive: true,
            wordBased: true,
            type: "kMDItemDisplayName"
        )
        #expect(result == "kMDItemDisplayName == \"testing\"cdw")
    }


}
