## 2024-04-12 - Multi-platform context-aware instructions
**Learning:** Hardcoding "Press Space" blocks mobile/console users. "Hold to align" is a safer default. Dynamic instructions based on actual last input type (Keyboard, Gamepad, Touch, Mouse) provide the best UX.
**Action:** Default instruction text to platform-agnostic phrasing, and update dynamically using InputBegan/InputEnded events checking `Enum.UserInputType` to provide immediate, context-aware guidance.
