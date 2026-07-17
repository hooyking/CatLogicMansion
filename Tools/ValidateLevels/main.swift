import CatLogicMansionCore
import Foundation

let rootPath = CommandLine.arguments.dropFirst().first ?? "CatLogicMansion/GameData/Levels"
let rootURL = URL(fileURLWithPath: rootPath, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
let decoder = JSONDecoder()

let levelURLs = (FileManager.default.enumerator(at: rootURL, includingPropertiesForKeys: nil)?
    .compactMap { $0 as? URL }
    .filter { $0.lastPathComponent.hasPrefix("level_") && $0.pathExtension == "json" }
    .sorted { $0.path < $1.path }) ?? []

guard !levelURLs.isEmpty else {
    fputs("No level JSON files found under \(rootURL.path)\n", stderr)
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
