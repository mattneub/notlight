import AppKit

/// Text field that absolutely refuses to show a focus ring (because setting this property
/// in the nib is insufficient).
final class MyTextField: NSTextField {
    override var focusRingType: NSFocusRingType {
        get {.none }
        set {}
    }
}
