import AppKit

/// Protocol that describes NSApplication so we can mock it for testing.
protocol ApplicationType {
    var optionKeyDown: Bool { get }
}

extension NSApplication: ApplicationType {
    var optionKeyDown: Bool {
        currentEvent?.modifierFlags.contains(.option) ?? false
    }
}
