import AppKit

/// Application that modifies the rules for quitting with respect to sheet management:
/// we can quit even if sheet is showing, by dismissing and then terminating.
/// This takes two prongs: sometimes we get a terminate event, but
/// if user chooses quit from the Dock menu or tries to restart, we don't.
/// So we also have to grab Quit apple event (notice we install this _late_).
@objc(MyApplication) // otherwise the name is munged and we can't say it easily in Info.plist etc.
class MyApplication: NSApplication {
    override func terminate(_ sender: Any?) {
        self.windows.forEach { $0.contentViewController?.dismiss(self) }
        super.terminate(self)
    }

    override func finishLaunching() {
        super.finishLaunching()
        // install handler for quit apple event
        NSAppleEventManager.shared().setEventHandler(
            self,
            andSelector: #selector(handleQuitAE),
            forEventClass: kCoreEventClass,
            andEventID: kAEQuitApplication
        )
    }

    @objc func handleQuitAE(_ event: NSAppleEventDescriptor, reply: NSAppleEventDescriptor) {
        self.terminate(self)
    }

}
