import AppKit

protocol SavePanelFactoryType {
    func makeSavePanel() -> NSSavePanel
}

final class SavePanelFactory: SavePanelFactoryType {
    func makeSavePanel() -> NSSavePanel {
        NSSavePanel()
    }
}
