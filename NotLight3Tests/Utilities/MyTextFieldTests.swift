import Testing
@testable import NotLight3
import AppKit

private struct MyTextFieldTests {
    @Test("focusRingType is always none")
    func focusRingType() {
        let subject = MyTextField()
        #expect(subject.focusRingType == .none)
        subject.focusRingType = .exterior
        #expect(subject.focusRingType == .none)
    }
}
