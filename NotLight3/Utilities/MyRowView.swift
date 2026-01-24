import AppKit

/// Table row view that lets us set the color used when the row is selected.
final class MyRowView: NSTableRowView {
    convenience init(selectionColor: NSColor) {
        self.init(frame: .zero)
        self.selectionColor = selectionColor
    }

    var selectionColor: NSColor = .lightGray

    override func drawSelection(in rect: NSRect) {
        selectionColor.setFill()
        rect.fill()
    }
}
