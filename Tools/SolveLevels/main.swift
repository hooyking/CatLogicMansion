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

        guard let clearSolution = LevelSolver.solve(level, goal: .clear, maxMoves: 100, maxStates: 500_000) else {
            failureCount += 1
            print("FAIL \(url.lastPathComponent): no clear route within 100 moves")
            continue
        }

        guard let threeStarSolution = LevelSolver.solve(level, goal: .threeStar, maxMoves: 100, maxStates: 500_000) else {
            failureCount += 1
            print("FAIL \(url.lastPathComponent): clear route found, but no 3-star route within 100 moves")
            print("  clear: \(format(solution: clearSolution))")
            continue
        }

        print("PASS \(url.lastPathComponent)")
        print("  clear: \(format(solution: clearSolution))")
        print("  3-star: \(format(solution: threeStarSolution))")
    } catch {
        failureCount += 1
        print("FAIL \(url.lastPathComponent): decode failed: \(error)")
    }
}

if failureCount > 0 {
    fputs("\n\(failureCount) level file(s) failed solve check.\n", stderr)
    exit(1)
}

print("\nSolved \(levelURLs.count) level file(s).")

private func format(solution: LevelSolution) -> String {
    let route = solution.moves.map(\.description).joined(separator: " ")
    return "\(solution.result.moves) moves, \(solution.result.stars) star(s), route: \(route)"
}

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
