import AppKit

protocol WorkspaceType {
    func activateFileViewerSelecting(_: [URL])
}

extension NSWorkspace: WorkspaceType {}
