import ArgumentParser
import Foundation
import Mustache
import Yams

struct MustacheAppError: Error, CustomStringConvertible {
    let description: String

    init(_ description: String) {
        self.description = description
    }
}

@main
struct MustacheApp: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mustache",
        abstract: """
        Mustache is a logic-less templating system for rendering
        text files.
        """,
        usage: """
        mustache <context-filename> <template-filename>
        mustache - <template-filename>
        """,
        discussion: """
        The mustache command processes a Mustache template with a context 
        defined in YAML/JSON. While the template is always loaded from a file
        the context can be supplied to the process either from a file or from
        stdin.

        Examples:
        mustache context.yml template.mustache
        cat context.yml | mustache - template.mustache
        """
    )

    @Argument(help: "Context file")
    var contextFile: String

    @Argument(help: "Mustache template file")
    var templateFile: String

    func run() throws {
        let renderer = Renderer()
        guard let templateString = loadString(filename: self.templateFile) else {
            throw MustacheAppError("Failed to load template file \(self.templateFile)")
        }
        let contextStrings = try loadContextFiles(filename: self.contextFile)
        let rendered = try renderer.render(template: templateString, contexts: contextStrings)
        if rendered.last?.isNewline == true {
            print(rendered, terminator: "")
        } else {
            print(rendered)
        }
    }

    /// Load file into string
    func loadString(filename: some StringProtocol) -> String? {
        guard let data = FileManager.default.contents(atPath: String(filename)) else { return nil }
        return String(decoding: data, as: Unicode.UTF8.self)
    }

    /// Pass stdin into a string
    func loadStdin() -> String {
        let input = AnyIterator { readLine(strippingNewline: false) }.joined(separator: "")
        return input
    }

    /// Load context strings
    func loadContextFiles(filename: String) throws -> [String] {
        var contexts: [String] = []
        let files = filename.split(separator: ",")

        for file in files {
            if file == "-" {
                contexts.append(self.loadStdin())
            } else {
                guard let string = loadString(filename: file) else {
                    throw MustacheAppError("Failed to load context file \(filename)")
                }
                contexts.append(string)
            }
        }
        return contexts
    }

    struct Renderer {
        func render(template: String, contexts: [String]) throws -> String {
            let compiledTemplate = try MustacheTemplate(string: template)
            let context = try loadCombinedYaml(contexts: contexts)
            return compiledTemplate.render(context)
        }

        func loadCombinedYaml(contexts: [String]) throws -> Any {
            func merge(_ object: Any, into base: Any?) -> Any {
                if let objectDictionary = object as? [String: Any], var baseDictionary = base as? [String: Any] {
                    for (key, value) in objectDictionary {
                        baseDictionary[key] = merge(value, into: baseDictionary[key])
                    }
                    return baseDictionary
                } else {
                    return object
                }
            }

            guard var object = try contexts.first.map({ try loadYaml(string: String($0)) }) else {
                throw MustacheAppError("No contexts provided")
            }
            let restOfContexts = contexts.dropFirst()
            for context in restOfContexts {
                let additionalObject = try loadYaml(string: context)
                object = merge(additionalObject, into: object)
            }
            return object
        }

        func loadYaml(string: String) throws -> Any {
            func convertObject(_ object: Any) -> Any {
                guard var dictionary = object as? [String: Any] else { return object }
                for (key, value) in dictionary {
                    dictionary[key] = convertObject(value)
                }
                return dictionary
            }

            guard let yaml = try Yams.load(yaml: string) else {
                throw MustacheAppError("YAML context file is empty")
            }
            return convertObject(yaml)
        }
    }
}
