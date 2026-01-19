@testable import NotLight3

final class MockApplication: ApplicationType {
    var optionKeyDownToReturn = false

    var optionKeyDown: Bool {
        optionKeyDownToReturn
    }
}
