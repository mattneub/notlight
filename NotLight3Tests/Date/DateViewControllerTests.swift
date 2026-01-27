import Testing
@testable import NotLight3
import AppKit

private struct DateViewControllerTests {
    let subject = DateViewController()

    @Test("viewDidAppear: sets up window")
    func viewDidAppear() {
        let window = makeWindow(viewController: subject)
        #expect(window.minSize == CGSize(width: 316, height: 222))
        #expect(window.isResizable == false)
    }
}
