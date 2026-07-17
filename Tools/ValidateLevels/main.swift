import CatLogicMansionCore
import Foundation

let rootPath = CommandLine.arguments.dropFirst().first ?? "CatLogicMansion/GameData/Levels"
let rootURL = URL(fileURLWithPath: rootPath, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
let decoder = JSONDecoder()

let levelURLs = indexedLevelURLs(rootURL: rootURL)

guard !levelURLs.isEmpty else {
    fputs("No indexed level JSON files found under \(rootURL.path)\n", stderr)
    exit(1)
}

var failureCount = 0

for url in levelURLs {
    do {
        let level = try decoder.decode(Level.self, from: Data(contentsOf: url))
        let issues = LevelValidator.validate(level)

        if issues.isEmpty {
            print("PASS \(url.lastPathComponent)")
        } else {
            failureCount += 1
            print("FAIL \(url.lastPathComponent)")
            for issue in issues {
                print("  - \(issue.description)")
            }
        }
    } catch {
        failureCount += 1
        print("FAIL \(url.lastPathComponent)")
        print("  - decode failed: \(error)")
    }
}

if failureCount > 0 {
    fputs("\n\(failureCount) level file(s) failed validation.\n", stderr)
    exit(1)
}

print("\nValidated \(levelURLs.count) level file(s).")

private func indexedLevelURLs(rootURL: URL) -> [URL] {
    let chapterURLs = chapterIndexURLs(rootURL: rootURL)

    return chapterURLs.flatMap { indexURL -> [URL] in
        do {
            let index = try decoder.decode(ChapterIndex.self, from: Data(contentsOf: indexURL))
            let chapterDirectory = indexURL.deletingLastPathComponent()
            return index.levels.map { chapterDirectory.appendingPathComponent($0) }
        } catch {
            return []
        }
    }
}

private func chapterIndexURLs(rootURL: URL) -> [URL] {
    let directIndexURL = rootURL.appendingPathComponent("index.json")
    if FileManager.default.fileExists(atPath: directIndexURL.path) {
        return [directIndexURL]
    }

    return ((try? FileManager.default.contentsOfDirectory(
        at: rootURL,
        includingPropertiesForKeys: nil
    )) ?? [])
    .map { $0.appendingPathComponent("index.json") }
    .filter { FileManager.default.fileExists(atPath: $0.path) }
    .sorted { $0.path < $1.path }
}
