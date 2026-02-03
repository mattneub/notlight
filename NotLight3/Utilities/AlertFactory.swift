import AppKit

protocol AlertFactoryType {
    func makeAlert() -> NSAlert
}

final class AlertFactory: AlertFactoryType {
    func makeAlert() -> NSAlert {
        NSAlert()
    }
}
