import SpriteKit
import UIKit

final class GameScene: SKScene {
    var onMove: (() -> Void)?
    var onUndo: (() -> Void)?
    var onRoomCleared: ((GameResult) -> Void)?
    var onAudioFeedback: ((AudioFeedback) -> Void)?

    private let level: Level
    private let tileSize: CGFloat = 48
    private var playerNode = SKNode()
    private let roomTheme: RoomTheme
    private var engine: GameEngine
    private var touchStart: CGPoint?
    private var textureCache: [String: SKTexture] = [:]

    init(level: Level) {
        self.level = level
        roomTheme = RoomTheme(levelId: level.id)
        engine = GameEngine(level: level)
        super.init(size: .zero)
        backgroundColor = roomTheme.background
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func didMove(to view: SKView) {
        renderLevel()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        renderLevel()
    }

    func resetLevel() {
        removeAllActions()
        engine = GameEngine(level: level)
        touchStart = nil
        renderLevel()
    }

    func applyLaunchMoves(_ directions: [MoveDirection]) {
        guard !directions.isEmpty else {
            return
        }

        for direction in directions {
            let outcome = engine.move(direction)
            guard outcome != .blocked else {
                break
            }

            onMove?()
            if case let .cleared(result) = outcome {
                onRoomCleared?(result)
                break
            }
        }

        renderLevel()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStart = touches.first?.location(in: self)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let start = touchStart, let end = touches.first?.location(in: self) else {
            return
        }

        let dx = end.x - start.x
        let dy = end.y - start.y
        let threshold: CGFloat = 20

        if abs(dx) < threshold && abs(dy) < threshold {
            moveTowardTap(end)
            return
        }

        if abs(dx) > abs(dy) {
            move(dx > 0 ? .right : .left)
        } else {
            move(dy > 0 ? .up : .down)
        }
    }

    private func renderLevel() {
        removeAllChildren()
        renderRoomBase()
        renderTiles()
        renderExit()
        renderObjects()
        renderPlayer()
    }

    private func renderRoomBase() {
        let frame = boardRect.insetBy(dx: -14, dy: -14)
        let shadow = SKShapeNode(rect: frame.offsetBy(dx: 0, dy: -7), cornerRadius: 28)
        shadow.fillColor = SceneColor.shadow
        shadow.strokeColor = .clear
        shadow.zPosition = 0
        addChild(shadow)

        let base = SKShapeNode(rect: frame, cornerRadius: 28)
        base.fillColor = roomTheme.boardBase
        base.strokeColor = roomTheme.boardStroke
        base.lineWidth = 3
        base.zPosition = 1
        addChild(base)
    }

    private func renderTiles() {
        for y in 0..<level.height {
            for x in 0..<level.width {
                let position = GridPosition(x: x, y: y)
                let isWall = level.isWall(at: position)
                let textureName = isWall ? VisualAssetManifest.wall : floorTextureName(at: position)

                if let node = makeTextureNode(named: textureName, size: CGSize(width: tileSize - 2, height: tileSize - 2)) {
                    node.position = point(for: position)
                    node.zPosition = isWall ? 5 : 2
                    addChild(node)
                } else {
                    let node = SKShapeNode(rectOf: CGSize(width: tileSize - 2, height: tileSize - 2), cornerRadius: 8)
                    node.position = point(for: position)
                    node.strokeColor = roomTheme.tileStroke
                    node.lineWidth = 1
                    node.zPosition = isWall ? 5 : 2
                    node.fillColor = isWall ? roomTheme.wall : floorColor(at: position)
                    addChild(node)

                    if isWall {
                        renderWallHighlight(at: position)
                    }
                }
            }
        }
    }

    private func renderExit() {
        let container = SKNode()
        container.position = point(for: GridPosition(x: level.exit.x, y: level.exit.y))
        container.zPosition = 6

        let textureName = engine.isExitOpen ? VisualAssetManifest.exitOpen : VisualAssetManifest.exitLocked
        if let texturedExit = makeTextureNode(named: textureName, size: CGSize(width: tileSize, height: tileSize)) {
            container.addChild(texturedExit)
            addChild(container)
            return
        }

        let door = SKShapeNode(rectOf: CGSize(width: tileSize - 12, height: tileSize - 10), cornerRadius: 12)
        door.fillColor = engine.isExitOpen ? SceneColor.exitOpen : SceneColor.exitLocked
        door.strokeColor = SceneColor.cream
        door.lineWidth = 3
        container.addChild(door)

        let arch = SKShapeNode(circleOfRadius: 13)
        arch.position = CGPoint(x: 0, y: 8)
        arch.fillColor = SceneColor.cream.withAlphaComponent(engine.isExitOpen ? 0.28 : 0.14)
        arch.strokeColor = .clear
        container.addChild(arch)

        let handle = SKShapeNode(circleOfRadius: 3)
        handle.position = CGPoint(x: 9, y: -1)
        handle.fillColor = SceneColor.gold
        handle.strokeColor = .clear
        container.addChild(handle)

        addChild(container)
    }

    private func renderObjects() {
        for object in engine.objects {
            guard !engine.isCollected(id: object.id) else {
                continue
            }

            let node = objectNode(for: object)
            node.position = point(for: object.position)
            node.zPosition = CGFloat(VisualAssetManifest.renderZPosition(forObjectType: object.type))
            addChild(node)
        }
    }

    private func renderPlayer() {
        playerNode = makeCatNode()
        playerNode.position = point(for: engine.playerPosition)
        playerNode.zPosition = 10
        addChild(playerNode)
    }

    private func renderWallHighlight(at position: GridPosition) {
        let highlight = SKShapeNode(rectOf: CGSize(width: tileSize - 10, height: 5), cornerRadius: 3)
        highlight.position = CGPoint(x: point(for: position).x, y: point(for: position).y + 14)
        highlight.fillColor = roomTheme.wallHighlight
        highlight.strokeColor = .clear
        highlight.zPosition = 6
        addChild(highlight)
    }

    private func objectNode(for object: GameObject) -> SKNode {
        let isEnabled = objectTextureState(for: object)
        let textureName = VisualAssetManifest.textureName(forObjectType: object.type, isEnabled: isEnabled)
        if let textureNode = makeTextureNode(named: textureName, size: CGSize(width: tileSize, height: tileSize)) {
            return textureNode
        }

        switch object.type {
        case "collectible":
            return makeTreatNode()
        case "key":
            return makeKeyNode()
        case "box":
            return makeBoxNode()
        case "button":
            return makeButtonNode(isPressed: engine.isButtonPressed(object))
        case "door":
            return makeDoorNode(isOpen: engine.openedTargetIds.contains(object.id))
        case "bridge":
            return makeBridgeNode(isEnabled: engine.isTargetEnabled(id: object.id))
        default:
            return makeMysteryNode()
        }
    }

    private func makeTreatNode() -> SKNode {
        let node = SKNode()
        let plate = SKShapeNode(circleOfRadius: 17)
        plate.fillColor = SceneColor.cream
        plate.strokeColor = SceneColor.gold
        plate.lineWidth = 3
        node.addChild(plate)

        for index in 0..<3 {
            let treat = SKShapeNode(circleOfRadius: 5)
            treat.position = CGPoint(x: CGFloat(index - 1) * 7, y: index == 1 ? 3 : -3)
            treat.fillColor = SceneColor.catOrange
            treat.strokeColor = .clear
            node.addChild(treat)
        }

        return node
    }

    private func makeKeyNode() -> SKNode {
        let node = SKNode()
        let bow = SKShapeNode(circleOfRadius: 8)
        bow.position = CGPoint(x: -8, y: 4)
        bow.fillColor = .clear
        bow.strokeColor = SceneColor.gold
        bow.lineWidth = 4
        node.addChild(bow)

        let shaft = SKShapeNode(rectOf: CGSize(width: 22, height: 5), cornerRadius: 2.5)
        shaft.position = CGPoint(x: 6, y: 1)
        shaft.fillColor = SceneColor.gold
        shaft.strokeColor = .clear
        node.addChild(shaft)

        let tooth = SKShapeNode(rectOf: CGSize(width: 5, height: 9), cornerRadius: 2)
        tooth.position = CGPoint(x: 15, y: -4)
        tooth.fillColor = SceneColor.gold
        tooth.strokeColor = .clear
        node.addChild(tooth)

        return node
    }

    private func makeBoxNode() -> SKNode {
        let node = SKNode()
        let box = SKShapeNode(rectOf: CGSize(width: tileSize - 12, height: tileSize - 12), cornerRadius: 14)
        box.fillColor = SceneColor.box
        box.strokeColor = SceneColor.cream
        box.lineWidth = 3
        node.addChild(box)

        let strapVertical = SKShapeNode(rectOf: CGSize(width: 5, height: tileSize - 18), cornerRadius: 2)
        strapVertical.fillColor = SceneColor.boxBand
        strapVertical.strokeColor = .clear
        node.addChild(strapVertical)

        let strapHorizontal = SKShapeNode(rectOf: CGSize(width: tileSize - 18, height: 5), cornerRadius: 2)
        strapHorizontal.fillColor = SceneColor.boxBand
        strapHorizontal.strokeColor = .clear
        node.addChild(strapHorizontal)

        return node
    }

    private func makeButtonNode(isPressed: Bool) -> SKNode {
        let node = SKNode()
        let base = SKShapeNode(circleOfRadius: 17)
        base.fillColor = SceneColor.cream
        base.strokeColor = SceneColor.boardStroke
        base.lineWidth = 2
        node.addChild(base)

        let button = SKShapeNode(circleOfRadius: isPressed ? 10 : 13)
        button.fillColor = isPressed ? SceneColor.success : SceneColor.alert
        button.strokeColor = .clear
        node.addChild(button)

        return node
    }

    private func makeDoorNode(isOpen: Bool) -> SKNode {
        let node = SKNode()
        let door = SKShapeNode(rectOf: CGSize(width: tileSize - 14, height: tileSize - 8), cornerRadius: 14)
        door.fillColor = isOpen ? SceneColor.success.withAlphaComponent(0.55) : SceneColor.lockedDoor
        door.strokeColor = SceneColor.cream
        door.lineWidth = 3
        node.addChild(door)

        let band = SKShapeNode(rectOf: CGSize(width: tileSize - 22, height: 4), cornerRadius: 2)
        band.fillColor = SceneColor.gold.withAlphaComponent(isOpen ? 0.4 : 0.85)
        band.strokeColor = .clear
        node.addChild(band)

        return node
    }

    private func makeBridgeNode(isEnabled: Bool) -> SKNode {
        let node = SKNode()
        let bridge = SKShapeNode(rectOf: CGSize(width: tileSize - 8, height: tileSize - 16), cornerRadius: 13)
        bridge.fillColor = isEnabled ? SceneColor.bridge : SceneColor.exitLocked.withAlphaComponent(0.6)
        bridge.strokeColor = SceneColor.cream.withAlphaComponent(0.8)
        bridge.lineWidth = 2
        node.addChild(bridge)

        for offset in [-10, 0, 10] {
            let plank = SKShapeNode(rectOf: CGSize(width: 3, height: tileSize - 22), cornerRadius: 1.5)
            plank.position = CGPoint(x: CGFloat(offset), y: 0)
            plank.fillColor = SceneColor.cream.withAlphaComponent(isEnabled ? 0.4 : 0.18)
            plank.strokeColor = .clear
            node.addChild(plank)
        }

        return node
    }

    private func makeMysteryNode() -> SKNode {
        let node = SKNode()
        let marker = SKShapeNode(circleOfRadius: 14)
        marker.fillColor = SceneColor.moonBlue
        marker.strokeColor = SceneColor.cream
        marker.lineWidth = 2
        node.addChild(marker)
        return node
    }

    private func makeCatNode() -> SKNode {
        if let cat = makeTextureNode(named: VisualAssetManifest.player, size: CGSize(width: tileSize, height: tileSize)) {
            return cat
        }

        let node = SKNode()
        let shadow = SKShapeNode(ellipseOf: CGSize(width: 40, height: 12))
        shadow.position = CGPoint(x: 0, y: -17)
        shadow.fillColor = SceneColor.shadow
        shadow.strokeColor = .clear
        node.addChild(shadow)

        let leftEar = SKShapeNode(path: trianglePath(points: [
            CGPoint(x: -15, y: 7),
            CGPoint(x: -8, y: 24),
            CGPoint(x: -1, y: 7)
        ]))
        leftEar.fillColor = SceneColor.catOrange
        leftEar.strokeColor = SceneColor.cream
        leftEar.lineWidth = 3
        node.addChild(leftEar)

        let rightEar = SKShapeNode(path: trianglePath(points: [
            CGPoint(x: 15, y: 7),
            CGPoint(x: 8, y: 24),
            CGPoint(x: 1, y: 7)
        ]))
        rightEar.fillColor = SceneColor.catOrange
        rightEar.strokeColor = SceneColor.cream
        rightEar.lineWidth = 3
        node.addChild(rightEar)

        let face = SKShapeNode(circleOfRadius: 19)
        face.fillColor = SceneColor.catOrange
        face.strokeColor = SceneColor.cream
        face.lineWidth = 4
        node.addChild(face)

        for x in [-7, 7] {
            let eye = SKShapeNode(circleOfRadius: 2.6)
            eye.position = CGPoint(x: CGFloat(x), y: 2)
            eye.fillColor = SceneColor.walnut
            eye.strokeColor = .clear
            node.addChild(eye)
        }

        let cheekLeft = SKShapeNode(circleOfRadius: 3.2)
        cheekLeft.position = CGPoint(x: -9, y: -5)
        cheekLeft.fillColor = SceneColor.blush
        cheekLeft.strokeColor = .clear
        node.addChild(cheekLeft)

        let cheekRight = SKShapeNode(circleOfRadius: 3.2)
        cheekRight.position = CGPoint(x: 9, y: -5)
        cheekRight.fillColor = SceneColor.blush
        cheekRight.strokeColor = .clear
        node.addChild(cheekRight)

        let nose = SKShapeNode(circleOfRadius: 2.6)
        nose.position = CGPoint(x: 0, y: -4)
        nose.fillColor = SceneColor.walnut.withAlphaComponent(0.75)
        nose.strokeColor = .clear
        node.addChild(nose)

        return node
    }

    private func objectTextureState(for object: GameObject) -> Bool {
        switch object.type {
        case "button":
            return engine.isButtonPressed(object)
        case "door":
            return engine.openedTargetIds.contains(object.id)
        case "bridge":
            return engine.isTargetEnabled(id: object.id)
        default:
            return true
        }
    }

    private func makeTextureNode(named name: String, size: CGSize) -> SKSpriteNode? {
        guard let texture = texture(named: name) else {
            return nil
        }

        return SKSpriteNode(texture: texture, color: .clear, size: size)
    }

    private func texture(named name: String) -> SKTexture? {
        if let cached = textureCache[name] {
            return cached
        }

        guard
            let url = Bundle.main.url(forResource: name, withExtension: "png", subdirectory: "GameData/Art"),
            let image = UIImage(contentsOfFile: url.path)
        else {
            return nil
        }

        let texture = SKTexture(image: image)
        texture.filteringMode = .linear
        textureCache[name] = texture
        return texture
    }

    private func trianglePath(points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        guard let first = points.first else {
            return path
        }

        path.move(to: first)
        points.dropFirst().forEach { path.addLine(to: $0) }
        path.closeSubpath()
        return path
    }

    private func floorColor(at position: GridPosition) -> SKColor {
        if (position.x + position.y).isMultiple(of: 2) {
            return roomTheme.floorLight
        }

        return roomTheme.floorDark
    }

    private func floorTextureName(at position: GridPosition) -> String {
        if (position.x + position.y).isMultiple(of: 2) {
            return VisualAssetManifest.floorLight
        }

        return VisualAssetManifest.floorDark
    }

    private func moveTowardTap(_ tapPoint: CGPoint) {
        let target = gridPosition(for: tapPoint)
        let dx = target.x - engine.playerPosition.x
        let dy = target.y - engine.playerPosition.y

        if abs(dx) + abs(dy) != 1 {
            return
        }

        if dx == 1 {
            move(.right)
        } else if dx == -1 {
            move(.left)
        } else if dy == 1 {
            move(.down)
        } else if dy == -1 {
            move(.up)
        }
    }

    private func move(_ direction: MoveDirection) {
        let outcome = engine.move(direction)
        guard outcome != .blocked else {
            onAudioFeedback?(.blocked)
            return
        }

        onMove?()
        onAudioFeedback?(.move)

        let action = SKAction.move(to: point(for: engine.playerPosition), duration: 0.12)
        playerNode.run(action) { [weak self] in
            guard let self else {
                return
            }

            self.renderLevel()
            if case let .cleared(result) = outcome {
                self.onAudioFeedback?(.clear)
                self.onRoomCleared?(result)
            }
        }
    }

    func undoLastMove() {
        guard engine.undo() else {
            return
        }

        onUndo?()
        onAudioFeedback?(.undo)
        renderLevel()
    }

    private func point(for position: GridPosition) -> CGPoint {
        let boardWidth = CGFloat(level.width) * tileSize
        let boardHeight = CGFloat(level.height) * tileSize
        let originX = (size.width - boardWidth) / 2 + tileSize / 2
        let originY = (size.height - boardHeight) / 2 + tileSize / 2

        return CGPoint(
            x: originX + CGFloat(position.x) * tileSize,
            y: originY + CGFloat(level.height - 1 - position.y) * tileSize
        )
    }

    private var boardRect: CGRect {
        let boardWidth = CGFloat(level.width) * tileSize
        let boardHeight = CGFloat(level.height) * tileSize
        let originX = (size.width - boardWidth) / 2
        let originY = (size.height - boardHeight) / 2

        return CGRect(x: originX, y: originY, width: boardWidth, height: boardHeight)
    }

    private func gridPosition(for point: CGPoint) -> GridPosition {
        let boardWidth = CGFloat(level.width) * tileSize
        let boardHeight = CGFloat(level.height) * tileSize
        let originX = (size.width - boardWidth) / 2
        let originY = (size.height - boardHeight) / 2
        let x = Int((point.x - originX) / tileSize)
        let invertedY = Int((point.y - originY) / tileSize)
        let y = level.height - 1 - invertedY

        return GridPosition(x: x, y: y)
    }
}

private enum SceneColor {
    static let cream = SKColor(red: 1.00, green: 0.97, blue: 0.88, alpha: 1)
    static let boardBase = SKColor(red: 0.76, green: 0.45, blue: 0.26, alpha: 1)
    static let boardStroke = SKColor(red: 0.46, green: 0.22, blue: 0.12, alpha: 1)
    static let floorLight = SKColor(red: 1.00, green: 0.77, blue: 0.48, alpha: 1)
    static let floorDark = SKColor(red: 0.96, green: 0.64, blue: 0.36, alpha: 1)
    static let tileStroke = SKColor(red: 0.78, green: 0.43, blue: 0.23, alpha: 0.34)
    static let wall = SKColor(red: 0.50, green: 0.26, blue: 0.16, alpha: 1)
    static let wallHighlight = SKColor(red: 0.74, green: 0.42, blue: 0.25, alpha: 1)
    static let walnut = SKColor(red: 0.34, green: 0.16, blue: 0.10, alpha: 1)
    static let catOrange = SKColor(red: 1.00, green: 0.55, blue: 0.18, alpha: 1)
    static let blush = SKColor(red: 1.00, green: 0.70, blue: 0.64, alpha: 0.82)
    static let gold = SKColor(red: 1.00, green: 0.76, blue: 0.27, alpha: 1)
    static let success = SKColor(red: 0.32, green: 0.74, blue: 0.45, alpha: 1)
    static let alert = SKColor(red: 0.95, green: 0.30, blue: 0.25, alpha: 1)
    static let exitOpen = SKColor(red: 0.32, green: 0.74, blue: 0.45, alpha: 1)
    static let exitLocked = SKColor(red: 0.55, green: 0.57, blue: 0.66, alpha: 1)
    static let box = SKColor(red: 0.68, green: 0.42, blue: 0.23, alpha: 1)
    static let boxBand = SKColor(red: 0.46, green: 0.22, blue: 0.12, alpha: 1)
    static let lockedDoor = SKColor(red: 0.46, green: 0.27, blue: 0.18, alpha: 1)
    static let bridge = SKColor(red: 0.48, green: 0.65, blue: 0.90, alpha: 1)
    static let moonBlue = SKColor(red: 0.36, green: 0.48, blue: 0.88, alpha: 1)
    static let shadow = SKColor(red: 0.32, green: 0.16, blue: 0.08, alpha: 0.18)
}

private struct RoomTheme {
    let background: SKColor
    let boardBase: SKColor
    let boardStroke: SKColor
    let floorLight: SKColor
    let floorDark: SKColor
    let tileStroke: SKColor
    let wall: SKColor
    let wallHighlight: SKColor

