import Testing
@testable import NotLight3
import AppKit

private struct NSViewTests {
    @Test("subviews(ofType:) returns array of type, recursing or not, including hidden or not")
    func subviewsOfType() {
        let view = NSView()
        view.addSubview(NSButton())
        let otherView = NSView()
        view.addSubview(otherView)
        otherView.isHidden = true
        otherView.addSubview(NSTextView())
        let textView = NSTextView()
        view.addSubview(textView)
        textView.isHidden = true
        view.addSubview(NSButton())
        #expect(view.subviews(ofType: NSSwitch.self).count == 0)
        #expect(view.subviews(ofType: NSTextView.self).count == 0)
        #expect(view.subviews(ofType: NSTextView.self, includeHidden: true).count == 2)
        let buttons = view.subviews(ofType: NSButton.self)
        #expect(buttons.count == 2)
        let subview = NSView()
        view.addSubview(subview)
        subview.addSubview(NSSwitch())
        #expect(view.subviews(ofType: NSSwitch.self).count == 1)
        #expect(view.subviews(ofType: NSSwitch.self, recursing: false).count == 0)
    }
}
