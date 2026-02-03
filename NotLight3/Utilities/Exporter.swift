import AppKit
import UniformTypeIdentifiers

protocol ExporterType {
    func saveSearch(search: String, paths: [URL]) async
}

final class Exporter: ExporterType {
    func saveSearch(search: String, paths: [URL]) async {
        let save = services.savePanelFactory.makeSavePanel()
        save.allowedContentTypes = [.xml]
        save.title = "Save Search"
        save.message = "Save the current search as an XML file:"
        save.canSelectHiddenExtension = true
        let result = save.runModal()
        if result == .OK {
            if let path = save.url {
                do {
                    let xmlData = try self.currentSearchAsXML(search: search, paths: paths)
                    try xmlData.write(to: path, options: .atomic)
                } catch {
                    _ = services.application.presentError(error)
                }
            }
        }
    }

    func currentSearchAsXML(search: String, paths: [URL]) throws(XMLConstructionError) -> Data {
        guard let rootElement = XMLNode.element(
            withName: "search"
        ) as? XMLElement else {
            throw .oops
        }
        guard let queryElement = XMLNode.element(
            withName: "query",
            stringValue: search
        ) as? XMLElement else {
            throw .oops
        }
        let document = XMLDocument(rootElement: rootElement)
        document.version = "1.0"
        document.characterEncoding = "UTF-8"
        rootElement.addChild(queryElement)
        if paths.count > 0 {
            guard let pathsElement = XMLNode.element(
                withName: "paths"
            ) as? XMLElement else {
                throw .oops
            }
            rootElement.addChild(pathsElement)
            for path in paths {
                guard let child = XMLNode.element(
                    withName: "path",
                    stringValue: path.absoluteString
                ) as? XMLElement else {
                    throw .oops
                }
                pathsElement.addChild(child)
            }
        }
        return document.xmlData(options: .nodePrettyPrint)
    }

    enum XMLConstructionError: LocalizedError {
        case oops
        var errorDescription: String? { // the bold title of the alert
            "Could not save the search."
        }
        var recoverySuggestion: String? { // the normal second paragraph of the alert
            "There was a problem constructing the XML."
        }
    }
}
