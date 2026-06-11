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

## 2027-02-14 - Minigame Instruction Visibility
**Learning:** Players often struggle with minigames because key mechanics (like "Hold SPACE") are assumed knowledge rather than explicitly taught.
**Action:** Always include persistent, high-contrast instruction text (e.g., "Hold SPACE") directly within the minigame UI to eliminate ambiguity.

## 2027-04-01 - Matchmaking Queue Visibility
**Learning:** Players joining a matchmaking queue via an interactable object (like a Portal) often feel uncertain if their action registered when the feedback is limited to console prints or delayed teleports.
**Action:** Always provide immediate, on-screen visual confirmation (like a toast notification) indicating successful queue entry and current queue size.
## 2024-05-24 - Async Loading Operations
**Learning:** When improving UX during async loading operations, avoid replacing universally recognized icons (like '↻') with ambiguous text (like '...'). Instead, animate the existing icon (e.g., rotating it in place) to provide clear visual feedback while maintaining the element's visual affordance.
**Action:** Handle relative layout rotation by wrapping static children (like tooltips) and rotating elements in a shared container to prevent unintended inheritance of rotation.

## 2027-05-01 - Minigame Success States
**Learning:** Instantly removing the UI upon minigame success is jarring. Players need a brief moment to process the visual feedback of their success before the context shifts.
**Action:** Always insert a short delay (e.g., 0.5s) and display a clear "Success" state (like text or color changes) before closing high-focus minigame UIs.
## 2026-06-11 - Add explicitly accessible Close and Toggle buttons
**Learning:** For Roblox Luau UI accessibility, relying solely on keyboard shortcuts (like Tab) for visibility toggling is insufficient. Interactive core elements like loadouts must provide explicit, on-screen toggle and close buttons to ensure discoverability and accessibility for mouse-only and mobile users. Additionally, ensuring interactive elements include `SelectionGained` and `SelectionLost` handlers that mirror `MouseEnter` and `MouseLeave` provides necessary visual feedback for gamepad and keyboard navigation.
**Action:** When designing or updating core UI elements, always include an explicit on-screen toggle button with a clear visual state, and a clear 'Close' button within the panel. Ensure all interactive buttons map `SelectionGained`/`SelectionLost` to their hover state logic for full input parity.
## 2026-06-11 - Selene linting UDim2.new
**Learning:** Selene's `roblox_manual_fromscale_or_fromoffset` rule enforces that `UDim2.new(0, x, 0, y)` is simplified to `UDim2.fromOffset(x, y)` and `UDim2.new(x, 0, y, 0)` is simplified to `UDim2.fromScale(x, y)`. Failing to use these constructors results in linting errors in strict environments.
**Action:** When creating `UDim2` values in Roblox UI development, always use the explicit `UDim2.fromOffset` and `UDim2.fromScale` constructors when possible to maintain codebase quality standards.
## 2026-06-11 - UX Enhancements and Constraints
**Learning:** When attempting to add accessibility features (like explicit buttons or hints) to an existing UI, be extremely careful not to accidentally place new elements at the exact same screen coordinates as existing ones (e.g., overlapping a new 'Close' button with an existing 'Refresh' button). Additionally, strictly adhere to the < 50 lines rule for Palette; if an enhancement requires too much code or structural change, pivot to a simpler, non-intrusive micro-UX fix, such as adding a simple text hint.
**Action:** When adding micro-UX elements, prefer simple TextLabel hints, ARIA-like tooltips, or minor property changes that fit well within the 50-line limit and do not risk complex UI layout regressions.
