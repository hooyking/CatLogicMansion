import Foundation
import Testing
@testable import CatLogicMansionCore

@MainActor
@Suite("AppSettings")
struct AppSettingsTests {
    @Test("sound and music default to enabled")
    func soundAndMusicDefaultToEnabled() {
        resetSettings()

        let settings = AppSettings()

        #expect(settings.isSoundEnabled)
        #expect(settings.isMusicEnabled)
    }

    @Test("sound and music preferences persist")
    func soundAndMusicPreferencesPersist() {
        resetSettings()

        let settings = AppSettings()
        settings.isSoundEnabled = false
        settings.isMusicEnabled = false

        let restoredSettings = AppSettings()

        #expect(!restoredSettings.isSoundEnabled)
        #expect(!restoredSettings.isMusicEnabled)
    }

    @Test("language preference persists")
    func languagePreferencePersists() {
        resetSettings()

        let settings = AppSettings()
        settings.language = .simplifiedChinese

        let restoredSettings = AppSettings()

        #expect(restoredSettings.language == .simplifiedChinese)
        #expect(L10n.currentLanguageCode == "zh-Hans")
    }

    @Test("language title keys are stable")
    func languageTitleKeysAreStable() {
        #expect(AppLanguage.system.titleKey == "settings.language.system")
        #expect(AppLanguage.english.titleKey == "settings.language.english")
        #expect(AppLanguage.simplifiedChinese.titleKey == "settings.language.zh_hans")
        #expect(AppLanguage.traditionalChinese.titleKey == "settings.language.zh_hant")
    }

    @Test("localization falls back to keys for missing strings")
    func localizationFallsBackToKeysForMissingStrings() {
        resetSettings()
        UserDefaults.standard.set("en", forKey: L10n.languagePreferenceKey)

        #expect(L10n.currentLanguageCode == "en")
        #expect(L10n.tr("missing.test.key") == "missing.test.key")
    }

    @Test("version display includes version and build")
    func versionDisplayIncludesVersionAndBuild() {
        resetSettings()

        let settings = AppSettings()

        #expect(!settings.versionDisplay.isEmpty)
        #expect(settings.versionDisplay.contains("("))
        #expect(settings.versionDisplay.contains(")"))
    }
}

private func resetSettings() {
    UserDefaults.standard.removeObject(forKey: L10n.languagePreferenceKey)
    UserDefaults.standard.removeObject(forKey: AppSettings.soundPreferenceKey)
    UserDefaults.standard.removeObject(forKey: AppSettings.musicPreferenceKey)
}
