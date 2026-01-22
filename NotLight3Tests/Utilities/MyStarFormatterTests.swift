import Testing
@testable import NotLight3
import AppKit

private struct MyStarFormatterTests {
    let subject = MyStarFormatter()

    @Test("stringForObject: strips off asterisks")
    func stringForObject() {
        #expect(subject.string(for: "") == "")
        #expect(subject.string(for: "*") == "")
        #expect(subject.string(for: "**") == "")
        #expect(subject.string(for: "test") == "test")
        #expect(subject.string(for: "*test*") == "test")
    }

    @Test("getObjectValue: adds asterisks")
    func getObjectValue() throws {
        var result: AnyObject? = "" as NSString
        //
        var ok = subject.getObjectValue(&result, for: "", errorDescription: nil)
        #expect(ok == true)
        var realResult = try #require(result! as? NSString)
        #expect((realResult as String) == "**")
        //
        ok = subject.getObjectValue(&result, for: "*", errorDescription: nil)
        #expect(ok == true)
        realResult = try #require(result! as? NSString)
        #expect((realResult as String) == "**")
        //
        ok = subject.getObjectValue(&result, for: "test", errorDescription: nil)
        #expect(ok == true)
        realResult = try #require(result! as? NSString)
        #expect((realResult as String) == "*test*")
    }
}
