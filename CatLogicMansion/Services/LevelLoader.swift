import Foundation

enum LevelLoader {
    static func load(levelId: String) -> Level {
        let fileName = "\(levelId).json"

        guard let url = Bundle.main.url(
            forResource: fileName,
            withExtension: nil,
            subdirectory: "GameData/Levels/chapter_01"
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
