import AppKit

/// Class that dumpster dives into a nib file to get an instance of our FolderTextField
/// and its corresponding "x" button.
class MyContainerView: NSView {
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet weak var wrapperView: NSView!

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let nib = NSNib(nibNamed: "MyContainerView", bundle: nil) {
            nib.instantiate(withOwner: self, topLevelObjects: nil)
            addSubview(wrapperView)
            NSLayoutConstraint.activate([
                topAnchor.constraint(equalTo: wrapperView.topAnchor),
                bottomAnchor.constraint(equalTo: wrapperView.bottomAnchor),
                leadingAnchor.constraint(equalTo: wrapperView.leadingAnchor),
                trailingAnchor.constraint(equalTo: wrapperView.trailingAnchor),
            ])
        }
    }

    @IBAction func textFieldValueChanged(_ sender: NSTextField) {
        // https://stackoverflow.com/a/49297065/341994
        tryToPerform(Selector(("folderTextFieldChanged:")), with: sender) // toss it into the air!
    }

    @IBAction func doClear(_ sender: NSButton) {
        textField.stringValue = ""
        textFieldValueChanged(textField)
    }
}
