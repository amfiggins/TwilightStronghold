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

## 2026-02-07 - Handling Dynamic Lists & Async UI

**Learning:** Static lists in Roblox UI (like inventory) are not automatically scrollable and can overflow, leading to inaccessible items. Additionally, triggering async data fetches without a debounce can lead to race conditions and duplicate UI elements.
**Action:** Always wrap dynamic lists in a `ScrollingFrame` with `AutomaticCanvasSize` and implement debounce/loading states for any button that triggers an async fetch.

## 2026-11-20 - Static Inventory State
**Learning:** Roblox GUIs often load data once. Users assume UI updates automatically when data changes (like inventory), leading to confusion when it doesn't.
**Action:** If reactive binding isn't available, always provide a manual "Refresh" trigger and explicit "Loading/Empty" states to manage expectations.

## 2026-12-05 - Gamepad & Keyboard Accessibility
**Learning:** Roblox UI elements do not automatically mirror hover states for Gamepad/Keyboard selection. This leaves non-mouse users without visual feedback when navigating.
**Action:** Always bind `SelectionGained` and `SelectionLost` events to the same visual update logic used for `MouseEnter` and `MouseLeave`.

## 2027-01-15 - Context-Aware Actions & Details
**Learning:** Generic buttons (e.g., "Unequip Weapon") confuse users when the context (which weapon?) is unclear or the button is irrelevant (nothing equipped).
**Action:** Use context-aware labels (e.g., "Unequip Void Slayer") and conditionally render action buttons to reduce cognitive load and clutter.

## 2027-02-18 - Minigame UX Standards
**Learning:** Users often fail custom minigames due to unclear controls and subtle feedback. Color changes are processed faster than position changes.
**Action:** Always include a persistent instruction label (e.g., "Hold SPACE") and use immediate color changes (e.g., White -> Green) to confirm success states in the render loop.
