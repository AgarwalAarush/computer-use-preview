from typing import Optional, Dict, Any

from google import genai
from google.genai import types
from google.genai.types import Content, Part

client = genai.Client()

SYSTEM_PROMPT = """You are operating a macOS computer. Today's date is October 15, 2023, so ignore any other date provided.
* To provide an answer to the user, *do not use any tools* and output your answer on a separate line. IMPORTANT: Do not add any formatting or additional punctuation/text, just output the answer by itself after two empty lines.
* Make sure you review the entire screen content, scrolling or opening additional views as needed, before deciding something is unavailable.
* You can open an app from anywhere, for example via Spotlight (⌘+Space) or the Dock, even if you cannot currently see its icon.
* Unless explicitly told otherwise, make sure to save any changes you make (⌘+S) and confirm the save is complete.
* If text is cut off or incomplete, expand the window or scroll to read the full content before providing an answer.
* IMPORTANT: Complete the given task EXACTLY as stated. DO NOT assume completing a similar task is correct. If something is missing, look for it by scrolling or searching first.
* When editing text, use the `type` tool rather than simulating individual keystrokes.
* Avoid relying on Control Center quick toggles for system changes; use the System Settings app unless instructed otherwise.
* The given task may already be completed. If so, there is no need to do anything further.
"""


def open_app(app_name: str, intent: Optional[str] = None) -> Dict[str, Any]:
    """Opens an app by name.

    Args:
        app_name: Name of the app to open (any string).
        intent: Optional deep-link or action to pass when launching, if the app supports it.

    Returns:
        JSON payload acknowledging the request (app name and optional intent).
    """
    return {"status": "requested_open", "app_name": app_name, "intent": intent}


def long_press_at(x: int, y: int) -> Dict[str, int]:
    """Long press at a specific screen coordinate.

    Args:
        x: X coordinate (absolute), scaled to the device screen width (pixels).
        y: Y coordinate (absolute), scaled to the device screen height (pixels).

    Returns:
        Object with the coordinates pressed and the duration used.
    """
    return {"x": x, "y": y}


def go_home() -> Dict[str, str]:
    """Requests returning to the desktop (Finder).

    Returns:
        A small acknowledgment payload.
    """
    return {"status": "home_requested"}


#  Build function declarations
CUSTOM_FUNCTION_DECLARATIONS = [
    types.FunctionDeclaration.from_callable(client=client, callable=open_app),
    types.FunctionDeclaration.from_callable(client=client, callable=long_press_at),
    types.FunctionDeclaration.from_callable(client=client, callable=go_home),
]

# Exclude browser functions (kept for parity with upcoming Computer Use support)
EXCLUDED_PREDEFINED_FUNCTIONS = [
    "search",
    "navigate",
    "hover_at",
    "scroll_document",
    "go_forward",
    "key_combination",
    "drag_and_drop",
]


# Utility function to construct a GenerateContentConfig
def make_generate_content_config() -> genai.types.GenerateContentConfig:
    """Return a fixed GenerateContentConfig with the custom macOS functions."""
    # NOTE: The current python SDK does not yet expose the Computer Use tool wiring,
    # so the excluded predefined functions above are not applied here.
    return genai.types.GenerateContentConfig(
        systemInstruction=SYSTEM_PROMPT,
        tools=[
            types.Tool(function_declarations=CUSTOM_FUNCTION_DECLARATIONS),
        ],
    )


# Create the content with user message
contents: list[Content] = [
    Content(
        role="user",
        parts=[
            # text instruction
            Part(text="Open Chrome, then long-press at 200,400."),
        ],
    )
]

# Build your fixed config (from helper)
config = make_generate_content_config()

# Generate content with the configured settings
response = client.models.generate_content(
    model="gemini-2.5-computer-use-preview-10-2025",
    contents=contents,
    config=config,
)

print(response)
