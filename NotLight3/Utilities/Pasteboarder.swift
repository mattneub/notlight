import AppKit

protocol PasteboarderType {
    func putOnPasteboard(_ text: String)
}

final class Pasteboarder: PasteboarderType {
    func putOnPasteboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.declareTypes([.string], owner: nil)
        pasteboard.setString(text, forType: .string)
    }
}
