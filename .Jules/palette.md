## 2026-01-29 - Roblox UI Interactivity

**Learning:** Roblox UI buttons lack built-in interactive feedback (hover/click) by default compared to web buttons, making interfaces feel 'dead'. Users need explicit visual confirmation for actions.
**Action:** Always implement custom MouseEnter/MouseLeave/MouseButton1Click handlers for interactive elements to improve perceived responsiveness.

## 2026-05-21 - Feedback for High-Frequency Actions

**Learning:** Repetitive actions like resource gathering (mining, cutting) feel unresponsive without immediate visual confirmation (e.g., "Toast" or "Floating Text"), even if the inventory updates in the background.
**Action:** Implement lightweight, non-blocking visual cues (like floating text) for all high-frequency interactions to confirm success.

## 2026-06-15 - Visualizing Invisible State

**Learning:** Users struggled to optimize minigame performance because the success state (progress bar) was calculated internally but never rendered.
**Action:** Always visualize internal counters that determine success/failure (like minigame progress) to provide actionable feedback.

## 2026-10-24 - List Scanability

**Learning:** Plain text lists (like inventories) are hard to scan quickly for value/quality.
**Action:** Use color-coded indicators (borders/icons) alongside text to allow rapid visual filtering.
