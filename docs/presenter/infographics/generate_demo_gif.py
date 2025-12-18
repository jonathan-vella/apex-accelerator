#!/usr/bin/env python3
"""
Generate Animated Demo GIF for Agentic InfraOps.

Creates a simulated terminal animation showing the 7-step agentic workflow
with realistic typing effects and command output.

Requirements:
    pip install pillow

Usage:
    python generate_demo_gif.py

Output:
    generated/demo-workflow.gif
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


# =============================================================================
# Configuration
# =============================================================================

# Terminal colors (dark theme)
COLORS = {
    "bg": "#1e1e1e",  # VS Code dark background
    "text": "#d4d4d4",  # Default text
    "green": "#4ec9b0",  # Success/prompt
    "blue": "#569cd6",  # Commands
    "yellow": "#dcdcaa",  # Highlights
    "orange": "#ce9178",  # Strings
    "purple": "#c586c0",  # Keywords
    "cyan": "#9cdcfe",  # Variables
    "red": "#f14c4c",  # Errors
    "dim": "#6a9955",  # Comments
    "white": "#ffffff",  # Bright white
}

# Terminal dimensions
TERM_WIDTH = 900
TERM_HEIGHT = 550
PADDING = 20
LINE_HEIGHT = 22

# Animation settings
TYPING_SPEED = 3  # frames per character
PAUSE_SHORT = 8  # frames for short pause
PAUSE_MEDIUM = 15  # frames for medium pause
PAUSE_LONG = 30  # frames for long pause
FRAME_DURATION = 50  # milliseconds per frame


# =============================================================================
# Terminal Simulation
# =============================================================================


class TerminalFrame:
    """Represents a single frame of the terminal animation."""

    def __init__(self):
        self.lines: list[list[tuple[str, str]]] = []  # [(text, color), ...]
        self.cursor_visible = True
        self.cursor_pos = (0, 0)  # (line, column)

    def add_line(self, segments: list[tuple[str, str]]):
        """Add a line with colored segments."""
        self.lines.append(segments)

    def copy(self) -> "TerminalFrame":
        """Create a deep copy of this frame."""
        new_frame = TerminalFrame()
        new_frame.lines = [line[:] for line in self.lines]
        new_frame.cursor_visible = self.cursor_visible
        new_frame.cursor_pos = self.cursor_pos
        return new_frame


def get_font(size: int = 14, bold: bool = False) -> ImageFont.FreeTypeFont:
    """Get a monospace font."""
    font_paths = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSansMono-Bold.ttf",
        "/System/Library/Fonts/Menlo.ttc",
        "C:\\Windows\\Fonts\\consola.ttf",
    ]

    for path in font_paths:
        try:
            return ImageFont.truetype(path, size)
        except (OSError, IOError):
            continue

    return ImageFont.load_default()


def render_frame(frame: TerminalFrame) -> Image.Image:
    """Render a terminal frame to an image."""
    img = Image.new("RGB", (TERM_WIDTH, TERM_HEIGHT), COLORS["bg"])
    draw = ImageDraw.Draw(img)
    font = get_font(14)

    # Draw terminal title bar
    draw.rectangle([(0, 0), (TERM_WIDTH, 30)], fill="#323232")
    draw.ellipse([(12, 10), (22, 20)], fill="#ff5f56")  # Close
    draw.ellipse([(32, 10), (42, 20)], fill="#ffbd2e")  # Minimize
    draw.ellipse([(52, 10), (62, 20)], fill="#27c93f")  # Maximize
    title_font = get_font(12)
    draw.text(
        (TERM_WIDTH // 2 - 80, 8),
        "GitHub Copilot - Agent Mode",
        font=title_font,
        fill=COLORS["dim"],
    )

    # Draw terminal content
    y = 40 + PADDING
    for line_segments in frame.lines:
        x = PADDING
        for text, color in line_segments:
            draw.text((x, y), text, font=font,
                      fill=COLORS.get(color, COLORS["text"]))
            # Approximate character width
            x += len(text) * 8.5
        y += LINE_HEIGHT

    # Draw cursor if visible
    if frame.cursor_visible and frame.lines:
        last_line = frame.lines[-1]
        cursor_x = PADDING + sum(len(t) for t, _ in last_line) * 8.5
        cursor_y = 40 + PADDING + (len(frame.lines) - 1) * LINE_HEIGHT
        draw.rectangle(
            [(cursor_x, cursor_y), (cursor_x + 8, cursor_y + LINE_HEIGHT - 4)],
            fill=COLORS["green"],
        )

    return img


# =============================================================================
# Animation Sequences
# =============================================================================


def create_workflow_animation() -> list[Image.Image]:
    """Create the full workflow animation sequence."""
    frames: list[Image.Image] = []
    terminal = TerminalFrame()

    def add_frames(count: int):
        """Add multiple copies of current frame."""
        for _ in range(count):
            frames.append(render_frame(terminal))

    def type_line(segments: list[tuple[str, str]], typing: bool = True):
        """Simulate typing a line."""
        if typing:
            current_segments: list[tuple[str, str]] = []
            for text, color in segments:
                for i in range(len(text)):
                    current_segments_copy = current_segments + \
                        [(text[: i + 1], color)]
                    terminal.lines[-1] = current_segments_copy
                    if i % TYPING_SPEED == 0:
                        frames.append(render_frame(terminal))
                current_segments.append((text, color))
            terminal.lines[-1] = segments
            add_frames(PAUSE_SHORT)
        else:
            terminal.add_line(segments)
            add_frames(2)

    # === Opening ===
    terminal.add_line([("", "text")])
    add_frames(PAUSE_MEDIUM)

    # === Step 1: User prompt ===
    terminal.lines[-1] = [("$ ", "green"), ("", "text")]
    type_line(
        [
            ("$ ", "green"),
            ("copilot ", "blue"),
            ('"Create HIPAA-compliant patient portal"', "orange"),
        ]
    )
    add_frames(PAUSE_MEDIUM)

    # Response header
    terminal.add_line([])
    type_line([("@plan", "purple"), (" - Creating implementation plan...", "dim")])
    add_frames(PAUSE_SHORT)

    # Plan output
    terminal.add_line([])
    type_line(
        [
            ("  ", "text"),
            ("✓", "green"),
            (" Analyzed requirements: ", "text"),
            ("HIPAA, patient data, portal", "cyan"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("✓", "green"),
            (" Identified components: ", "text"),
            ("App Service, SQL, Key Vault, WAF", "cyan"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("✓", "green"),
            (" Estimated resources: ", "text"),
            ("12 Azure services", "cyan"),
        ],
        typing=False,
    )
    add_frames(PAUSE_MEDIUM)

    # Approval prompt
    terminal.add_line([])
    type_line(
        [("  → ", "yellow"), ("Proceed to architecture review? ", "text"), ("[Y/n]", "dim")]
    )
    add_frames(PAUSE_SHORT)
    terminal.add_line([("  ", "text"), ("y", "green")])
    add_frames(PAUSE_MEDIUM)

    # === Step 2: Architecture ===
    terminal.add_line([])
    type_line(
        [("@azure-principal-architect", "purple"),
         (" - Reviewing architecture...", "dim")]
    )
    add_frames(PAUSE_SHORT)

    # WAF scores
    terminal.add_line([])
    type_line(
        [("  ", "text"), ("╔══════════════════════════════════════╗", "blue")], typing=False
    )
    type_line(
        [("  ", "text"), ("║  Well-Architected Framework Review   ║", "blue")], typing=False
    )
    type_line(
        [("  ", "text"), ("╠══════════════════════════════════════╣", "blue")], typing=False
    )
    type_line(
        [
            ("  ", "text"),
            ("║  ", "blue"),
            ("Security      ", "text"),
            ("█████████░", "green"),
            ("  9/10  ", "green"),
            ("║", "blue"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("║  ", "blue"),
            ("Reliability   ", "text"),
            ("████████░░", "green"),
            ("  8/10  ", "green"),
            ("║", "blue"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("║  ", "blue"),
            ("Performance   ", "text"),
            ("████████░░", "green"),
            ("  8/10  ", "green"),
            ("║", "blue"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("║  ", "blue"),
            ("Cost Optim.   ", "text"),
            ("███████░░░", "yellow"),
            ("  7/10  ", "yellow"),
            ("║", "blue"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("║  ", "blue"),
            ("Operations    ", "text"),
            ("████████░░", "green"),
            ("  8/10  ", "green"),
            ("║", "blue"),
        ],
        typing=False,
    )
    type_line(
        [("  ", "text"), ("╚══════════════════════════════════════╝", "blue")], typing=False
    )
    add_frames(PAUSE_MEDIUM)

    # Approval
    terminal.add_line([])
    type_line(
        [("  → ", "yellow"), ("Proceed to Bicep planning? ", "text"), ("[Y/n]", "dim")]
    )
    add_frames(PAUSE_SHORT)
    terminal.add_line([("  ", "text"), ("y", "green")])
    add_frames(PAUSE_MEDIUM)

    # === Step 3: Bicep Plan ===
    terminal.add_line([])
    type_line([("@bicep-plan", "purple"),
              (" - Creating module structure...", "dim")])
    add_frames(PAUSE_SHORT)

    # Module list
    terminal.add_line([])
    type_line(
        [
            ("  ", "text"),
            ("📁", "text"),
            (" infra/bicep/patient-portal/", "cyan"),
        ],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("├── ", "dim"), ("main.bicep", "text"),
         ("         (orchestrator)", "dim")],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("├── ", "dim"),
         ("network.bicep", "text"), ("      (VNet, NSGs)", "dim")],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("├── ", "dim"),
         ("security.bicep", "text"), ("     (Key Vault, WAF)", "dim")],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("├── ", "dim"),
         ("database.bicep", "text"), ("     (Azure SQL)", "dim")],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("├── ", "dim"),
         ("app-service.bicep", "text"), ("  (Web App)", "dim")],
        typing=False,
    )
    type_line(
        [("     ", "text"), ("└── ", "dim"),
         ("monitoring.bicep", "text"), ("   (Log Analytics)", "dim")],
        typing=False,
    )
    add_frames(PAUSE_MEDIUM)

    # Approval
    terminal.add_line([])
    type_line(
        [("  → ", "yellow"), ("Generate Bicep templates? ", "text"), ("[Y/n]", "dim")]
    )
    add_frames(PAUSE_SHORT)
    terminal.add_line([("  ", "text"), ("y", "green")])
    add_frames(PAUSE_MEDIUM)

    # === Step 4: Implementation ===
    terminal.add_line([])
    type_line([("@bicep-implement", "purple"),
              (" - Generating templates...", "dim")])
    add_frames(PAUSE_SHORT)

    # Progress
    terminal.add_line([])
    for progress_pct in [20, 40, 60, 80, 100]:
        bar_len = progress_pct // 5
        bar = "█" * bar_len + "░" * (20 - bar_len)
        terminal.lines[-1] = [
            ("  ", "text"),
            ("Generating: ", "text"),
            (f"[{bar}]", "green" if progress_pct == 100 else "yellow"),
            (f" {progress_pct}%", "text"),
        ]
        add_frames(PAUSE_SHORT)

    add_frames(PAUSE_SHORT)

    # Validation
    terminal.add_line([])
    type_line([("  ", "text"), ("Running ", "text"),
              ("bicep build", "blue"), ("...", "dim")])
    add_frames(PAUSE_MEDIUM)
    type_line([("  ", "text"), ("✓", "green"),
              (" Build succeeded: 0 errors", "text")], typing=False)

    terminal.add_line([])
    type_line([("  ", "text"), ("Running ", "text"),
              ("bicep lint", "blue"), ("...", "dim")])
    add_frames(PAUSE_SHORT)
    type_line([("  ", "text"), ("✓", "green"),
              (" Lint passed: 0 warnings", "text")], typing=False)
    add_frames(PAUSE_MEDIUM)

    # === Final Summary ===
    terminal.add_line([])
    type_line([("═" * 50, "green")], typing=False)
    type_line(
        [("  ", "text"), ("✅ ", "green"), ("Deployment Ready!", "white")], typing=False
    )
    type_line([("═" * 50, "green")], typing=False)
    terminal.add_line([])
    type_line(
        [
            ("  ", "text"),
            ("Files created:   ", "dim"),
            ("6 Bicep modules", "cyan"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("Time elapsed:    ", "dim"),
            ("4 minutes 32 seconds", "cyan"),
        ],
        typing=False,
    )
    type_line(
        [
            ("  ", "text"),
            ("Time saved:      ", "dim"),
            ("~2 hours (96%)", "green"),
        ],
        typing=False,
    )
    terminal.add_line([])
    type_line(
        [
            ("  ", "text"),
            ("Run ", "text"),
            ("./deploy.ps1", "blue"),
            (" to deploy to Azure", "text"),
        ],
        typing=False,
    )

    add_frames(PAUSE_LONG * 2)

    return frames


# =============================================================================
# Main
# =============================================================================


def main():
    """Generate the demo GIF."""
    print("🎬 Generating demo workflow animation...")

    # Create output directory
    output_dir = Path(__file__).parent / "generated"
    output_dir.mkdir(exist_ok=True)

    # Generate frames
    print("  → Creating animation frames...")
    pil_frames = create_workflow_animation()
    print(f"  → Generated {len(pil_frames)} frames")

    # Save as GIF
    output_path = output_dir / "demo-workflow.gif"
    print(f"  → Saving GIF to {output_path}...")

    pil_frames[0].save(
        output_path,
        save_all=True,
        append_images=pil_frames[1:],
        duration=FRAME_DURATION,
        loop=0,  # Loop forever
        optimize=True,
    )

    # Calculate file size
    file_size = output_path.stat().st_size / 1024 / 1024
    print(f"  → File size: {file_size:.2f} MB")

    print(f"\n✅ Demo GIF saved to: {output_path}")
    print(
        f"   Duration: ~{len(pil_frames) * FRAME_DURATION / 1000:.1f} seconds")


if __name__ == "__main__":
    main()
