import Testing
@testable import CatLogicMansionCore

@Suite("VisualAssetManifest")
struct VisualAssetManifestTests {
    @Test("core gameplay assets expose stable texture names")
    func coreGameplayAssetsExposeStableTextureNames() {
        #expect(VisualAssetManifest.floorLight == "art_floor_light")
        #expect(VisualAssetManifest.floorDark == "art_floor_dark")
        #expect(VisualAssetManifest.wall == "art_wall")
        #expect(VisualAssetManifest.player == "art_cat_miso")
        #expect(VisualAssetManifest.exitOpen == "art_exit_open")
        #expect(VisualAssetManifest.exitLocked == "art_exit_locked")

        #expect(VisualAssetManifest.textureName(forObjectType: "collectible", isEnabled: true) == "art_treat")
        #expect(VisualAssetManifest.textureName(forObjectType: "key", isEnabled: true) == "art_key")
        #expect(VisualAssetManifest.textureName(forObjectType: "box", isEnabled: true) == "art_box")
        #expect(VisualAssetManifest.textureName(forObjectType: "button", isEnabled: false) == "art_button_up")
        #expect(VisualAssetManifest.textureName(forObjectType: "button", isEnabled: true) == "art_button_down")
        #expect(VisualAssetManifest.textureName(forObjectType: "door", isEnabled: false) == "art_door_locked")
        #expect(VisualAssetManifest.textureName(forObjectType: "door", isEnabled: true) == "art_door_open")
        #expect(VisualAssetManifest.textureName(forObjectType: "bridge", isEnabled: false) == "art_bridge_disabled")
        #expect(VisualAssetManifest.textureName(forObjectType: "bridge", isEnabled: true) == "art_bridge_enabled")
        #expect(VisualAssetManifest.textureName(forObjectType: "unknown", isEnabled: true) == "art_unknown")
    }

    @Test("object render order keeps floor controls below boxes")
    func objectRenderOrderKeepsFloorControlsBelowBoxes() {
        #expect(VisualAssetManifest.renderZPosition(forObjectType: "button") < VisualAssetManifest.renderZPosition(forObjectType: "box"))
        #expect(VisualAssetManifest.renderZPosition(forObjectType: "bridge") < VisualAssetManifest.renderZPosition(forObjectType: "box"))
        #expect(VisualAssetManifest.renderZPosition(forObjectType: "collectible") > VisualAssetManifest.renderZPosition(forObjectType: "box"))
    }
}
