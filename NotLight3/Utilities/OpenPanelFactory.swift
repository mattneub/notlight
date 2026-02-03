import AppKit

protocol OpenPanelFactoryType {
    func makeOpenPanel() -> NSOpenPanel
}

final class OpenPanelFactory: OpenPanelFactoryType {
    func makeOpenPanel() -> NSOpenPanel {
        NSOpenPanel()
    }
}
