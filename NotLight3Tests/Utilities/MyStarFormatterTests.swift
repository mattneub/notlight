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
    func getObjectValue() {
        var result: NSString = ""
        withUnsafeMutablePointer(to: &result) { pointer in
            let autoReleaser = AutoreleasingUnsafeMutablePointer<AnyObject?>(pointer)
            let ok = subject.getObjectValue(autoReleaser, for: "", errorDescription: nil)
            #expect(ok == true)
        }
        #expect(result == "**")
        withUnsafeMutablePointer(to: &result) { pointer in
            let autoReleaser = AutoreleasingUnsafeMutablePointer<AnyObject?>(pointer)
            let ok = subject.getObjectValue(autoReleaser, for: "*", errorDescription: nil)
            #expect(ok == true)
        }
        #expect(result == "**")
        withUnsafeMutablePointer(to: &result) { pointer in
            let autoReleaser = AutoreleasingUnsafeMutablePointer<AnyObject?>(pointer)
            let ok = subject.getObjectValue(autoReleaser, for: "test", errorDescription: nil)
            #expect(ok == true)
        }
        #expect(result == "*test*")
    }
}
