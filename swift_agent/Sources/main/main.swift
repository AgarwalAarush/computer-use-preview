
import ArgumentParser
import Foundation

struct ComputerUse: ParsableCommand {
    @Option(name: .long, help: "The query for the browser agent to execute.")
    var query: String

    @Option(name: .long, help: "The computer use environment to use.")
    var env: String = "macos"

    @Option(name: .long, help: "The inital URL loaded for the computer.")
    var initialUrl: String = "https://www.google.com"

    @Flag(name: .long, help: "If possible, highlight the location of the mouse.")
    var highlightMouse: Bool = false

    @Option(name: .long, help: "Set which main model to use.")
    var model: String = "gemini-2.5-computer-use-preview-10-2025"

    @available(macOS 11.0, *)
    func run() throws {
        let computer: Computer
        switch env {
        case "playwright":
            computer = PlaywrightComputer(
                initialUrl: initialUrl,
                highlightMouse: highlightMouse
            )
        case "browserbase":
            computer = BrowserbaseComputer(
                initialUrl: initialUrl
            )
        case "macos":
            computer = MacOSComputer(
                initialUrl: initialUrl,
                highlightMouse: highlightMouse
            )
        default:
            throw NSError(domain: "", code: 1, userInfo: [NSLocalizedDescriptionKey: "Unknown environment: \(env)"])
        }

        let agent = BrowserAgent(
            browserComputer: computer,
            query: query,
            modelName: model
        )
        agent.agentLoop()

        // Keep the main thread alive to allow the agent to run.
        RunLoop.main.run()
    }
}

ComputerUse.main()
