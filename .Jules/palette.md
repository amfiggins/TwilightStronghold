## 2026-01-29 - Roblox UI Interactivity
**Learning:** Roblox UI buttons lack built-in interactive feedback (hover/click) by default compared to web buttons, making interfaces feel 'dead'. Users need explicit visual confirmation for actions.
**Action:** Always implement custom MouseEnter/MouseLeave/MouseButton1Click handlers for interactive elements to improve perceived responsiveness.

## 2026-05-21 - Feedback for High-Frequency Actions
**Learning:** Repetitive actions like resource gathering (mining, cutting) feel unresponsive without immediate visual confirmation (e.g., "Toast" or "Floating Text"), even if the inventory updates in the background.
**Action:** Implement lightweight, non-blocking visual cues (like floating text) for all high-frequency interactions to confirm success.

## 2026-05-21 - Blind Minigame Mechanics
**Learning:** Complex interaction loops (like holding a key to fill a bar) are frustratingly opaque without visual progress indicators. Users can't adjust their behavior or feel satisfaction without seeing the "fill".
**Action:** Always visualize the internal `progress` state of any minigame or long-press action.
