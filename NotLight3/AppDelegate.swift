import AppKit

@MainActor
var services: Services = Services()

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    var rootCoordinator: RootCoordinatorType = RootCoordinator()

    /// Object that will tell the root coordinator to create the main module, only once in the
    /// lifetime of the app.
    private lazy var moduleCreation = Oncer { [weak self] in
        if let mainViewController = NSApplication.shared.mainWindow?.contentViewController as? MainViewController {
            self?.rootCoordinator.createMainModule(mainViewController: mainViewController)
        }
    }

    func applicationDidFinishLaunching(_ aNotification: Notification) {
    }

    func applicationDidBecomeActive(_ notif: Notification) {
        // Create module here because `didFinishLaunching` is too soon to know the main window
        unlessTesting {
            try? moduleCreation.doYourThing(Void()) // ensure the main module is created
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }

//    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
//        return true
//    }


}

