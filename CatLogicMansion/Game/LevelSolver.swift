public enum LevelSolveGoal {
    case clear
    case threeStar
}

public struct LevelSolution: Equatable {
    public let moves: [MoveDirection]
    public let result: GameResult
}

public enum LevelSolver {
    public static func solve(
        _ level: Level,
        goal: LevelSolveGoal,
        maxMoves: Int = 80,
        maxStates: Int = 50_000
    ) -> LevelSolution? {
        var queue = [
            SearchNode(
                engine: GameEngine(level: level),
                moves: []
            )
        ]
        var visited = Set<String>()
        var index = 0

        visited.insert(queue[0].engine.searchKey)

        while index < queue.count, visited.count <= maxStates {
            let node = queue[index]
            index += 1

            guard node.moves.count < maxMoves else {
                continue
            }

            for direction in MoveDirection.allCases {
                var nextEngine = node.engine
                let outcome = nextEngine.move(direction)

                guard outcome != .blocked else {
                    continue
                }

                let nextMoves = node.moves + [direction]

                if case let .cleared(result) = outcome, matches(result: result, goal: goal) {
                    return LevelSolution(moves: nextMoves, result: result)
                }

                let key = nextEngine.searchKey
                guard visited.insert(key).inserted else {
                    continue
                }

                queue.append(
                    SearchNode(
                        engine: nextEngine,
                        moves: nextMoves
                    )
                )
            }
        }

        return nil
    }

    private static func matches(result: GameResult, goal: LevelSolveGoal) -> Bool {
        switch goal {
        case .clear:
            true
        case .threeStar:
            result.stars == 3
        }
    }
}

private struct SearchNode {
    let engine: GameEngine
    let moves: [MoveDirection]
}
