import Foundation

enum LevelLoader {
    private static let levelsDirectory = "GameData/Levels"

    static func loadChapterIndex() -> ChapterIndex {
        guard let index = loadChapterIndexes().first else {
            fatalError("Missing chapter index")
        }

        return index
    }

    static func loadChapterIndexes() -> [ChapterIndex] {
        chapterIndexEntries().map(\.index)
    }

    static func availableLevelIds() -> [String] {
        loadChapterIndexes().flatMap { index in
            index.levels.map { fileName in
                fileName.replacingOccurrences(of: ".json", with: "")
            }
        }
    }

    static func levelIds(in chapterId: String) -> [String] {
        loadChapterIndexes()
            .first { $0.chapterId == chapterId }?
            .levels
            .map { $0.replacingOccurrences(of: ".json", with: "") } ?? []
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

        guard let chapterDirectory = chapterDirectory(containing: fileName) else {
            fatalError("Missing level file: \(fileName)")
        }

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

    private static func chapterIndexEntries() -> [(index: ChapterIndex, directory: String)] {
        guard let resourceURL = Bundle.main.resourceURL else {
            fatalError("Missing levels directory")
        }

        let levelsURL = resourceURL.appendingPathComponent(levelsDirectory)
        guard FileManager.default.fileExists(atPath: levelsURL.path) else {
            fatalError("Missing levels directory")
        }

        let chapterURLs = ((try? FileManager.default.contentsOfDirectory(
            at: levelsURL,
            includingPropertiesForKeys: nil
        )) ?? [])
        .filter { url in
            var isDirectory: ObjCBool = false
            return FileManager.default.fileExists(atPath: url.path, isDirectory: &isDirectory) && isDirectory.boolValue
        }
        .sorted { $0.lastPathComponent < $1.lastPathComponent }

        return chapterURLs.map { chapterURL in
            let indexURL = chapterURL.appendingPathComponent("index.json")
            do {
                let data = try Data(contentsOf: indexURL)
                let index = try JSONDecoder().decode(ChapterIndex.self, from: data)
                return (index, "\(levelsDirectory)/\(chapterURL.lastPathComponent)")
            } catch {
                fatalError("Failed to decode chapter index \(indexURL.lastPathComponent): \(error)")
            }
        }
    }

    private static func chapterDirectory(containing fileName: String) -> String? {
        chapterIndexEntries()
            .first { entry in
                entry.index.levels.contains(fileName)
            }?
            .directory
    }

    static func chapterIndex(for levelId: String) -> ChapterIndex? {
        let fileName = "\(levelId).json"
        return chapterIndexEntries()
            .first { $0.index.levels.contains(fileName) }?
            .index
    }
}
