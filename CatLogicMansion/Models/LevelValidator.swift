public enum LevelValidationIssue: Equatable, CustomStringConvertible {
    case invalidDimensions(width: Int, height: Int)
    case tileRowCountMismatch(expected: Int, actual: Int)
    case tileRowWidthMismatch(row: Int, expected: Int, actual: Int)
    case unsupportedTileCharacter(row: Int, column: Int, value: Character)
    case playerOutsideMap(GridPosition)
    case playerStartsOnWall(GridPosition)
    case exitOutsideMap(GridPosition)
    case exitOnWall(GridPosition)
    case duplicateObjectId(String)
    case objectOutsideMap(id: String, position: GridPosition)
    case objectOnWall(id: String, position: GridPosition)
    case missingExitUnlockTarget(String)
    case missingObjectTarget(sourceId: String, targetId: String)

    public var description: String {
        switch self {
        case let .invalidDimensions(width, height):
            "invalid dimensions \(width)x\(height)"
        case let .tileRowCountMismatch(expected, actual):
            "tile row count mismatch: expected \(expected), actual \(actual)"
        case let .tileRowWidthMismatch(row, expected, actual):
            "tile row \(row) width mismatch: expected \(expected), actual \(actual)"
        case let .unsupportedTileCharacter(row, column, value):
            "unsupported tile character '\(value)' at (\(column), \(row))"
        case let .playerOutsideMap(position):
            "player outside map at \(position)"
        case let .playerStartsOnWall(position):
            "player starts on wall at \(position)"
        case let .exitOutsideMap(position):
            "exit outside map at \(position)"
        case let .exitOnWall(position):
            "exit on wall at \(position)"
        case let .duplicateObjectId(id):
            "duplicate object id '\(id)'"
        case let .objectOutsideMap(id, position):
            "object '\(id)' outside map at \(position)"
        case let .objectOnWall(id, position):
            "object '\(id)' on wall at \(position)"
        case let .missingExitUnlockTarget(targetId):
            "exit unlock target '\(targetId)' does not exist"
        case let .missingObjectTarget(sourceId, targetId):
            "object '\(sourceId)' targets missing object '\(targetId)'"
        }
    }
}

public enum LevelValidator {
    public static func validate(_ level: Level) -> [LevelValidationIssue] {
        var issues: [LevelValidationIssue] = []

        if level.width <= 0 || level.height <= 0 {
            issues.append(.invalidDimensions(width: level.width, height: level.height))
        }

        if level.tiles.count != level.height {
            issues.append(.tileRowCountMismatch(expected: level.height, actual: level.tiles.count))
        }

        for (rowIndex, row) in level.tiles.enumerated() {
            let characters = Array(row)

            if characters.count != level.width {
                issues.append(.tileRowWidthMismatch(row: rowIndex, expected: level.width, actual: characters.count))
            }

            for (columnIndex, character) in characters.enumerated() where character != "#" && character != "." {
                issues.append(.unsupportedTileCharacter(row: rowIndex, column: columnIndex, value: character))
            }
        }

        let playerPosition = GridPosition(x: level.player.x, y: level.player.y)
        if !level.isInside(playerPosition) {
            issues.append(.playerOutsideMap(playerPosition))
        } else if isWall(at: playerPosition, in: level) {
            issues.append(.playerStartsOnWall(playerPosition))
        }

        let exitPosition = GridPosition(x: level.exit.x, y: level.exit.y)
        if !level.isInside(exitPosition) {
            issues.append(.exitOutsideMap(exitPosition))
        } else if isWall(at: exitPosition, in: level) {
            issues.append(.exitOnWall(exitPosition))
        }

        var seenObjectIds = Set<String>()
        var duplicateObjectIds = Set<String>()

        for object in level.objects {
            if !seenObjectIds.insert(object.id).inserted {
                duplicateObjectIds.insert(object.id)
            }

            let objectPosition = GridPosition(x: object.x, y: object.y)
            if !level.isInside(objectPosition) {
                issues.append(.objectOutsideMap(id: object.id, position: objectPosition))
            } else if isWall(at: objectPosition, in: level) {
                issues.append(.objectOnWall(id: object.id, position: objectPosition))
            }
        }

        issues.append(contentsOf: duplicateObjectIds.sorted().map(LevelValidationIssue.duplicateObjectId))

        let objectIds = Set(level.objects.map(\.id))
        if let unlockBy = level.exit.unlockBy, !objectIds.contains(unlockBy) {
            issues.append(.missingExitUnlockTarget(unlockBy))
        }

        for object in level.objects {
            for targetId in object.targetIds ?? [] where !objectIds.contains(targetId) {
                issues.append(.missingObjectTarget(sourceId: object.id, targetId: targetId))
            }
        }

        return issues
    }

    private static func isWall(at position: GridPosition, in level: Level) -> Bool {
        guard level.tiles.indices.contains(position.y) else {
            return true
        }

        let row = Array(level.tiles[position.y])
        guard row.indices.contains(position.x) else {
            return true
        }

        return row[position.x] == "#"
    }
}
