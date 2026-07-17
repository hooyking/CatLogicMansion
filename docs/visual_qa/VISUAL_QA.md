# Visual QA - 2026-07-17

## Scope

- Device: iPhone 16 Pro Max simulator, iOS 26.5.
- Flow: opened levels 1-10 directly with launch arguments and captured each board.
- Evidence:
  - Before pass: `docs/visual_qa/screenshots/contact_sheet.png`
  - Asset readability pass: `docs/visual_qa/screenshots_after/contact_sheet.png`
  - Final HUD + asset pass: `docs/visual_qa/screenshots_after_icons/contact_sheet.png`

## Changes Made

- Kept the game cat token aligned with the pre-formal-asset game-page shape: transparent background, no cropped corners, orange face, cream outline.
- Made the treat read as a fish-shaped collectible instead of a generic orange dot group.
- Made keys thicker so they remain recognizable on dense boards.
- Made pressure buttons clearer with a base, pressed offset, and check mark on the pressed state.
- Made bridges wider and added a clear disabled-state cross.
- Replaced the in-game undo/reset HUD controls with circular icon buttons and kept accessibility labels.
- Moved floor controls below boxes in render order, so a box pressing a button no longer shows a badge-like button graphic on top of the box.

## QA Notes

- Levels 1-10 render without blank boards or missing art.
- The game page no longer shows a pause button.
- The top HUD now uses icons for repeated actions; result-overlay action buttons remain text because they are confirmation choices.
- Door and exit readability are acceptable for this pass.
- Box-on-button state was rechecked on level 006 with scripted simulator moves; evidence: `docs/visual_qa/screenshots_box_button/level_006_box_on_button.png`.

## Next Visual Checks

- Re-play levels 1-10 on device or simulator and note any object that is still misread during motion.
- After final commercial art assets are prepared, run the same screenshot pass and compare against `screenshots_after_icons`.
