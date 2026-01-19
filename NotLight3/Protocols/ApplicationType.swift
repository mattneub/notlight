import AppKit

protocol ApplicationType {
    var optionKeyDown: Bool { get }
}

extension NSApplication: ApplicationType {
    var optionKeyDown: Bool {
        currentEvent?.modifierFlags.contains(.option) ?? false
    }
}
