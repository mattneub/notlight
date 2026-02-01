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
            type: "howdy",
            operator: "=="
        )
        #expect(result == "howdy == \"testing\"")
    }

    @Test("makeQuery: uses operator")
    func makeQueryOperator() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: false,
            type: "howdy",
            operator: "!="
        )
        #expect(result == "howdy != \"testing\"")
    }

    @Test("makeQuery: if caseInsensitive, adds c")
    func makeQueryDisplayNameC() throws {
        let result = subject.makeQuery(
            term: "testing",
            caseInsensitive: true,
            diacriticInsensitive: false,
            wordBased: false,
            type: "kMDItemDisplayName",
            operator: "=="
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
            type: "kMDItemDisplayName",
            operator: "=="
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
            type: "kMDItemDisplayName",
            operator: "=="
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
            type: "kMDItemDisplayName",
            operator: "=="
        )
        #expect(result == "kMDItemDisplayName == \"testing\"cdw")
    }

    @Test("makeQuery: if type is kMDItemFSCreatorCode, translates into number")
    func makeQueryCreatorCode() {
        let result = subject.makeQuery(
            term: "MSWD",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: false,
            type: "kMDItemFSCreatorCode",
            operator: "=="
        )
        #expect(result == "kMDItemFSCreatorCode == \"1297307460\"")
    }

    @Test("makeQuery: if type is kMDItemFSTypeCode, translates into number")
    func makeQueryTypeCode() {
        let result = subject.makeQuery(
            term: "W8BN",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: false,
            type: "kMDItemFSTypeCode",
            operator: "=="
        )
        #expect(result == "kMDItemFSTypeCode == \"1463304782\"")
    }

    @Test("makeQuery: if type is kMDItemContentType, translates extension into UTType identifier")
    func makeQueryExtension() {
        let result = subject.makeQuery(
            term: "doc",
            caseInsensitive: false,
            diacriticInsensitive: false,
            wordBased: false,
            type: "kMDItemContentType",
            operator: "=="
        )
        #expect(result == "kMDItemContentType == \"com.microsoft.word.doc\"")
    }
}
