public enum VisualAssetManifest {
    public static let floorLight = "art_floor_light"
    public static let floorDark = "art_floor_dark"
    public static let wall = "art_wall"
    public static let player = "art_cat_miso"
    public static let exitOpen = "art_exit_open"
    public static let exitLocked = "art_exit_locked"

    public static func textureName(forObjectType objectType: String, isEnabled: Bool) -> String {
        switch objectType {
        case "collectible":
            return "art_treat"
        case "key":
            return "art_key"
        case "box":
            return "art_box"
        case "button":
            return isEnabled ? "art_button_down" : "art_button_up"
        case "door":
            return isEnabled ? "art_door_open" : "art_door_locked"
        case "bridge":
            return isEnabled ? "art_bridge_enabled" : "art_bridge_disabled"
        default:
            return "art_unknown"
        }
    }

    public static func renderZPosition(forObjectType objectType: String) -> Double {
        switch objectType {
        case "button", "bridge":
            6
        case "box", "door":
            8
        case "collectible", "key":
            9
        default:
            7
        }
    }
}
