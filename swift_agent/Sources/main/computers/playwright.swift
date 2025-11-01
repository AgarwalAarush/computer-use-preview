
class PlaywrightComputer: Computer {
    let initialUrl: String
    let highlightMouse: Bool

    init(initialUrl: String, highlightMouse: Bool) {
        self.initialUrl = initialUrl
        self.highlightMouse = highlightMouse
    }

    func screenSize() -> (Int, Int) {
        fatalError("Not implemented")
    }

    func clickAt(x: Int, y: Int) -> EnvState {
        fatalError("Not implemented")
    }

    func hoverAt(x: Int, y: Int) -> EnvState {
        fatalError("Not implemented")
    }

    func typeTextAt(x: Int, y: Int, text: String, pressEnter: Bool, clearBeforeTyping: Bool) -> EnvState {
        fatalError("Not implemented")
    }

    func scrollDocument(direction: String) -> EnvState {
        fatalError("Not implemented")
    }

    func scrollAt(x: Int, y: Int, direction: String, magnitude: Int) -> EnvState {
        fatalError("Not implemented")
    }

    func wait5Seconds() -> EnvState {
        fatalError("Not implemented")
    }

    func goBack() -> EnvState {
        fatalError("Not implemented")
    }

    func goForward() -> EnvState {
        fatalError("Not implemented")
    }

    func search() -> EnvState {
        fatalError("Not implemented")
    }

    func navigate(url: String) -> EnvState {
        fatalError("Not implemented")
    }

    func keyCombination(keys: [String]) -> EnvState {
        fatalError("Not implemented")
    }

    func dragAndDrop(x: Int, y: Int, destinationX: Int, destinationY: Int) -> EnvState {
        fatalError("Not implemented")
    }

    func currentState() -> EnvState {
        fatalError("Not implemented")
    }

    func close() {
        fatalError("Not implemented")
    }
}
