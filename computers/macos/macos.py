import io
import subprocess
import time
from typing import Literal, Optional

import pyautogui

from ..computer import Computer, EnvState


MACOS_KEY_MAP = {
    "control": "ctrl",
    "ctrl": "ctrl",
    "shift": "shift",
    "alt": "option",
    "option": "option",
    "command": "command",
    "cmd": "command",
    "meta": "command",
    "enter": "enter",
    "return": "enter",
    "tab": "tab",
    "escape": "esc",
    "esc": "esc",
    "space": "space",
    "pageup": "pageup",
    "pagedown": "pagedown",
    "f1": "f1",
    "f2": "f2",
    "f3": "f3",
    "f4": "f4",
    "f5": "f5",
    "f6": "f6",
    "f7": "f7",
    "f8": "f8",
    "f9": "f9",
    "f10": "f10",
    "f11": "f11",
    "f12": "f12",
    "left": "left",
    "right": "right",
    "up": "up",
    "down": "down",
    "delete": "delete",
    "backspace": "backspace",
}


def _normalize_key(key: str) -> str:
    return MACOS_KEY_MAP.get(key.lower(), key.lower())


class MacOSComputer(Computer):
    """Computer implementation that sends real macOS input events."""

    def __init__(
        self,
        screen_size: Optional[tuple[int, int]] = None,
        initial_url: str = "https://www.google.com",
        search_engine_url: str = "https://www.google.com",
        highlight_mouse: bool = False,
    ):
        # Setting FAILSAFE to False prevents pyautogui from raising if the cursor
        # hits a screen corner while the agent moves the mouse.
        pyautogui.FAILSAFE = False
        self._screen_size_override = screen_size
        self._initial_url = initial_url
        self._search_engine_url = search_engine_url
        self._highlight_mouse = highlight_mouse
        self._current_url = "macos://desktop"

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        return False

    def screen_size(self) -> tuple[int, int]:
        if self._screen_size_override:
            return self._screen_size_override
        size = pyautogui.size()
        return size.width, size.height

    def open_web_browser(self) -> EnvState:
        # Open the initial URL in the default browser.
        self.navigate(self._initial_url)
        return self.current_state()

    def click_at(self, x: int, y: int) -> EnvState:
        self._move_mouse(x, y)
        pyautogui.click(x=x, y=y)
        self._wait_for_ui()
        return self.current_state()

    def hover_at(self, x: int, y: int) -> EnvState:
        self._move_mouse(x, y)
        self._wait_for_ui()
        return self.current_state()

    def type_text_at(
        self,
        x: int,
        y: int,
        text: str,
        press_enter: bool,
        clear_before_typing: bool,
    ) -> EnvState:
        self._move_mouse(x, y)
        pyautogui.click(x=x, y=y)
        self._wait_for_ui()

        if clear_before_typing:
            pyautogui.hotkey("command", "a")
            pyautogui.press("delete")
            self._wait_for_ui()

        pyautogui.typewrite(text, interval=0.01)
        self._wait_for_ui()

        if press_enter:
            pyautogui.press("enter")
            self._wait_for_ui()

        return self.current_state()

    def scroll_document(
        self, direction: Literal["up", "down", "left", "right"]
    ) -> EnvState:
        center_x, center_y = (value // 2 for value in self.screen_size())
        return self.scroll_at(center_x, center_y, direction, magnitude=600)

    def scroll_at(
        self,
        x: int,
        y: int,
        direction: Literal["up", "down", "left", "right"],
        magnitude: int,
    ) -> EnvState:
        self._move_mouse(x, y)
        if direction == "up":
            pyautogui.scroll(magnitude)
        elif direction == "down":
            pyautogui.scroll(-magnitude)
        elif direction == "left":
            pyautogui.hscroll(magnitude)
        elif direction == "right":
            pyautogui.hscroll(-magnitude)
        else:
            raise ValueError(f"Unsupported direction: {direction}")
        self._wait_for_ui()
        return self.current_state()

    def wait_5_seconds(self) -> EnvState:
        time.sleep(5)
        return self.current_state()

    def go_back(self) -> EnvState:
        pyautogui.hotkey("command", "[")
        self._wait_for_ui()
        return self.current_state()

    def go_forward(self) -> EnvState:
        pyautogui.hotkey("command", "]")
        self._wait_for_ui()
        return self.current_state()

    def search(self) -> EnvState:
        return self.navigate(self._search_engine_url)

    def navigate(self, url: str) -> EnvState:
        normalized_url = url
        if not normalized_url.startswith(("http://", "https://")):
            normalized_url = "https://" + normalized_url
        subprocess.Popen(["open", normalized_url])
        self._current_url = normalized_url
        # Give the browser time to open or switch tabs.
        time.sleep(2)
        return self.current_state()

    def key_combination(self, keys: list[str]) -> EnvState:
        normalized_keys = [_normalize_key(k) for k in keys]
        pyautogui.hotkey(*normalized_keys)
        self._wait_for_ui()
        return self.current_state()

    def drag_and_drop(
        self, x: int, y: int, destination_x: int, destination_y: int
    ) -> EnvState:
        self._move_mouse(x, y)
        pyautogui.mouseDown(x=x, y=y)
        self._wait_for_ui()
        self._move_mouse(destination_x, destination_y)
        pyautogui.mouseUp(x=destination_x, y=destination_y)
        self._wait_for_ui()
        return self.current_state()

    def current_state(self) -> EnvState:
        screenshot = pyautogui.screenshot()
        buffer = io.BytesIO()
        screenshot.save(buffer, format="PNG")
        return EnvState(screenshot=buffer.getvalue(), url=self._current_url)

    def _move_mouse(self, x: int, y: int):
        pyautogui.moveTo(x, y, duration=0.15 if self._highlight_mouse else 0)

    def _wait_for_ui(self, delay: float = 0.5):
        time.sleep(delay)
