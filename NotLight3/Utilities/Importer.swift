import AppKit
import UniformTypeIdentifiers

protocol ImporterType {
    func loadSearch() throws -> (String, [String])
}

final class Importer: ImporterType {
    func loadSearch() throws -> (String, [String]) {
        let open = services.openPanelFactory.makeOpenPanel()
        open.allowedContentTypes = [.xml]
        open.title = "Load Search"
        open.message = "Load a saved search (an XML file):"
        let result = open.runModal()
        do {
            if result == .OK {
                if let path = open.url {
                    let xmlDoc = try XMLDocument(contentsOf: path, options: [])
                    let output = try validateSearch(xmlDoc)
                    return output
                }
            } else {
                throw XMLAnalysisError.cancelled
            }
        } catch {
            let errorToThrow = error as? XMLAnalysisError ?? XMLAnalysisError.general
            _ = services.application.presentError(errorToThrow)
        }
        throw XMLAnalysisError.general
    }

    func validateSearch(_ xmlDoc: XMLDocument) throws(XMLAnalysisError) -> (String, [String]) {
        // hey, I've got a DTD!
        // none of these .general errors should actually occur
        guard let url = services.bundle.url(forResource: "search", withExtension: "dtd") else {
            throw .general
        }
        guard let dtd = try? XMLDTD(contentsOf: url, options: []) else {
            throw .general
        }
        xmlDoc.dtd = dtd
        dtd.name = "search" // thank you, Jim Correia
        do {
            try xmlDoc.validate()
        } catch {
            throw .dtd
        }
        guard let root = xmlDoc.rootElement() else {
            throw .general
        }
        guard let query = try? root.nodes(forXPath: "query").first?.stringValue else {
            throw .general
        }
        guard let paths = try? root.nodes(forXPath: "paths/path").compactMap({ $0.stringValue }) else {
            throw .general
        }
        return (query, paths)
    }

}

enum XMLAnalysisError: LocalizedError {
    case dtd
    case general
    case cancelled
    var errorDescription: String? { // the bold title of the alert
        "Could not open the XML file."
    }
    var recoverySuggestion: String? { // the normal second paragraph of the alert
        switch self {
        case .dtd:
            "The XML document does not appear to be a saved search."
        case .general:
            "There was a problem analyzing the XML."
        default: nil
        }
    }
}
