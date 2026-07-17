import Foundation

enum LevelLoader {
    private static let chapterDirectory = "GameData/Levels/chapter_01"

    static func loadChapterIndex() -> ChapterIndex {
        guard let url = Bundle.main.url(
            forResource: "index.json",
            withExtension: nil,
            subdirectory: chapterDirectory
        ) else {
            fatalError("Missing chapter index")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(ChapterIndex.self, from: data)
        } catch {
            fatalError("Failed to decode chapter index: \(error)")
        }
    }

    static func availableLevelIds() -> [String] {
        loadChapterIndex().levels.map { fileName in
            fileName.replacingOccurrences(of: ".json", with: "")
        }
    }

    static func nextLevelId(after levelId: String) -> String {
        let levelIds = availableLevelIds()
        guard let index = levelIds.firstIndex(of: levelId) else {
            return levelId
        }

        let nextIndex = levelIds.index(after: index)
        guard levelIds.indices.contains(nextIndex) else {
            return levelId
        }

        return levelIds[nextIndex]
    }

    static func load(levelId: String) -> Level {
        let fileName = "\(levelId).json"

        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: chapterDirectory
        ) else {
            fatalError("Missing level file: \(fileName)")
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode(Level.self, from: data)
        } catch {
            fatalError("Failed to decode level file \(fileName): \(error)")
        }
    }
}
