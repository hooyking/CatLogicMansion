import Foundation
import Testing
@testable import CatLogicMansionCore

@Suite("LevelValidator")
struct LevelValidatorTests {
    @Test("valid levels report no issues")
    func validLevelsReportNoIssues() {
        let level = makeValidationLevel()

        #expect(LevelValidator.validate(level).isEmpty)
    }

    @Test("invalid dimensions and tile rows are reported")
    func invalidDimensionsAndTileRowsAreReported() {
        let level = makeValidationLevel(
            width: 0,
            height: 3,
            tiles: [
                "####",
                "#.x#"
            ]
        )

        let issues = LevelValidator.validate(level)

        #expect(issues.contains(.invalidDimensions(width: 0, height: 3)))
        #expect(issues.contains(.tileRowCountMismatch(expected: 3, actual: 2)))
        #expect(issues.contains(.tileRowWidthMismatch(row: 0, expected: 0, actual: 4)))
        #expect(issues.contains(.unsupportedTileCharacter(row: 1, column: 2, value: "x")))
    }

    @Test("positions outside the map and objects on walls are reported")
    func invalidPositionsAreReported() {
        let level = makeValidationLevel(
            player: LevelPlayer(x: 0, y: 0, direction: "right"),
            exit: LevelExit(id: "exit", x: 7, y: 7, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "fish", type: "collectible", subtype: "fish", x: 0, y: 0, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        )

        let issues = LevelValidator.validate(level)

        #expect(issues.contains(.playerStartsOnWall(GridPosition(x: 0, y: 0))))
        #expect(issues.contains(.exitOutsideMap(GridPosition(x: 7, y: 7))))
        #expect(issues.contains(.objectOnWall(id: "fish", position: GridPosition(x: 0, y: 0))))
    }

    @Test("exit on wall and object outside map are reported")
    func exitOnWallAndObjectOutsideMapAreReported() {
        let level = makeValidationLevel(
            exit: LevelExit(id: "exit", x: 0, y: 0, locked: false, unlockBy: nil),
            objects: [
                LevelObject(id: "box", type: "box", subtype: nil, x: 8, y: 8, locked: nil, enabled: nil, targetIds: nil, holdMode: nil)
            ]
        )

        let issues = LevelValidator.validate(level)

        #expect(issues.contains(.exitOnWall(GridPosition(x: 0, y: 0))))
        #expect(issues.contains(.objectOutsideMap(id: "box", position: GridPosition(x: 8, y: 8))))
    }

    @Test("duplicate object ids and missing target references are reported")
    func duplicateObjectIdsAndMissingReferencesAreReported() {
        let level = makeValidationLevel(
            exit: LevelExit(id: "exit", x: 3, y: 3, locked: true, unlockBy: "missing_key"),
            objects: [
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 1, locked: nil, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "box", type: "box", subtype: nil, x: 2, y: 2, locked: nil, enabled: nil, targetIds: nil, holdMode: nil),
                LevelObject(id: "button", type: "button", subtype: nil, x: 1, y: 2, locked: nil, enabled: nil, targetIds: ["missing_door"], holdMode: "pressed")
            ]
        )

        let issues = LevelValidator.validate(level)

        #expect(issues.contains(.duplicateObjectId("box")))
        #expect(issues.contains(.missingExitUnlockTarget("missing_key")))
        #expect(issues.contains(.missingObjectTarget(sourceId: "button", targetId: "missing_door")))
    }

    @Test("current chapter one JSON levels are structurally valid")
    func currentChapterOneJSONLevelsAreStructurallyValid() throws {
        let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        let levelDirectory = root.appendingPathComponent("CatLogicMansion/GameData/Levels/chapter_01")
        let indexURL = levelDirectory.appendingPathComponent("index.json")
        let index = try JSONDecoder().decode(ChapterIndex.self, from: Data(contentsOf: indexURL))
        let levelURLs = try FileManager.default
            .contentsOfDirectory(at: levelDirectory, includingPropertiesForKeys: nil)
            .filter { $0.lastPathComponent.hasPrefix("level_") && $0.pathExtension == "json" }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }

        let decoder = JSONDecoder()
        var failures: [String] = []

        for url in levelURLs {
            let level = try decoder.decode(Level.self, from: Data(contentsOf: url))
            let issues = LevelValidator.validate(level)

            if !issues.isEmpty {
                failures.append("\(url.lastPathComponent): \(issues.map(\.description).joined(separator: ", "))")
            }
        }

        #expect(index.levels.count == 15)
        #expect(levelURLs.map(\.lastPathComponent) == index.levels)
        #expect(failures.isEmpty, Comment(rawValue: failures.joined(separator: "\n")))
    }

    @Test("validation issues provide readable descriptions")
    func validationIssuesProvideReadableDescriptions() {
        let issues: [LevelValidationIssue] = [
            .invalidDimensions(width: 0, height: -1),
            .tileRowCountMismatch(expected: 3, actual: 2),
            .tileRowWidthMismatch(row: 1, expected: 5, actual: 4),
            .unsupportedTileCharacter(row: 1, column: 2, value: "x"),
            .playerOutsideMap(GridPosition(x: -1, y: 0)),
            .playerStartsOnWall(GridPosition(x: 0, y: 0)),
            .exitOutsideMap(GridPosition(x: 9, y: 9)),
            .exitOnWall(GridPosition(x: 0, y: 0)),
            .duplicateObjectId("box"),
            .objectOutsideMap(id: "box", position: GridPosition(x: 9, y: 9)),
            .objectOnWall(id: "fish", position: GridPosition(x: 0, y: 0)),
            .missingExitUnlockTarget("key"),
            .missingObjectTarget(sourceId: "button", targetId: "door")
        ]

        for issue in issues {
            #expect(!issue.description.isEmpty)
        }
    }
}

private func makeValidationLevel(
    width: Int = 5,
    height: Int = 5,
    player: LevelPlayer = LevelPlayer(x: 1, y: 1, direction: "right"),
    exit: LevelExit = LevelExit(id: "exit", x: 3, y: 3, locked: false, unlockBy: nil),
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
        id: "validation_level",
        chapterId: "chapter_test",
        nameKey: "level.validation.name",
        tutorialKey: nil,
        width: width,
        height: height,
        targetSteps: 10,
        player: player,
        exit: exit,
        tiles: tiles,
        objects: objects
    )
}
