import Testing
@testable import NotLight3
import AppKit

private struct MyURLFormatterTests {
    let subject = MyURLFormatter()

    @Test("stringForObject: creates path string of URL, or nil if not file URL")
    func stringForObject() {
        #expect(subject.string(for: "howdy") == nil)
        #expect(subject.string(for: URL(string: "http://www.example.com")!) == nil)
        #expect(subject.string(for: URL(string: "file:///testing%20this")) == "/testing this")
    }

    @Test("getObjectValue: turns path string into file URL")
    func getObjectValue() throws {
        var result: AnyObject? = URL(string: "https://www.example.com")! as NSURL
        let ok = subject.getObjectValue(&result, for: "/testing", errorDescription: nil)
        #expect(ok == true)
        let realResult = try #require(result! as? NSURL)
        #expect((realResult as URL) == URL(string: "file:///testing/")!)
    }
}
