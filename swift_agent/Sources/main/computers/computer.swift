
import Foundation

struct EnvState {
    let screenshot: Data
    let url: String
}

protocol Computer {
    func screenSize() -> (Int, Int)
    func clickAt(x: Int, y: Int) -> EnvState
    func hoverAt(x: Int, y: Int) -> EnvState
    func typeTextAt(x: Int, y: Int, text: String, pressEnter: Bool, clearBeforeTyping: Bool) -> EnvState
    func scrollDocument(direction: String) -> EnvState
    func scrollAt(x: Int, y: Int, direction: String, magnitude: Int) -> EnvState
    func wait5Seconds() -> EnvState
    func goBack() -> EnvState
    func goForward() -> EnvState
    func search() -> EnvState
    func navigate(url: String) -> EnvState
    func keyCombination(keys: [String]) -> EnvState
    func dragAndDrop(x: Int, y: Int, destinationX: Int, destinationY: Int) -> EnvState
    func currentState() -> EnvState
    func close()
}
