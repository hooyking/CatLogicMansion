public struct Level: Decodable {
    let id: String
    let chapterId: String
    let nameKey: String
    let tutorialKey: String?
    let width: Int
    let height: Int
    let targetSteps: Int
    let player: LevelPlayer
    let exit: LevelExit
    let tiles: [String]
    let objects: [LevelObject]

    func isInside(_ position: GridPosition) -> Bool {
        position.x >= 0 && position.x < width && position.y >= 0 && position.y < height
    }

    func isWall(at position: GridPosition) -> Bool {
        guard isInside(position) else {
            return true
        }

        let row = Array(tiles[position.y])
        return row[position.x] == "#"
    }
}

public struct ChapterIndex: Decodable {
    public let chapterId: String
    public let titleKey: String
    public let subtitleKey: String
    public let levels: [String]
}

public struct LevelPlayer: Decodable {
    let x: Int
    let y: Int
    let direction: String
}

public struct LevelExit: Decodable {
    let id: String
    let x: Int
    let y: Int
    let locked: Bool
    let unlockBy: String?
}

public struct LevelObject: Decodable {
    let id: String
    let type: String
    let subtype: String?
    let x: Int
    let y: Int
    let locked: Bool?
    let enabled: Bool?
    let targetIds: [String]?
    let holdMode: String?
}
