
import AppKit
import Foundation
import CoreGraphics
import Carbon

class MacOSComputer: Computer {
    let initialUrl: String
    let highlightMouse: Bool
    var currentUrl: String = "macos://desktop"

    let MACOS_KEY_MAP: [String: CGKeyCode] = [
        "control": CGKeyCode(kVK_Control),
        "ctrl": CGKeyCode(kVK_Control),
        "shift": CGKeyCode(kVK_Shift),
        "alt": CGKeyCode(kVK_Option),
        "option": CGKeyCode(kVK_Option),
        "command": CGKeyCode(kVK_Command),
        "cmd": CGKeyCode(kVK_Command),
        "meta": CGKeyCode(kVK_Command),
        "enter": CGKeyCode(kVK_Return),
        "return": CGKeyCode(kVK_Return),
        "tab": CGKeyCode(kVK_Tab),
        "escape": CGKeyCode(kVK_Escape),
        "esc": CGKeyCode(kVK_Escape),
        "space": CGKeyCode(kVK_Space),
        "pageup": CGKeyCode(kVK_PageUp),
        "pagedown": CGKeyCode(kVK_PageDown),
        "f1": CGKeyCode(kVK_F1),
        "f2": CGKeyCode(kVK_F2),
        "f3": CGKeyCode(kVK_F3),
        "f4": CGKeyCode(kVK_F4),
        "f5": CGKeyCode(kVK_F5),
        "f6": CGKeyCode(kVK_F6),
        "f7": CGKeyCode(kVK_F7),
        "f8": CGKeyCode(kVK_F8),
        "f9": CGKeyCode(kVK_F9),
        "f10": CGKeyCode(kVK_F10),
        "f11": CGKeyCode(kVK_F11),
        "f12": CGKeyCode(kVK_F12),
        "left": CGKeyCode(kVK_LeftArrow),
        "right": CGKeyCode(kVK_RightArrow),
        "up": CGKeyCode(kVK_UpArrow),
        "down": CGKeyCode(kVK_DownArrow),
        "delete": CGKeyCode(kVK_ForwardDelete),
        "backspace": CGKeyCode(kVK_Delete)
    ]

    init(initialUrl: String, highlightMouse: Bool) {
        self.initialUrl = initialUrl
        self.highlightMouse = highlightMouse
    }

    func screenSize() -> (Int, Int) {
        if let screen = NSScreen.main {
            let rect = screen.frame
            return (Int(rect.size.width), Int(rect.size.height))
        }
        return (0, 0)
    }

