import SwiftUI

enum AppDesign {
    enum ColorToken {
        static let parchment = Color(red: 1.00, green: 0.90, blue: 0.72)
        static let parchmentDeep = Color(red: 0.98, green: 0.72, blue: 0.46)
        static let walnut = Color(red: 0.34, green: 0.16, blue: 0.10)
        static let walnutSoft = Color(red: 0.57, green: 0.34, blue: 0.21)
        static let catOrange = Color(red: 1.00, green: 0.55, blue: 0.18)
        static let peach = Color(red: 1.00, green: 0.75, blue: 0.45)
        static let bubblePink = Color(red: 1.00, green: 0.72, blue: 0.76)
        static let moonBlue = Color(red: 0.36, green: 0.48, blue: 0.88)
        static let mint = Color(red: 0.56, green: 0.82, blue: 0.58)
        static let cream = Color(red: 1.00, green: 0.97, blue: 0.87)
        static let success = Color(red: 0.30, green: 0.72, blue: 0.43)
    }

    enum Radius {
        static let card: CGFloat = 32
        static let control: CGFloat = 24
        static let sheet: CGFloat = 38
    }

    enum Shadow {
        static let card = Color(red: 0.42, green: 0.20, blue: 0.10).opacity(0.16)
    }
}

struct MansionBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppDesign.ColorToken.cream,
                AppDesign.ColorToken.parchment,
                AppDesign.ColorToken.bubblePink.opacity(0.45),
                AppDesign.ColorToken.parchmentDeep.opacity(0.78)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay {
            RadialGradient(
                colors: [
                    AppDesign.ColorToken.catOrange.opacity(0.22),
                    AppDesign.ColorToken.peach.opacity(0.18),
                    .clear
                ],
                center: .topTrailing,
                startRadius: 20,
                endRadius: 360
            )
        }
        .ignoresSafeArea()
    }
}
