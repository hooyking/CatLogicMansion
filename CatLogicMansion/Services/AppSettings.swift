import Foundation

@MainActor
final class AppSettings: ObservableObject {
    nonisolated static let soundPreferenceKey = "cat_logic_mansion.sound_enabled"
    nonisolated static let musicPreferenceKey = "cat_logic_mansion.music_enabled"

    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: L10n.languagePreferenceKey)
        }
    }

    @Published var isSoundEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isSoundEnabled, forKey: Self.soundPreferenceKey)
        }
    }

    @Published var isMusicEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isMusicEnabled, forKey: Self.musicPreferenceKey)
        }
    }

    init() {
        let rawValue = UserDefaults.standard.string(forKey: L10n.languagePreferenceKey) ?? AppLanguage.system.rawValue
        language = AppLanguage(rawValue: rawValue) ?? .system
        isSoundEnabled = UserDefaults.standard.object(forKey: Self.soundPreferenceKey) as? Bool ?? true
        isMusicEnabled = UserDefaults.standard.object(forKey: Self.musicPreferenceKey) as? Bool ?? true
    }

    var versionDisplay: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "0.1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

enum AppLanguage: String, CaseIterable, Identifiable {
    case system
    case english = "en"
    case simplifiedChinese = "zh-Hans"
    case traditionalChinese = "zh-Hant"

    var id: String {
        rawValue
    }

    var titleKey: String {
        switch self {
        case .system:
            "settings.language.system"
        case .english:
            "settings.language.english"
        case .simplifiedChinese:
            "settings.language.zh_hans"
        case .traditionalChinese:
            "settings.language.zh_hant"
        }
    }
}
