import Testing
@testable import CatLogicMansionCore

@Suite("GameEngine rules")
struct GameEngineTests {
    @Test("collectibles and target steps determine star result")
    func collectibleAndTargetStepsDetermineStarResult() {
        var engine = GameEngine(level: makeLevel(
            targetSteps: 3,
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "fish", type: "collectible", subtype: "fish", x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.right) == .moved)
        #expect(engine.move(.right) == .cleared(GameResult(moves: 2, targetSteps: 3, collectedAllItems: true)))
        #expect(engine.result?.stars == 3)
    }

    @Test("locked exits open after collecting matching key")
    func lockedExitOpensAfterCollectingMatchingKey() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: true, unlockBy: "key"),
            objects: [
                LevelObject(id: "key", type: "key", subtype: "gold", x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.right) == .moved)
        #expect(engine.heldKeyIds == ["key"])
        #expect(engine.move(.right) == .cleared(GameResult(moves: 2, targetSteps: 10, collectedAllItems: true)))
    }

    @Test("boxes push one tile and cannot be pushed through walls")
    func boxesPushOneTileAndCannotBePushedThroughWalls() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 1, y: 3, locked: false, unlockBy: nil),
            tiles: [
                "#####",
                "#...#",
                "#####",
                "#...#",
                "#####"
            ],
            objects: [
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.right) == .moved)
        #expect(engine.objectPosition(id: "box") == GridPosition(x: 3, y: 1))
        #expect(engine.move(.right) == .blocked)
        #expect(engine.playerPosition == GridPosition(x: 2, y: 1))
        #expect(engine.objectPosition(id: "box") == GridPosition(x: 3, y: 1))
    }

    @Test("buttons open doors only while pressed")
    func buttonsOpenDoorsOnlyWhilePressed() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "door", type: "door", subtype: nil, x: 2, y: 1, locked: true, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "button", type: "button", subtype: nil, x: 1, y: 2, locked: nil, enabled: nil, targetIds: ["door"], holdMode: "temporary")
            ]
        ))

        #expect(engine.move(.right) == .blocked)
        #expect(engine.move(.down) == .moved)
        #expect(engine.openedTargetIds == ["door"])
        #expect(engine.move(.up) == .moved)
        #expect(engine.openedTargetIds.isEmpty)
    }

    @Test("disabled bridges block cats and boxes until a target enables them")
    func disabledBridgesBlockCatsAndBoxesUntilTargetEnablesThem() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 2),
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "bridge", type: "bridge", subtype: nil, x: 3, y: 1, locked: nil, enabled: false, targetIds: nil, holdMode: nil),
                LevelObject(id: "button", type: "button", subtype: nil, x: 3, y: 2, locked: nil, enabled: nil, targetIds: ["bridge"], holdMode: "pressed"),
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 2, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.up) == .moved)
        #expect(engine.move(.right) == .moved)
        #expect(engine.move(.right) == .blocked)
        #expect(engine.move(.left) == .moved)
        #expect(engine.move(.down) == .moved)
        #expect(engine.move(.right) == .moved)
        #expect(engine.openedTargetIds == ["bridge"])
        #expect(engine.move(.up) == .moved)
        #expect(engine.move(.right) == .moved)
    }

    @Test("undo restores player, objects, inventory, targets, and move count")
    func undoRestoresFullState() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "key", type: "key", subtype: "gold", x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 2, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.right) == .moved)
        #expect(engine.move(.down) == .moved)
        #expect(engine.moveCount == 2)

        let firstUndoSucceeded = engine.undo()
        #expect(firstUndoSucceeded)
        #expect(engine.playerPosition == GridPosition(x: 2, y: 1))
        #expect(engine.objectPosition(id: "box") == GridPosition(x: 2, y: 2))
        #expect(engine.heldKeyIds == ["key"])
        #expect(engine.moveCount == 1)

        let secondUndoSucceeded = engine.undo()
        #expect(secondUndoSucceeded)
        #expect(engine.playerPosition == GridPosition(x: 1, y: 1))
        #expect(engine.heldKeyIds.isEmpty)
        #expect(engine.moveCount == 0)
    }

    @Test("query helpers expose collected objects and target state for rendering")
    func queryHelpersExposeRenderingState() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: true, unlockBy: nil),
            objects: [
                LevelObject(id: "fish", type: "collectible", subtype: "fish", x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "bridge", type: "bridge", subtype: nil, x: 1, y: 2, locked: nil, enabled: true, targetIds: nil, holdMode: nil),
                LevelObject(id: "door", type: "door", subtype: nil, x: 3, y: 2, locked: true, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.objects.map(\.id) == ["bridge", "door", "fish"])
        #expect(engine.isTargetEnabled(id: "bridge"))
        #expect(!engine.isTargetEnabled(id: "door"))
        #expect(!engine.isTargetEnabled(id: "missing"))
        #expect(engine.move(.right) == .moved)
        #expect(engine.isCollected(id: "fish"))
        #expect(!engine.isExitOpen)
    }

    @Test("blocked moves cover map boundaries, closed targets, and completed rooms")
    func blockedMovesCoverEdgesTargetsAndCompletedRooms() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 2, locked: nil, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "door", type: "door", subtype: nil, x: 2, y: 3, locked: true, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "bridge", type: "bridge", subtype: nil, x: 1, y: 2, locked: nil, enabled: false, targetIds: nil, holdMode: nil)
            ]
        ))

        #expect(engine.move(.up) == .blocked)
        #expect(engine.move(.down) == .blocked)
        #expect(engine.move(.right) == .moved)
        #expect(engine.move(.down) == .blocked)
        #expect(engine.move(.right) == .cleared(GameResult(moves: 2, targetSteps: 10, collectedAllItems: true)))
        #expect(engine.move(.left) == .blocked)
    }

    @Test("undo reports false when there is no history")
    func undoReportsFalseWhenThereIsNoHistory() {
        var engine = GameEngine(level: makeLevel(
            player: GridPosition(x: 1, y: 1),
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: false, unlockBy: nil)
        ))

        let undoSucceeded = engine.undo()
        #expect(!undoSucceeded)
    }
}

private func makeLevel(
    targetSteps: Int = 10,
    player: GridPosition,
    exit: LevelExit,
    tiles: [String] = [
        "#####",
        "#...#",
        "#...#",
        "#...#",
        "#####"
    ],
    objects: [LevelObject] = []
) -> Level {
    Level(
        id: "test_level",
        chapterId: "chapter_test",
        nameKey: "level.test.name",
        tutorialKey: nil,
        width: tiles.first?.count ?? 0,
        height: tiles.count,
        targetSteps: targetSteps,
        player: LevelPlayer(x: player.x, y: player.y, direction: "right"),
        exit: exit,
        tiles: tiles,
        objects: objects
    )
}
