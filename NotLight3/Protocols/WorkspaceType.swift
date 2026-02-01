import AppKit

/// Protocol that describes NSWorkspace so we can mock it for testing.
protocol WorkspaceType {
    func activateFileViewerSelecting(_: [URL])
    func icon(forFile: String) -> NSImage
    func open(_: URL) -> Bool
}

extension NSWorkspace: WorkspaceType {}