    func clickAt(x: Int, y: Int) -> EnvState {
        moveMouse(x: x, y: y)
        let mouseLocation = CGPoint(x: x, y: y)
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: mouseLocation, mouseButton: .left)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: mouseLocation, mouseButton: .left)
        mouseDown?.post(tap: .cghidEventTap)
        mouseUp?.post(tap: .cghidEventTap)
        waitForUI()
        return currentState()
    }

    func hoverAt(x: Int, y: Int) -> EnvState {
        moveMouse(x: x, y: y)
        waitForUI()
        return currentState()
    }

    func typeTextAt(x: Int, y: Int, text: String, pressEnter: Bool, clearBeforeTyping: Bool) -> EnvState {
        moveMouse(x: x, y: y)
        clickAt(x: x, y: y)
        waitForUI()

        if clearBeforeTyping {
            keyCombination(keys: ["command", "a"])
            keyCombination(keys: ["delete"])
            waitForUI()
        }

        for char in text {
            typeKey(key: String(char))
            waitForUI(delay: 0.01)
        }

        if pressEnter {
            keyCombination(keys: ["enter"])
            waitForUI()
        }

        return currentState()
    }

    func scrollDocument(direction: String) -> EnvState {
        let (width, height) = screenSize()
        return scrollAt(x: width / 2, y: height / 2, direction: direction, magnitude: 600)
    }

    func scrollAt(x: Int, y: Int, direction: String, magnitude: Int) -> EnvState {
        moveMouse(x: x, y: y)
        let scrollEvent = CGEvent(scrollWheelEvent2Source: nil, units: .pixel, wheelCount: 1, wheel1: Int32(direction == "down" ? -magnitude : (direction == "up" ? magnitude : 0)), wheel2: Int32(direction == "right" ? -magnitude : (direction == "left" ? magnitude : 0)), wheel3: 0)
        scrollEvent?.post(tap: .cghidEventTap)
        waitForUI()
        return currentState()
    }

    func wait5Seconds() -> EnvState {
        Thread.sleep(forTimeInterval: 5)
        return currentState()
    }

    func goBack() -> EnvState {
        keyCombination(keys: ["command", "["])
        waitForUI()
        return currentState()
    }

    func goForward() -> EnvState {
        keyCombination(keys: ["command", "]"])
        waitForUI()
        return currentState()
    }

    func search() -> EnvState {
        return navigate(url: "https://www.google.com")
    }

    func navigate(url: String) -> EnvState {
        var normalizedUrl = url
        if !normalizedUrl.hasPrefix("http://") && !normalizedUrl.hasPrefix("https://") {
            normalizedUrl = "https://" + normalizedUrl
        }
        let process = Process()
        process.launchPath = "/usr/bin/open"
        process.arguments = [normalizedUrl]
        process.launch()
        currentUrl = normalizedUrl
        Thread.sleep(forTimeInterval: 2)
        return currentState()
    }

    func keyCombination(keys: [String]) -> EnvState {
        let keyCodes = keys.map { MACOS_KEY_MAP[$0.lowercased()] ?? 0 }
        let source = CGEventSource(stateID: .hidSystemState)

        for keyCode in keyCodes {
            let keyDown = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: true)
            keyDown?.post(tap: .cghidEventTap)
        }

        for keyCode in keyCodes.reversed() {
            let keyUp = CGEvent(keyboardEventSource: source, virtualKey: keyCode, keyDown: false)
            keyUp?.post(tap: .cghidEventTap)
        }

        waitForUI()
        return currentState()
    }

    func dragAndDrop(x: Int, y: Int, destinationX: Int, destinationY: Int) -> EnvState {
        moveMouse(x: x, y: y)
        let mouseDown = CGEvent(mouseEventSource: nil, mouseType: .leftMouseDown, mouseCursorPosition: CGPoint(x: x, y: y), mouseButton: .left)
        mouseDown?.post(tap: .cghidEventTap)
        waitForUI()
        moveMouse(x: destinationX, y: destinationY)
        let mouseUp = CGEvent(mouseEventSource: nil, mouseType: .leftMouseUp, mouseCursorPosition: CGPoint(x: destinationX, y: destinationY), mouseButton: .left)
        mouseUp?.post(tap: .cghidEventTap)
        waitForUI()
        return currentState()
    }

    func currentState() -> EnvState {
        let displayID = CGMainDisplayID()
        let image = CGDisplayCreateImage(displayID)
        let bitmap = NSBitmapImageRep(cgImage: image!)
        let data = bitmap.representation(using: .png, properties: [:])!
        return EnvState(screenshot: data, url: currentUrl)
    }

    func close() {}

    private func moveMouse(x: Int, y: Int) {
        let mouseLocation = CGPoint(x: x, y: y)
        let mouseMove = CGEvent(mouseEventSource: nil, mouseType: .mouseMoved, mouseCursorPosition: mouseLocation, mouseButton: .left)
        mouseMove?.post(tap: .cghidEventTap)
    }

    private func waitForUI(delay: TimeInterval = 0.5) {
        Thread.sleep(forTimeInterval: delay)
    }

    private func typeKey(key: String) {
        let source = CGEventSource(stateID: .hidSystemState)
        let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: true)
        keyDown?.keyboardSetUnicodeString(stringLength: key.count, unicodeString: [unichar](key.utf16))
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 0, keyDown: false)
        keyUp?.keyboardSetUnicodeString(stringLength: key.count, unicodeString: [unichar](key.utf16))
        keyUp?.post(tap: .cghidEventTap)
    }
}
