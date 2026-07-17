// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CatLogicMansionCore",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .library(name: "CatLogicMansionCore", targets: ["CatLogicMansionCore"]),
        .executable(name: "validate-levels", targets: ["ValidateLevels"]),
        .executable(name: "solve-levels", targets: ["SolveLevels"])
    ],
    targets: [
        .target(
            name: "CatLogicMansionCore",
            path: ".",
            exclude: [
                "CatLogicMansion/App",
                "CatLogicMansion/Assets.xcassets",
                "CatLogicMansion/Game/GameContainerView.swift",
                "CatLogicMansion/Game/GameScene.swift",
                "CatLogicMansion/Game/GameViewModel.swift",
                "CatLogicMansion/GameData",
                "CatLogicMansion/Info.plist",
                "CatLogicMansion/Services/LevelLoader.swift",
                "CatLogicMansion/Services/ProgressStore.swift",
                "CatLogicMansion/Services/AudioService.swift",
                "GDD.md",
                "LICENSE",
                "README.md",
                "docs",
                "Tests",
                "Tools"
            ],
            sources: [
                "CatLogicMansion/Models/GridPosition.swift",
                "CatLogicMansion/Models/Level.swift",
                "CatLogicMansion/Models/LevelValidator.swift",
                "CatLogicMansion/Models/GameResult.swift",
                "CatLogicMansion/Models/LevelProgress.swift",
                "CatLogicMansion/Game/GameEngine.swift",
                "CatLogicMansion/Game/LevelSolver.swift",
                "CatLogicMansion/Services/AudioFeedback.swift",
                "CatLogicMansion/Services/AppSettings.swift",
                "CatLogicMansion/Services/LocalizationService.swift",
                "CatLogicMansion/Services/VisualAssetManifest.swift"
            ]
        ),
        .testTarget(
            name: "CatLogicMansionCoreTests",
            dependencies: ["CatLogicMansionCore"],
            path: "Tests/CatLogicMansionCoreTests"
        ),
        .executableTarget(
            name: "ValidateLevels",
            dependencies: ["CatLogicMansionCore"],
            path: "Tools/ValidateLevels"
        ),
        .executableTarget(
            name: "SolveLevels",
            dependencies: ["CatLogicMansionCore"],
            path: "Tools/SolveLevels"
        )
    ]
)