    init(levelId: String) {
        let number = Int(levelId.replacingOccurrences(of: "level_", with: "")) ?? 1

        switch number {
        case 4...6:
            background = SKColor(red: 0.90, green: 0.95, blue: 0.88, alpha: 1)
            boardBase = SKColor(red: 0.38, green: 0.50, blue: 0.34, alpha: 1)
            boardStroke = SKColor(red: 0.18, green: 0.28, blue: 0.18, alpha: 1)
            floorLight = SKColor(red: 0.76, green: 0.86, blue: 0.63, alpha: 1)
            floorDark = SKColor(red: 0.67, green: 0.78, blue: 0.55, alpha: 1)
            tileStroke = SKColor(red: 0.38, green: 0.50, blue: 0.34, alpha: 0.35)
            wall = SKColor(red: 0.19, green: 0.30, blue: 0.18, alpha: 1)
            wallHighlight = SKColor(red: 0.30, green: 0.43, blue: 0.25, alpha: 1)
        case 7...10:
            background = SKColor(red: 0.88, green: 0.91, blue: 0.98, alpha: 1)
            boardBase = SKColor(red: 0.30, green: 0.37, blue: 0.55, alpha: 1)
            boardStroke = SKColor(red: 0.16, green: 0.20, blue: 0.35, alpha: 1)
            floorLight = SKColor(red: 0.68, green: 0.75, blue: 0.90, alpha: 1)
            floorDark = SKColor(red: 0.57, green: 0.66, blue: 0.84, alpha: 1)
            tileStroke = SKColor(red: 0.30, green: 0.37, blue: 0.55, alpha: 0.35)
            wall = SKColor(red: 0.17, green: 0.21, blue: 0.36, alpha: 1)
            wallHighlight = SKColor(red: 0.28, green: 0.34, blue: 0.54, alpha: 1)
        default:
            background = SceneColor.cream
            boardBase = SceneColor.boardBase
            boardStroke = SceneColor.boardStroke
            floorLight = SceneColor.floorLight
            floorDark = SceneColor.floorDark
            tileStroke = SceneColor.tileStroke
            wall = SceneColor.wall
            wallHighlight = SceneColor.wallHighlight
        }
    }
}
