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

        guard let clearSolution = LevelSolver.solve(level, goal: .clear, maxMoves: 80) else {
            failureCount += 1
            print("FAIL \(url.lastPathComponent): no clear route within 80 moves")
            continue
        }

        guard let threeStarSolution = LevelSolver.solve(level, goal: .threeStar, maxMoves: 80) else {
            failureCount += 1
            print("FAIL \(url.lastPathComponent): clear route found, but no 3-star route within 80 moves")
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
