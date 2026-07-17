import Foundation

@MainActor
final class ProgressStore: ObservableObject {
    @Published private(set) var progressByLevelId: [String: LevelProgress] = [:]

    private let storageKey = "cat_logic_mansion.level_progress"

    init() {
        load()
    }

    func progress(for levelId: String) -> LevelProgress? {
        progressByLevelId[levelId]
    }

    func isUnlocked(levelNumber: Int) -> Bool {
        guard levelNumber > 1 else {
            return true
        }

        let previousLevelId = String(format: "level_%03d", levelNumber - 1)
        return progressByLevelId[previousLevelId] != nil
    }

    var totalStars: Int {
        progressByLevelId.values.reduce(0) { partialResult, progress in
            partialResult + progress.stars
        }
    }

    var clearedLevelCount: Int {
        progressByLevelId.count
    }

    func save(levelId: String, result: GameResult) {
        let current = progressByLevelId[levelId]
        let bestStars = max(current?.stars ?? 0, result.stars)
        let bestMoves = min(current?.bestMoves ?? Int.max, result.moves)

        progressByLevelId[levelId] = LevelProgress(
            levelId: levelId,
            stars: bestStars,
            bestMoves: bestMoves
        )

        persist()
    }

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            progressByLevelId = [:]
            return
        }

        do {
            let values = try JSONDecoder().decode([LevelProgress].self, from: data)
            progressByLevelId = Dictionary(uniqueKeysWithValues: values.map { ($0.levelId, $0) })
        } catch {
            progressByLevelId = [:]
        }
    }

    private func persist() {
        let values = progressByLevelId.values.sorted { $0.levelId < $1.levelId }

        if let data = try? JSONEncoder().encode(values) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}
