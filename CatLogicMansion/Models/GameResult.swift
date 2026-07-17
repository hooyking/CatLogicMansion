public struct GameResult: Equatable {
    public let moves: Int
    public let targetSteps: Int
    public let collectedAllItems: Bool

    public var stars: Int {
        var value = 1

        if collectedAllItems {
            value += 1
        }

        if moves <= targetSteps {
            value += 1
        }

        return value
    }
}
