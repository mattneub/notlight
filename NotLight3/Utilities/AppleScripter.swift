import AppKit

protocol AppleScripterType {
    func executeScript() -> String
}

final class AppleScripter: AppleScripterType {
    /// The script. By creating it as a property and performing a trial execution, we cause
    /// the runtime to ask for permission to script the Finder at the time this class
    /// is instantiated, quite separate from the first time the user clicks the Finder button.
    let appleScript: NSAppleScript? = {
        let text = """
        try
            tell application "Finder"
                get POSIX path of (target of Finder window 1 as alias)
            end tell
        end try
        """
        let script = NSAppleScript(source: text)
        script?.executeAndReturnError(nil) // would compileAndReturnError have been sufficient?
        return script
    }()

    func executeScript() -> String {
        let result: NSAppleEventDescriptor? = appleScript?.executeAndReturnError(nil)
        return result?.stringValue ?? ""
    }
}
