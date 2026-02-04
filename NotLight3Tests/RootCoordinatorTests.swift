import Testing
@testable import NotLight3
import AppKit
import WaitWhile

private struct RootCoordinatorTests {
    let subject = RootCoordinator()

    @Test("createMainModule: creates the main module")
    func createMainModule() throws {
        let window = makeWindow(viewController: NSViewController())
        subject.createMainModule(window: window)
        let processor = try #require(subject.mainProcessor as? MainProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? MainViewController)
        #expect(viewController.processor === processor)
        #expect(subject.mainViewController === viewController)
        #expect(window.contentViewController === viewController)
        window.close()
    }

    @Test("showResults: assembles the results module, sets the state, presents the view controller")
    func showResults() async throws {
        let state = ResultsState(results: [.init(displayName: "name", path: "path", date: .distantPast, size: 10)])
        let mainViewController = NSViewController()
        let window = makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        subject.showResults(state: state)
        let processor = try #require(subject.resultsProcessor as? ResultsProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? ResultsViewController)
        #expect(viewController.processor === processor)
        await #while(mainViewController.presentedViewControllers?.first == nil)
        #expect(mainViewController.presentedViewControllers?.first === viewController)
        window.close()
    }

    @Test("showSearchKeys: assembles the search keys module, presents the view controller")
    func showSearchKeys() async throws {
        subject.mainProcessor = MainProcessor()
        let mainViewController = NSViewController()
        let window = makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        subject.showSearchKeys()
        let processor = try #require(subject.searchKeysProcessor as? SearchKeysProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.delegate === subject.mainProcessor)
        let viewController = try #require(processor.presenter as? SearchKeysViewController)
        #expect(viewController.processor === processor)
        await #while(mainViewController.presentedViewControllers?.first == nil)
        #expect(mainViewController.presentedViewControllers?.first === viewController)
        window.close()
    }

    @Test("showDateAssistant: assembles the date module, creates window and shows it")
    func showDateAssistant() async throws {
        let application = MockApplication()
        services.application = application
        subject.showDateAssistant()
        let processor = try #require(subject.dateProcessor as? DateProcessor)
        #expect(processor.coordinator === subject)
        let viewController = try #require(processor.presenter as? DateViewController)
        #expect(viewController.processor === processor)
        await #while(subject.dateAssistantWindow == nil)
        let window = try #require(subject.dateAssistantWindow)
        #expect(window is NSPanel)
        #expect(window.contentViewController == viewController)
        #expect(window.isResizable == false)
        #expect(window.title == "Date Assistant")
        #expect(window.frame.size == CGSize(width: 316, height: 222 + 24)) // titlebar height
        #expect(window.isReleasedWhenClosed == false)
        #expect(application.methodsCalled == ["addWindowsItem(_:title:filename:)"])
        #expect(application.window === window)
        #expect(application.title == window.title)
        #expect(application.filename == false)
        window.close()
    }

    @Test("showImportExport: assembles import export module, presents as popover")
    func showImportExport() async throws {
        subject.mainProcessor = MainProcessor()
        let mainViewController = NSViewController()
        let window = makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        let rect = NSRect(x: 0, y: 0, width: 100, height: 200)
        subject.showImportExport(sourceRect: rect, sourceView: mainViewController.view, edge: .minY)
        let processor = try #require(subject.importExportProcessor as? ImportExportProcessor)
        #expect(processor.coordinator === subject)
        #expect(processor.delegate === subject.mainProcessor)
        let viewController = try #require(processor.presenter as? ImportExportViewController)
        #expect(viewController.processor === processor)
        await #while(mainViewController.presentedViewControllers?.first == nil)
        #expect(mainViewController.presentedViewControllers?.first === viewController)
        window.close()
    }

    @Test("dismiss: dismisses the presented view controller")
    func dismiss() throws {
        let mainViewController = NSViewController()
        let window = makeWindow(viewController: mainViewController)
        subject.mainViewController = mainViewController
        let presented = NSViewController()
        mainViewController.presentAsSheet(presented)
        #expect(mainViewController.presentedViewControllers?.count == 1)
        subject.dismiss()
        #expect(mainViewController.presentedViewControllers?.count == 0)
        window.close()
    }

    @Test("bringMainToFront: brings the main window key and front")
    func bringMainToFront() async {
        let window = MyWindow()
        window.isReleasedWhenClosed = false
        subject.mainWindow = window
        subject.bringMainToFront()
        #expect(window.methodsCalled == ["makeKeyAndOrderFront(_:)"])
        window.close()
    }

    @Test("showAlert: puts up alert")
    func showAlert() async {
        let alert = MockAlert()
        services.alertFactory = MockAlertFactory(mockAlert: alert)
        let window = makeWindow(viewController: NSViewController())
        subject.mainWindow = window
        await subject.showAlert(title: "Title", message: "Message")
        #expect(alert.alertStyle == .informational)
        #expect(alert.messageText == "Title")
        #expect(alert.informativeText == "Message")
        #expect(alert.methodsCalled == ["beginSheetModal(for:)"])
        #expect(alert.forWindow === window)
        window.close()
    }
}

private final class MyWindow: NSWindow {
    var methodsCalled = [String]()
    override func makeKeyAndOrderFront(_ sender: Any?) {
        methodsCalled.append(#function)
    }
}

private final class MockAlertFactory: AlertFactoryType {
    let mockAlert: NSAlert

    init(mockAlert: NSAlert) {
        self.mockAlert = mockAlert
    }

    func makeAlert() -> NSAlert {
        mockAlert
    }
}
