import SwiftUI

struct SettingsDrawerView: View {
    @ObservedObject var appSettings: AppSettings
    let onClose: () -> Void

    @State private var isLanguagePickerOpen = false

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            header
            languageSection
            audioSection
            Spacer()
            versionSection
        }
        .padding(22)
        .frame(width: min(UIScreen.main.bounds.width * 0.82, 340), alignment: .leading)
        .frame(maxHeight: .infinity)
        .background(.regularMaterial)
        .overlay(alignment: .trailing) {
            Rectangle()
                .fill(AppDesign.ColorToken.walnut.opacity(0.08))
                .frame(width: 1)
        }
        .ignoresSafeArea(edges: .vertical)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.tr("settings.title"))
                    .font(.system(size: 30, weight: .black, design: .rounded))
                    .foregroundStyle(AppDesign.ColorToken.walnut)

                Text(L10n.tr("app.name"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.62))
            }

            Spacer()

            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppDesign.ColorToken.walnut)
                    .frame(width: 40, height: 40)
                    .background(AppDesign.ColorToken.cream.opacity(0.76))
                    .clipShape(Circle())
            }
        }
        .padding(.top, 46)
    }

    private var versionSection: some View {
        HStack {
            Text(L10n.tr("settings.version"))
            Spacer()
            Text(appSettings.versionDisplay)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.48))
        .padding(.bottom, 18)
    }

    private var languageSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                    isLanguagePickerOpen.toggle()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "globe")
                        .foregroundStyle(AppDesign.ColorToken.catOrange)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(L10n.tr("settings.language"))
                            .font(.caption.bold())
                            .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.54))

                        Text(L10n.tr(appSettings.language.titleKey))
                            .font(.headline.weight(.bold))
                            .foregroundStyle(AppDesign.ColorToken.walnut)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.black))
                        .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.42))
                        .rotationEffect(.degrees(isLanguagePickerOpen ? 90 : 0))
                }
                .padding(16)
                .background(AppDesign.ColorToken.cream.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
            }
            .buttonStyle(.plain)

            if isLanguagePickerOpen {
                VStack(spacing: 6) {
                    ForEach(AppLanguage.allCases) { language in
                        languageOption(language)
                    }
                }
                .padding(10)
                .background(AppDesign.ColorToken.cream.opacity(0.48))
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private var audioSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            settingsToggle(
                title: L10n.tr("settings.sound"),
                iconName: appSettings.isSoundEnabled ? "speaker.wave.2.fill" : "speaker.slash.fill",
                isOn: $appSettings.isSoundEnabled
            )

            settingsToggle(
                title: L10n.tr("settings.music"),
                iconName: appSettings.isMusicEnabled ? "music.note" : "music.note.list",
                isOn: $appSettings.isMusicEnabled
            )
        }
    }

    private func settingsToggle(title: String, iconName: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            HStack(spacing: 12) {
                Image(systemName: iconName)
                    .foregroundStyle(AppDesign.ColorToken.catOrange)
                    .frame(width: 22)

                Text(title)
                    .font(.headline.weight(.bold))
                    .foregroundStyle(AppDesign.ColorToken.walnut)
            }
        }
        .toggleStyle(SwitchToggleStyle(tint: AppDesign.ColorToken.catOrange))
        .padding(16)
        .background(AppDesign.ColorToken.cream.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
    }

    private func languageOption(_ language: AppLanguage) -> some View {
        Button {
            appSettings.language = language
            withAnimation(.spring(response: 0.28, dampingFraction: 0.88)) {
                isLanguagePickerOpen = false
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: appSettings.language == language ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(appSettings.language == language ? AppDesign.ColorToken.success : AppDesign.ColorToken.walnut.opacity(0.36))

                Text(L10n.tr(language.titleKey))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppDesign.ColorToken.walnut)

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                appSettings.language == language
                    ? AppDesign.ColorToken.catOrange.opacity(0.12)
                    : Color.clear
            )
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
        }
        .buttonStyle(.plain)
    }
}
