public struct GridPosition: Equatable, Hashable {
    let x: Int
    let y: Int

    func moved(_ direction: MoveDirection) -> GridPosition {
        switch direction {
        case .up:
            GridPosition(x: x, y: y - 1)
        case .down:
            GridPosition(x: x, y: y + 1)
        case .left:
            GridPosition(x: x - 1, y: y)
        case .right:
            GridPosition(x: x + 1, y: y)
        }
    }
}

public enum MoveDirection: CaseIterable, CustomStringConvertible {
    case up
    case down
    case left
    case right

    public var description: String {
        switch self {
        case .up:
            "up"
        case .down:
            "down"
        case .left:
            "left"
        case .right:
            "right"
        }
    }
}
