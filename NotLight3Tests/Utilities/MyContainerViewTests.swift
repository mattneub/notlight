import Testing
@testable import NotLight3
import AppKit

private struct MyContainerViewTests {
    let subject = MyContainerView()

    init() {
        subject.translatesAutoresizingMaskIntoConstraints = false
    }

    @Test("moving to window causes view to load its interface from nib")
    func moveToWindow() throws {
        let viewController = NSViewController()
        let window = makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        #expect(subject.wrapperView != nil)
        #expect(subject.textField != nil)
        #expect(subject.wrapperView.isDescendant(of: subject))
        #expect(subject.textField.isDescendant(of: subject))
        #expect(subject.textField is FolderTextField)
        let heightConstraint = try #require(subject.constraints.first(where: { $0.firstAttribute == .height }))
        #expect(heightConstraint.constant == 28)
        window.close()
    }

    @Test("textFieldValueChanged: calls up responder chain to folderTextFieldChanged")
    func textFieldValueChanged() {
        let viewController = MockViewController()
        let window = makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.textFieldValueChanged(subject.textField)
        #expect(viewController.methodsCalled == ["folderTextFieldChanged(_:)"])
        window.close()
    }

    @Test("doClear: sets text field string value to empty, calls up responder chain to folderTextFieldChanged")
    func doClear() {
        let viewController = MockViewController()
        let window = makeWindow(viewController: viewController)
        viewController.view.addSubview(subject)
        subject.textField.stringValue = "howdy"
        let button = NSButton()
        subject.doClear(button)
        #expect(subject.textField.stringValue == "")
        #expect(viewController.methodsCalled == ["folderTextFieldChanged(_:)"])
        window.close()
    }
}

private final class MockViewController: NSViewController {
    var methodsCalled = [String]()
    @objc func folderTextFieldChanged(_ sender: Any?) {
        methodsCalled.append(#function)
    }
}
