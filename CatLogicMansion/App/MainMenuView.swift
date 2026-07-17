import SwiftUI

struct MainMenuView: View {
    let totalStars: Int
    let onPlay: () -> Void
    let onSelectLevels: () -> Void
    let onOpenSettings: () -> Void

    var body: some View {
        ZStack {
            MansionBackground()

            VStack(spacing: 28) {
                Spacer(minLength: 28)

                VStack(spacing: 14) {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 64, weight: .black))
                        .foregroundStyle(AppDesign.ColorToken.catOrange)
                        .frame(width: 112, height: 112)
                        .background(AppDesign.ColorToken.cream.opacity(0.82))
                        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.sheet))
                        .shadow(color: AppDesign.ColorToken.catOrange.opacity(0.2), radius: 18, y: 10)

                    Text(L10n.tr("app.name"))
                        .font(.system(size: 42, weight: .black, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppDesign.ColorToken.walnut)

                    Text(L10n.tr("menu.subtitle"))
                        .font(.callout.weight(.semibold))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.68))
                        .fixedSize(horizontal: false, vertical: true)
                }

                VStack(spacing: 12) {
                    Label("\(totalStars)/30 \(L10n.tr("level_select.stars_suffix"))", systemImage: "star.fill")
                    Label(L10n.tr("level_select.offline"), systemImage: "wifi.slash")
                    Label(L10n.tr("level_select.no_ads"), systemImage: "sparkles")
                }
                .font(.caption.bold())
                .foregroundStyle(AppDesign.ColorToken.moonBlue)

                VStack(spacing: 14) {
                    Button(action: onPlay) {
                        Label(L10n.tr("menu.play"), systemImage: "play.fill")
                    }
                    .buttonStyle(MenuPrimaryButtonStyle())

                    Button(action: onSelectLevels) {
                        Label(L10n.tr("menu.levels"), systemImage: "square.grid.2x2.fill")
                    }
                    .buttonStyle(MenuSecondaryButtonStyle())

                    Button(action: onOpenSettings) {
                        Label(L10n.tr("settings.title"), systemImage: "gearshape.fill")
                    }
                    .buttonStyle(MenuSecondaryButtonStyle())
                }
                .frame(maxWidth: 320)

                Spacer(minLength: 32)
            }
            .padding(24)
        }
    }
}

private struct MenuPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [
                        AppDesign.ColorToken.catOrange.opacity(configuration.isPressed ? 0.78 : 1),
                        AppDesign.ColorToken.peach.opacity(configuration.isPressed ? 0.72 : 1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
            .shadow(color: AppDesign.ColorToken.catOrange.opacity(0.22), radius: 10, y: 5)
    }
}

private struct MenuSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.bold())
            .foregroundStyle(AppDesign.ColorToken.walnut)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(AppDesign.ColorToken.cream.opacity(configuration.isPressed ? 0.52 : 0.82))
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
            .overlay {
                RoundedRectangle(cornerRadius: AppDesign.Radius.control)
                    .stroke(AppDesign.ColorToken.peach.opacity(0.3), lineWidth: 2)
            }
    }
}
