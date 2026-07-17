import Foundation

enum L10n {
    static let languagePreferenceKey = "cat_logic_mansion.language_preference"

    static func tr(_ key: String) -> String {
        translations[currentLanguageCode]?[key] ?? translations["en"]?[key] ?? key
    }

    static var currentLanguageCode: String {
        let preference = UserDefaults.standard.string(forKey: languagePreferenceKey) ?? "system"

        if translations.keys.contains(preference) {
            return preference
        }

        return systemLanguageCode
    }

    private static var systemLanguageCode: String {
        let identifier = Locale.current.identifier

        if identifier.hasPrefix("zh_Hant") || identifier.hasPrefix("zh-Hant") || identifier.contains("Hant") {
            return "zh-Hant"
        }

        if identifier.hasPrefix("zh") {
            return "zh-Hans"
        }

        return "en"
    }

    private static let translations: [String: [String: String]] = [
        "en": load("en"),
        "zh-Hans": load("zh-Hans"),
        "zh-Hant": load("zh-Hant")
    ]

    private static func load(_ languageCode: String) -> [String: String] {
        guard let url = Bundle.main.url(
            forResource: "\(languageCode).json",
            withExtension: nil,
            subdirectory: "GameData/Localization"
        ) else {
            return [:]
        }

        do {
            let data = try Data(contentsOf: url)
            return try JSONDecoder().decode([String: String].self, from: data)
        } catch {
            return [:]
        }
    }
}
