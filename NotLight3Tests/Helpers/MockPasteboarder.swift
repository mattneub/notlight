@testable import NotLight3

final class MockPasteboarder: PasteboarderType {
    var methodsCalled = [String]()
    var text: String?

    func putOnPasteboard(_ text: String) {
        methodsCalled.append(#function)
        self.text = text
    }
}
