import SpriteKit
import SwiftUI

@MainActor
final class GameViewModel: ObservableObject {
    @Published private(set) var moveCount = 0
    @Published private(set) var roomCleared = false
    @Published private(set) var result: GameResult?
    @Published private(set) var scene: GameScene?
    @Published private(set) var tutorialText = ""

    var onAudioFeedback: (AudioFeedback) -> Void = { _ in }

    private var currentLevelId = ""

    func load(levelId: String) {
        guard currentLevelId != levelId || scene == nil else {
            return
        }

        currentLevelId = levelId
        moveCount = 0
        roomCleared = false
        result = nil
        let level = LevelLoader.load(levelId: levelId)
        tutorialText = level.tutorialKey.map(L10n.tr) ?? ""
        scene = makeScene(level: level)
    }

    func reset() {
        moveCount = 0
        roomCleared = false
        result = nil
        if let scene {
            scene.resetLevel()
        } else {
            let level = LevelLoader.load(levelId: currentLevelId)
            tutorialText = level.tutorialKey.map(L10n.tr) ?? ""
            scene = makeScene(level: level)
        }
    }

    func undo() {
        scene?.undoLastMove()
    }

    func applyLaunchMoves(_ directions: [MoveDirection]) {
        scene?.applyLaunchMoves(directions)
    }

    private func makeScene(level: Level) -> GameScene {
        let scene = GameScene(level: level)
        scene.scaleMode = .resizeFill
        scene.onMove = { [weak self] in
            Task { @MainActor in
                self?.moveCount += 1
            }
        }
        scene.onUndo = { [weak self] in
            Task { @MainActor in
                self?.moveCount = max((self?.moveCount ?? 0) - 1, 0)
                self?.roomCleared = false
                self?.result = nil
            }
        }
        scene.onRoomCleared = { [weak self] result in
            Task { @MainActor in
                self?.roomCleared = true
                self?.result = result
            }
        }
        scene.onAudioFeedback = { [weak self] feedback in
            Task { @MainActor in
                self?.onAudioFeedback(feedback)
            }
        }
        return scene
    }
}
