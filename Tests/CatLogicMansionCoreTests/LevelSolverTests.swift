import Foundation
import Testing
@testable import CatLogicMansionCore

@Suite("LevelSolver")
struct LevelSolverTests {
    @Test("finds a shortest clear route")
    func findsShortestClearRoute() {
        let level = makeSolverLevel(
            player: LevelPlayer(x: 1, y: 1, direction: "right"),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: false, unlockBy: nil)
        )

        let solution = LevelSolver.solve(level, goal: .clear, maxMoves: 10)

        #expect(solution?.moves == [.right, .right])
        #expect(solution?.result == GameResult(moves: 2, targetSteps: 10, collectedAllItems: true))
    }

    @Test("returns nil when exit is unreachable")
    func returnsNilWhenExitIsUnreachable() {
        let level = makeSolverLevel(
            player: LevelPlayer(x: 1, y: 1, direction: "right"),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: false, unlockBy: nil),
            tiles: [
                "#####",
                "#.#.#",
                "#####"
            ]
        )

        let solution = LevelSolver.solve(level, goal: .clear, maxMoves: 10)

        #expect(solution == nil)
    }

    @Test("can require a three star route")
    func canRequireThreeStarRoute() {
        let level = makeSolverLevel(
            targetSteps: 4,
            player: LevelPlayer(x: 1, y: 1, direction: "right"),
            exit: LevelExit(id: "exit", x: 3, y: 1, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "fish", type: "collectible", subtype: "fish", x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        )

        let solution = LevelSolver.solve(level, goal: .threeStar, maxMoves: 10)

        #expect(solution?.result.stars == 3)
        #expect(solution?.moves == [.right, .right])
    }

    @Test("current indexed JSON levels have a clear route")
    func currentIndexedJSONLevelsHaveClearRoute() throws {
        let failures = solveIndexedLevels(goal: .clear)

        #expect(failures.isEmpty, Comment(rawValue: "Unsolvable levels: \(failures.joined(separator: ", "))"))
    }

    @Test("current indexed JSON levels have a three-star route")
    func currentIndexedJSONLevelsHaveThreeStarRoute() throws {
        let failures = solveIndexedLevels(goal: .threeStar)

        #expect(failures.isEmpty, Comment(rawValue: "Levels without 3-star route: \(failures.joined(separator: ", "))"))
    }

    @Test("advanced indexed levels require longer three-star routes")
    func advancedIndexedLevelsRequireLongerThreeStarRoutes() throws {
        let shortRoutes = solveIndexedLevelResults(goal: .threeStar, levelIds: Set((11...20).map { String(format: "level_%03d", $0) }))
            .compactMap { result -> String? in
                guard let moves = result.moves, moves < 32 else { return nil }
                return "\(result.fileName): \(moves) moves"
            }

        #expect(shortRoutes.isEmpty, Comment(rawValue: "Finale levels are too short: \(shortRoutes.joined(separator: ", "))"))
    }

    @Test("advanced three-star routes use every placed mechanic")
    func advancedThreeStarRoutesUseEveryPlacedMechanic() throws {
        let failures = try loadIndexedLevels(levelIds: Set((11...20).map { String(format: "level_%03d", $0) }))
            .compactMap { level -> String? in
                guard let solution = LevelSolver.solve(level, goal: .threeStar, maxMoves: 100, maxStates: 500_000) else {
                    return "\(level.id): no 3-star route"
                }

                let audit = auditMechanics(level: level, moves: solution.moves)
                let issues = requiredMechanicIssues(level: level, audit: audit)
                guard issues.isEmpty else {
                    return "\(level.id): \(issues.joined(separator: ", "))"
                }

                return nil
            }

        #expect(failures.isEmpty, Comment(rawValue: "Unused finale mechanics: \(failures.joined(separator: "; "))"))
    }
}

private struct IndexedSolveResult {
    let fileName: String
    let moves: Int?
}

private func solveIndexedLevelResults(goal: LevelSolveGoal, levelIds: Set<String>? = nil) -> [IndexedSolveResult] {
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let levelsDirectory = root.appendingPathComponent("CatLogicMansion/GameData/Levels")
    let levelURLs = (try? FileManager.default
        .contentsOfDirectory(at: levelsDirectory, includingPropertiesForKeys: nil)
        .flatMap { chapterURL in
            try FileManager.default.contentsOfDirectory(at: chapterURL, includingPropertiesForKeys: nil)
        }
        .filter { $0.lastPathComponent.hasPrefix("level_") && $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }) ?? []

    let decoder = JSONDecoder()
    var results: [IndexedSolveResult] = []

    for url in levelURLs {
        let fileName = url.lastPathComponent
        guard let level = try? decoder.decode(Level.self, from: Data(contentsOf: url)) else {
            results.append(IndexedSolveResult(fileName: fileName, moves: nil))
            continue
        }

        guard levelIds?.contains(level.id) ?? true else {
            continue
        }

        let solution = LevelSolver.solve(level, goal: goal, maxMoves: 100, maxStates: 500_000)
        results.append(IndexedSolveResult(fileName: fileName, moves: solution?.moves.count))
    }

    return results
}

