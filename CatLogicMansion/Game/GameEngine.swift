struct GameObject: Equatable {
    let id: String
    let type: String
    let subtype: String?
    var position: GridPosition
    var locked: Bool
    var enabled: Bool
    let targetIds: [String]
    let holdMode: String?
}

enum MoveOutcome: Equatable {
    case blocked
    case moved
    case cleared(GameResult)
}

struct GameEngine {
    private let level: Level
    private var objectsById: [String: GameObject]
    private var collectedObjectIds: Set<String> = []
    private var history: [GameStateSnapshot] = []
    private(set) var heldKeyIds: Set<String> = []
    private(set) var openedTargetIds: Set<String> = []
    private(set) var playerPosition: GridPosition
    private(set) var result: GameResult?

    init(level: Level) {
        self.level = level
        playerPosition = GridPosition(x: level.player.x, y: level.player.y)
        objectsById = Dictionary(
            uniqueKeysWithValues: level.objects.map { object in
                (
                    object.id,
                    GameObject(
                        id: object.id,
                        type: object.type,
                        subtype: object.subtype,
                        position: GridPosition(x: object.x, y: object.y),
                        locked: object.locked ?? false,
                        enabled: object.enabled ?? true,
                        targetIds: object.targetIds ?? [],
                        holdMode: object.holdMode
                    )
                )
            }
        )
    }

    var moveCount: Int {
        history.count
    }

    var objects: [GameObject] {
        objectsById.values.sorted { $0.id < $1.id }
    }

    var isCleared: Bool {
        result != nil
    }

    var searchKey: String {
        let objectKey = objectsById.values
            .sorted { $0.id < $1.id }
            .map { "\($0.id):\($0.position.x),\($0.position.y)" }
            .joined(separator: "|")
        let collectedKey = collectedObjectIds.sorted().joined(separator: ",")
        let heldKey = heldKeyIds.sorted().joined(separator: ",")
        let openedKey = openedTargetIds.sorted().joined(separator: ",")

        return [
            "p:\(playerPosition.x),\(playerPosition.y)",
            "o:\(objectKey)",
            "c:\(collectedKey)",
            "h:\(heldKey)",
            "t:\(openedKey)"
        ].joined(separator: ";")
    }

    var collectedAllItems: Bool {
        let collectibleIds = objectsById.values
            .filter { $0.type == "collectible" }
            .map(\.id)

        return collectibleIds.allSatisfy { collectedObjectIds.contains($0) }
    }

    var isExitOpen: Bool {
        guard level.exit.locked else {
            return true
        }

        guard let unlockBy = level.exit.unlockBy else {
            return false
        }

        return heldKeyIds.contains(unlockBy) || openedTargetIds.contains(unlockBy)
    }

    func isCollected(id: String) -> Bool {
        collectedObjectIds.contains(id)
    }

    func objectPosition(id: String) -> GridPosition? {
        objectsById[id]?.position
    }

    func isButtonPressed(_ button: GameObject) -> Bool {
        playerPosition == button.position || objectsById.values.contains { object in
            object.type == "box" && object.position == button.position
        }
    }

    func isTargetEnabled(id: String) -> Bool {
        if let object = objectsById[id], object.type == "bridge" {
            return object.enabled || openedTargetIds.contains(id)
        }

        return openedTargetIds.contains(id)
    }

    mutating func move(_ direction: MoveDirection) -> MoveOutcome {
        guard !isCleared else {
            return .blocked
        }

        let nextPosition = playerPosition.moved(direction)

        guard canEnter(nextPosition, moving: direction) else {
            return .blocked
        }

        saveSnapshot()
        pushBoxIfNeeded(at: nextPosition, moving: direction)
        playerPosition = nextPosition
        collectObjectIfNeeded(at: nextPosition)
        refreshButtonTargets()

        if let result = clearResultIfNeeded() {
            self.result = result
            return .cleared(result)
        }

        return .moved
    }

    mutating func undo() -> Bool {
        guard let snapshot = history.popLast() else {
            return false
        }

        playerPosition = snapshot.playerPosition
        objectsById = snapshot.objectsById
        collectedObjectIds = snapshot.collectedObjectIds
        heldKeyIds = snapshot.heldKeyIds
        openedTargetIds = snapshot.openedTargetIds
        result = nil
        return true
    }

    private mutating func saveSnapshot() {
        history.append(
            GameStateSnapshot(
                playerPosition: playerPosition,
                objectsById: objectsById,
                collectedObjectIds: collectedObjectIds,
                heldKeyIds: heldKeyIds,
                openedTargetIds: openedTargetIds
            )
        )
    }

    private func canEnter(_ position: GridPosition, moving direction: MoveDirection) -> Bool {
        guard level.isInside(position), !level.isWall(at: position) else {
            return false
        }

        if blockingDoor(at: position) != nil {
            return false
        }

        if blockingBridge(at: position) != nil {
            return false
        }

        if let box = box(at: position) {
            return canPushBox(box, moving: direction)
        }

        return true
    }

    private func canPushBox(_ boxObject: GameObject, moving direction: MoveDirection) -> Bool {
        let targetPosition = boxObject.position.moved(direction)

        guard level.isInside(targetPosition), !level.isWall(at: targetPosition) else {
            return false
        }

        guard box(at: targetPosition) == nil,
              blockingDoor(at: targetPosition) == nil,
              blockingBridge(at: targetPosition) == nil else {
            return false
        }

        return true
    }

    private mutating func pushBoxIfNeeded(at position: GridPosition, moving direction: MoveDirection) {
        guard let boxObject = box(at: position) else {
            return
        }

        objectsById[boxObject.id]?.position = boxObject.position.moved(direction)
    }

    private mutating func collectObjectIfNeeded(at position: GridPosition) {
        for object in objectsById.values where object.position == position {
            if object.type == "collectible" {
                collectedObjectIds.insert(object.id)
            }

            if object.type == "key" {
                collectedObjectIds.insert(object.id)
                heldKeyIds.insert(object.id)
            }
        }
    }

    private mutating func refreshButtonTargets() {
        let buttonTargetIds = objectsById.values
            .filter { $0.type == "button" }
            .flatMap(\.targetIds)

        openedTargetIds.subtract(buttonTargetIds)

        for button in objectsById.values where button.type == "button" {
            guard isButtonPressed(button) else {
                continue
            }

            openedTargetIds.formUnion(button.targetIds)
        }
    }

    private func clearResultIfNeeded() -> GameResult? {
        let exitPosition = GridPosition(x: level.exit.x, y: level.exit.y)

        guard playerPosition == exitPosition, isExitOpen else {
            return nil
        }

        return GameResult(
            moves: moveCount,
            targetSteps: level.targetSteps,
            collectedAllItems: collectedAllItems
        )
    }

    private func box(at position: GridPosition) -> GameObject? {
        objectsById.values.first { object in
            object.type == "box" && object.position == position
        }
    }

    private func blockingDoor(at position: GridPosition) -> GameObject? {
        objectsById.values.first { object in
            object.type == "door" && object.position == position && !openedTargetIds.contains(object.id)
        }
    }

    private func blockingBridge(at position: GridPosition) -> GameObject? {
        objectsById.values.first { object in
            object.type == "bridge"
                && object.position == position
                && !object.enabled
                && !openedTargetIds.contains(object.id)
        }
    }
}

private struct GameStateSnapshot {
    let playerPosition: GridPosition
    let objectsById: [String: GameObject]
    let collectedObjectIds: Set<String>
    let heldKeyIds: Set<String>
    let openedTargetIds: Set<String>
}
