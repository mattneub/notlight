import Testing
@testable import NotLight3
import AppKit
import SnapshotTesting

private struct FolderTextFieldTests {
    let subject = FolderTextField(frame: .zero)

    @Test("view looks right")
    func looksRight() {
        subject.frame = NSRect(x: 0, y: 0, width: 200, height: 22)
        assertSnapshot(of: subject, as: .image)
    }
}