private func solveIndexedLevels(goal: LevelSolveGoal) -> [String] {
    solveIndexedLevelResults(goal: goal, levelIds: nil)
        .filter { $0.moves == nil }
        .map(\.fileName)
}

private func loadIndexedLevels(levelIds: Set<String>) throws -> [Level] {
    let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
    let levelsDirectory = root.appendingPathComponent("CatLogicMansion/GameData/Levels")
    let levelURLs = try FileManager.default
        .contentsOfDirectory(at: levelsDirectory, includingPropertiesForKeys: nil)
        .flatMap { chapterURL in
            try FileManager.default.contentsOfDirectory(at: chapterURL, includingPropertiesForKeys: nil)
        }
        .filter { $0.lastPathComponent.hasPrefix("level_") && $0.pathExtension == "json" }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }
    let decoder = JSONDecoder()

    return try levelURLs
        .map { try decoder.decode(Level.self, from: Data(contentsOf: $0)) }
        .filter { levelIds.contains($0.id) }
}

private struct MechanicAudit {
    var movedBoxIds = Set<String>()
    var collectedKeyIds = Set<String>()
    var pressedButtonIds = Set<String>()
    var enabledTargetIds = Set<String>()
    var crossedBridgeIds = Set<String>()
}

private func auditMechanics(level: Level, moves: [MoveDirection]) -> MechanicAudit {
    var engine = GameEngine(level: level)
    var audit = MechanicAudit()
    var previousBoxPositions = Dictionary(
        uniqueKeysWithValues: engine.objects
            .filter { $0.type == "box" }
            .map { ($0.id, $0.position) }
    )

    for move in moves {
        _ = engine.move(move)

        for object in engine.objects {
            switch object.type {
            case "box":
                if previousBoxPositions[object.id] != object.position {
                    audit.movedBoxIds.insert(object.id)
                    previousBoxPositions[object.id] = object.position
                }
            case "key":
                if engine.heldKeyIds.contains(object.id) {
                    audit.collectedKeyIds.insert(object.id)
                }
            case "button":
                if engine.isButtonPressed(object) {
                    audit.pressedButtonIds.insert(object.id)
                }
            case "door", "bridge":
                if engine.isTargetEnabled(id: object.id) {
                    audit.enabledTargetIds.insert(object.id)
                }

                if object.type == "bridge", engine.playerPosition == object.position {
                    audit.crossedBridgeIds.insert(object.id)
                }
            default:
                break
            }
        }
    }

    return audit
}

private func requiredMechanicIssues(level: Level, audit: MechanicAudit) -> [String] {
    var issues: [String] = []

    for object in level.objects {
        switch object.type {
        case "box" where !audit.movedBoxIds.contains(object.id):
            issues.append("\(object.id) was not moved")
        case "key" where !audit.collectedKeyIds.contains(object.id):
            issues.append("\(object.id) was not collected")
        case "button" where !audit.pressedButtonIds.contains(object.id):
            issues.append("\(object.id) was not pressed")
        case "door" where !audit.enabledTargetIds.contains(object.id):
            issues.append("\(object.id) was not opened")
        case "bridge" where !audit.enabledTargetIds.contains(object.id):
            issues.append("\(object.id) was not enabled")
        case "bridge" where !audit.crossedBridgeIds.contains(object.id):
            issues.append("\(object.id) was not crossed")
        default:
            break
        }
    }

    return issues
}

private func makeSolverLevel(
    targetSteps: Int = 10,
    player: LevelPlayer,
    exit: LevelExit,
    tiles: [String] = [
        "#####",
        "#...#",
        "#...#",
        "#####"
    ],
    objects: [LevelObject] = []
) -> Level {
    Level(
        id: "solver_level",
        chapterId: "chapter_test",
        nameKey: "level.solver.name",
        tutorialKey: nil,
        width: tiles.first?.count ?? 0,
        height: tiles.count,
        targetSteps: targetSteps,
        player: player,
        exit: exit,
        tiles: tiles,
        objects: objects
    )
}
