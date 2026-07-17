import SwiftUI

struct ContentView: View {
    @State private var selectedLevelId = LaunchConfiguration.initialLevelId
    @State private var screen: AppScreen = LaunchConfiguration.initialScreen
    @State private var isSettingsDrawerOpen = LaunchConfiguration.startsWithSettingsDrawer
    @StateObject private var progressStore = ProgressStore()
    @StateObject private var appSettings = AppSettings()
    @StateObject private var audioService = AudioService()

    var body: some View {
        NavigationStack {
            Group {
                switch screen {
                case .menu:
                    MainMenuView(
                        totalStars: progressStore.totalStars,
                        onPlay: startCurrentLevel,
                        onSelectLevels: {
                            screen = .levels
                        },
                        onOpenSettings: openSettingsDrawer
                    )
                case .levels:
                    LevelSelectView(progressStore: progressStore) { levelId in
                        selectedLevelId = levelId
                        screen = .game
                    }
                case .game:
                    GameContainerView(
                        levelId: selectedLevelId,
                        launchMoves: LaunchConfiguration.scriptedMoves,
                        onLevelCleared: { result in
                            progressStore.save(levelId: selectedLevelId, result: result)
                        },
                        onNextLevel: goToNextLevel,
                        onAudioFeedback: { feedback in
                            audioService.play(feedback)
                        }
                    )
                    .id(selectedLevelId)
                }
            }
            .id(appSettings.language.rawValue)
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(screen == .game ? .inline : .large)
            .toolbar {
                if screen == .game {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            screen = .levels
                        } label: {
                            Image(systemName: "chevron.left")
                        }
                        .accessibilityLabel(Text(L10n.tr("menu.levels")))
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            ForEach(LevelLoader.availableLevelIds(), id: \.self) { levelId in
                                let isUnlocked = progressStore.isUnlocked(levelId: levelId, in: LevelLoader.availableLevelIds())

                                Button(levelTitle(for: levelId)) {
                                    if isUnlocked {
                                        selectedLevelId = levelId
                                    }
                                }
                                .disabled(!isUnlocked)
                            }
                        } label: {
                            Image(systemName: "square.grid.2x2")
                        }
                    }
                } else if screen == .levels {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(L10n.tr("menu.home")) {
                            screen = .menu
                        }
                    }
                } else {
                    ToolbarItem(placement: .topBarLeading) {
                        Button(action: openSettingsDrawer) {
                            Image(systemName: "gearshape.fill")
                                .foregroundStyle(AppDesign.ColorToken.walnut)
                        }
                    }
                }
            }
        }
        .overlay {
            if isSettingsDrawerOpen {
                Color.black.opacity(0.28)
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeSettingsDrawer()
                    }
                    .transition(.opacity)
                    .zIndex(9)

                HStack(spacing: 0) {
                    SettingsDrawerView(
                        appSettings: appSettings,
                        onClose: closeSettingsDrawer
                    )

                    Spacer(minLength: 0)
                }
                .transition(.move(edge: .leading))
                .zIndex(10)
            }
        }
        .onAppear {
            syncAudioSettings()
        }
        .onChange(of: appSettings.isSoundEnabled) { _, _ in
            syncAudioSettings()
        }
        .onChange(of: appSettings.isMusicEnabled) { _, _ in
            syncAudioSettings()
        }
    }

    private var currentLevelName: String {
        guard let levelNumber = Int(selectedLevelId.replacingOccurrences(of: "level_", with: "")) else {
            return L10n.tr("app.name")
        }

        return L10n.tr("level.\(String(format: "%03d", levelNumber)).name")
    }

    private func levelTitle(for levelId: String) -> String {
        guard let levelNumber = Int(levelId.replacingOccurrences(of: "level_", with: "")) else {
            return L10n.tr("app.name")
        }

        return L10n.tr("level.\(String(format: "%03d", levelNumber)).name")
    }

    private var navigationTitle: String {
        switch screen {
        case .menu:
            L10n.tr("app.name")
        case .levels:
            L10n.tr("level_select.title")
        case .game:
            currentLevelName
        }
    }

    private func startCurrentLevel() {
        if selectedLevelId.isEmpty {
            selectedLevelId = "level_001"
        }

        screen = .game
    }

    private func goToNextLevel() {
        selectedLevelId = LevelLoader.nextLevelId(after: selectedLevelId)
        screen = .game
    }

    private func openSettingsDrawer() {
        withAnimation(.easeOut(duration: 0.24)) {
            isSettingsDrawerOpen = true
        }
    }

    private func closeSettingsDrawer() {
        withAnimation(.easeOut(duration: 0.22)) {
            isSettingsDrawerOpen = false
        }
    }

    private func syncAudioSettings() {
        audioService.update(
            soundEnabled: appSettings.isSoundEnabled,
            musicEnabled: appSettings.isMusicEnabled
        )
    }
}

private enum AppScreen {
    case menu
    case levels
    case game
}

private enum LaunchConfiguration {
    static let startsInGame = ProcessInfo.processInfo.arguments.contains("--open-level")
    static let startsWithSettingsDrawer = ProcessInfo.processInfo.arguments.contains("--open-settings")
    static var initialScreen: AppScreen {
        startsInGame ? .game : .menu
    }

    static var initialLevelId: String {
        guard let index = ProcessInfo.processInfo.arguments.firstIndex(of: "--level-id") else {
            return "level_001"
        }

        let valueIndex = ProcessInfo.processInfo.arguments.index(after: index)
        guard ProcessInfo.processInfo.arguments.indices.contains(valueIndex) else {
            return "level_001"
        }

        return ProcessInfo.processInfo.arguments[valueIndex]
    }

    static var scriptedMoves: [MoveDirection] {
        guard let index = ProcessInfo.processInfo.arguments.firstIndex(of: "--moves") else {
            return []
        }

        let valueIndex = ProcessInfo.processInfo.arguments.index(after: index)
        guard ProcessInfo.processInfo.arguments.indices.contains(valueIndex) else {
            return []
        }

        return ProcessInfo.processInfo.arguments[valueIndex]
            .split(separator: ",")
            .compactMap { moveDirection(from: String($0)) }
    }

    private static func moveDirection(from value: String) -> MoveDirection? {
        switch value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() {
        case "up":
            .up
        case "down":
            .down
        case "left":
            .left
        case "right":
            .right
        default:
            nil
        }
    }
}
