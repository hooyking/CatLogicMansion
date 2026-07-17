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

    @Test("current chapter one JSON levels have a clear route")
    func currentChapterOneJSONLevelsHaveClearRoute() throws {
        let failures = solveChapterOneLevels(goal: .clear)

        #expect(failures.isEmpty, Comment(rawValue: "Unsolvable levels: \(failures.joined(separator: ", "))"))
    }

    @Test("current chapter one JSON levels have a three-star route")
    func currentChapterOneJSONLevelsHaveThreeStarRoute() throws {
        let failures = solveChapterOneLevels(goal: .threeStar)

        #expect(failures.isEmpty, Comment(rawValue: "Levels without 3-star route: \(failures.joined(separator: ", "))"))
    }
}

private func solveChapterOneLevels(goal: LevelSolveGoal) -> [String] {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let levelDirectory = root.appendingPathComponent("CatLogicMansion/GameData/Levels/chapter_01")
        let levelURLs = (try? FileManager.default
            .contentsOfDirectory(at: levelDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("level_") && $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }) ?? []

        let decoder = JSONDecoder()
        var failures: [String] = []

        for url in levelURLs {
            guard let level = try? decoder.decode(Level.self, from: Data(contentsOf: url)) else {
                failures.append(url.lastPathComponent)
                continue
            }

            if LevelSolver.solve(level, goal: goal, maxMoves: 80) == nil {
                failures.append(url.lastPathComponent)
            }
        }

        return failures
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
