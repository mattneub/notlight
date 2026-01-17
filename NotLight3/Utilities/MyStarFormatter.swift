import AppKit

/// Formatter that surrounds a string with asterisks automatically. Technically, it mediates
/// between a `stringValue` (display) and an `objectValue` (underlying).
nonisolated
class MyStarFormatter: Formatter {
    /// "return the NSString that textually represents the cell's object for display": the _display_
    /// of the object, its `stringValue`, has _no_ surrounding asterisks, so trim them off.
    override func string(for object: Any?) -> String? {
        guard let string = object as? String else {
            return nil
        }
        var result = ""
        // edge cases
        if string == "" || string == "*" {
            result = ""
        } else {
            // normal case: trim * from start and end
            result = string.trimmingCharacters(in: CharacterSet(charactersIn: "*"))
        }
        return result
    }

    /// "return by reference the object anObject after creating it from the string passed in.
    /// Return YES if the conversion from string to cell-content object was successful": The object
    /// here is the field's `objectValue`. No errors will happen; we just
    /// surround the string with asterisks, set it into the `object`'s `pointee`, and return true.
    override func getObjectValue(
        _ object: AutoreleasingUnsafeMutablePointer<AnyObject?>?,
        for string: String,
        errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?
    ) -> Bool {
        var result = ""
        if string == "" || string == "*" {
            result = "**"
        } else {
            let string = "*" + string.trimmingCharacters(in: CharacterSet(charactersIn: "*")) + "*"
            result = string
        }
        object?.pointee = result as NSString
        return true
    }
}
