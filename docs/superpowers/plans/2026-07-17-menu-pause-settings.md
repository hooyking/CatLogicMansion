# Menu Pause Settings Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a complete MVP shell with a main menu, in-game pause overlay, and persistent sound/music settings.

**Architecture:** Keep gameplay state in `GameContainerView` and app navigation state in `ContentView`. Extend `AppSettings` for persisted toggles and pass it into settings UI. Use existing JSON localization and App target patterns.

**Tech Stack:** SwiftUI, SpriteKit, SwiftPM tests, UserDefaults.

---

### Task 1: Persist Sound And Music Settings

**Files:**
- Modify: `Package.swift`
- Modify: `CatLogicMansion/Services/AppSettings.swift`
- Test: `Tests/CatLogicMansionCoreTests/AppSettingsTests.swift`

- [ ] Write failing tests for default sound/music settings and persisted changes.
- [ ] Add `AppSettings` and `LocalizationService` to SwiftPM core sources.
- [ ] Implement `isSoundEnabled` and `isMusicEnabled` with `UserDefaults`.
- [ ] Run `swift test --filter AppSettings`.

### Task 2: Add Main Menu And Pause Overlay

**Files:**
- Modify: `CatLogicMansion/App/ContentView.swift`
- Create: `CatLogicMansion/App/MainMenuView.swift`
- Modify: `CatLogicMansion/Game/GameContainerView.swift`
- Modify: `CatLogicMansion.xcodeproj/project.pbxproj`

- [ ] Add `MainMenuView` with play, level select, and settings actions.
- [ ] Update `ContentView` to navigate between menu, level select, and game.
- [ ] Add a pause button and overlay in `GameContainerView`.
- [ ] Add new Swift file to Xcode project sources.

### Task 3: Localize And Verify

**Files:**
- Modify: `CatLogicMansion/GameData/Localization/en.json`
- Modify: `CatLogicMansion/GameData/Localization/zh-Hans.json`
- Modify: `CatLogicMansion/GameData/Localization/zh-Hant.json`
- Modify: `README.md`

- [ ] Add localized keys for menu, pause, sound, and music.
- [ ] Update README current feature list.
- [ ] Run `swift test --enable-code-coverage`, coverage report, `swift run validate-levels`, `swift run solve-levels`, and Xcode simulator build.
