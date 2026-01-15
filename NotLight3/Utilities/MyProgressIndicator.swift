import AppKit

/// Subclass that gives a progress indicator an `isAnimating` property which, amazingly, it lacks otherwise.
final class MyProgressIndicator: NSProgressIndicator {
    var isAnimating = false
    override func startAnimation(_ sender: Any?) {
        super.startAnimation(sender)
        isAnimating = true
    }
    override func stopAnimation(_ sender: Any?) {
        super.stopAnimation(sender)
        isAnimating = false
    }
}
