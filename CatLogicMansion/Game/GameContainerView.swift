import SpriteKit
import SwiftUI

struct GameContainerView: View {
    let levelId: String
    var launchMoves: [MoveDirection] = []
    var onLevelCleared: (GameResult) -> Void = { _ in }
    var onNextLevel: () -> Void = {}
    var onAudioFeedback: (AudioFeedback) -> Void = { _ in }

    @StateObject private var viewModel = GameViewModel()

    var body: some View {
        ZStack {
            MansionBackground()

            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(L10n.tr("game.moves"))
                            .font(.caption)
                            .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.62))
                        Text("\(viewModel.moveCount)")
                            .font(.system(size: 28, weight: .black, design: .rounded))
                            .foregroundStyle(AppDesign.ColorToken.walnut)
                    }

                    Spacer()

                    Button {
                        viewModel.undo()
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .accessibilityLabel(Text(L10n.tr("game.undo")))
                    .buttonStyle(MansionIconButtonStyle(tint: AppDesign.ColorToken.walnut, isPrimary: false))

                    Button {
                        viewModel.reset()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel(Text(L10n.tr("game.reset")))
                    .buttonStyle(MansionIconButtonStyle(tint: .white, isPrimary: true))
                }
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.card))
                .overlay {
                    RoundedRectangle(cornerRadius: AppDesign.Radius.card)
                        .stroke(AppDesign.ColorToken.cream.opacity(0.9), lineWidth: 2)
                }
                .shadow(color: AppDesign.Shadow.card, radius: 16, y: 8)
                .padding()

                if !viewModel.tutorialText.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(AppDesign.ColorToken.catOrange)

                        Text(viewModel.tutorialText)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.76))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(AppDesign.ColorToken.cream.opacity(0.76))
                    .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
                    .overlay {
                        RoundedRectangle(cornerRadius: AppDesign.Radius.control)
                            .stroke(AppDesign.ColorToken.peach.opacity(0.32), lineWidth: 2)
                    }
                    .shadow(color: AppDesign.Shadow.card, radius: 10, y: 5)
                    .padding(.horizontal)
                }

                if let scene = viewModel.scene {
                    SpriteView(scene: scene)
                        .id(ObjectIdentifier(scene))
                        .clipShape(RoundedRectangle(cornerRadius: 34))
                        .padding(.horizontal, 14)
                        .padding(.bottom, 18)
                }
            }

            if let result = viewModel.result {
                ResultOverlay(
                    result: result,
                    onRetry: {
                        viewModel.reset()
                    },
                    onNext: onNextLevel
                )
            }

        }
        .onAppear {
            viewModel.onAudioFeedback = onAudioFeedback
            viewModel.load(levelId: levelId)
            viewModel.applyLaunchMoves(launchMoves)
        }
        .onChange(of: levelId) { _, newValue in
            viewModel.load(levelId: newValue)
            viewModel.applyLaunchMoves(launchMoves)
        }
        .onChange(of: viewModel.result) { _, newValue in
            if let result = newValue {
                onLevelCleared(result)
            }
        }
    }
}

private struct ResultOverlay: View {
    let result: GameResult
    let onRetry: () -> Void
    let onNext: () -> Void

    var body: some View {
        ZStack {
            Color(red: 0.28, green: 0.14, blue: 0.08).opacity(0.34)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                Text(L10n.tr("result.completed"))
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .foregroundStyle(AppDesign.ColorToken.walnut)

                HStack(spacing: 8) {
                    ForEach(1...3, id: \.self) { index in
                        Image(systemName: index <= result.stars ? "star.fill" : "star")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundStyle(index <= result.stars ? AppDesign.ColorToken.peach : .gray.opacity(0.45))
                    }
                }

                VStack(spacing: 8) {
                    HStack {
                        Text(L10n.tr("result.moves"))
                        Spacer()
                        Text("\(result.moves)")
                    }

                    HStack {
                        Text(L10n.tr("result.target_steps"))
                        Spacer()
                        Text("\(result.targetSteps)")
                    }

                    HStack {
                        Text(L10n.tr("result.items"))
                        Spacer()
                        Text(result.collectedAllItems ? L10n.tr("result.items_all") : L10n.tr("result.items_missing"))
                    }
                }
                .font(.subheadline)
                .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.68))
                .padding(14)
                .background(AppDesign.ColorToken.cream.opacity(0.72))
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))

                VStack(spacing: 8) {
                    StarConditionRow(
                        title: L10n.tr("result.star_clear"),
                        isCompleted: true
                    )
                    StarConditionRow(
                        title: L10n.tr("result.star_collect_all"),
                        isCompleted: result.collectedAllItems
                    )
                    StarConditionRow(
                        title: L10n.tr("result.star_target_moves"),
                        isCompleted: result.moves <= result.targetSteps
                    )
                }
                .padding(14)
                .background(AppDesign.ColorToken.cream.opacity(0.48))
                .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))

                HStack(spacing: 12) {
                    Button(L10n.tr("result.retry"), action: onRetry)
                        .buttonStyle(MansionSecondaryButtonStyle())

                    Button(L10n.tr("result.next_level"), action: onNext)
                        .buttonStyle(MansionPrimaryButtonStyle())
                }
            }
            .padding(24)
            .frame(maxWidth: 340)
            .background(
                LinearGradient(
                    colors: [
                        AppDesign.ColorToken.cream.opacity(0.96),
                        AppDesign.ColorToken.parchment.opacity(0.9)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .overlay {
                RoundedRectangle(cornerRadius: AppDesign.Radius.sheet)
                    .stroke(AppDesign.ColorToken.cream.opacity(0.95), lineWidth: 3)
            }
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.sheet))
            .shadow(radius: 24)
            .padding(24)
        }
    }
}

private struct StarConditionRow: View {
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(isCompleted ? AppDesign.ColorToken.success : AppDesign.ColorToken.walnut.opacity(0.34))

            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppDesign.ColorToken.walnut.opacity(isCompleted ? 0.78 : 0.48))

            Spacer()
        }
    }
}

private struct MansionPrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 18)
            .padding(.vertical, 12)
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
            .shadow(color: AppDesign.ColorToken.catOrange.opacity(0.22), radius: 8, y: 4)
    }
}

private struct MansionIconButtonStyle: ButtonStyle {
    let tint: Color
    let isPrimary: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .bold, design: .rounded))
            .foregroundStyle(tint)
            .frame(width: 46, height: 46)
            .background(background(isPressed: configuration.isPressed))
            .clipShape(Circle())
            .overlay {
                Circle()
                    .stroke(AppDesign.ColorToken.cream.opacity(isPrimary ? 0.72 : 0.95), lineWidth: 2)
            }
            .shadow(
                color: AppDesign.ColorToken.walnut.opacity(configuration.isPressed ? 0.08 : 0.14),
                radius: configuration.isPressed ? 3 : 8,
                y: configuration.isPressed ? 1 : 4
            )
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
    }

    @ViewBuilder
    private func background(isPressed: Bool) -> some View {
        if isPrimary {
            LinearGradient(
                colors: [
                    AppDesign.ColorToken.catOrange.opacity(isPressed ? 0.78 : 1),
                    AppDesign.ColorToken.peach.opacity(isPressed ? 0.72 : 1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            AppDesign.ColorToken.cream.opacity(isPressed ? 0.54 : 0.86)
        }
    }
}

private struct MansionSecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.bold())
            .foregroundStyle(AppDesign.ColorToken.walnut)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(AppDesign.ColorToken.cream.opacity(configuration.isPressed ? 0.48 : 0.82))
            .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.control))
            .overlay {
                RoundedRectangle(cornerRadius: AppDesign.Radius.control)
                    .stroke(AppDesign.ColorToken.peach.opacity(0.28), lineWidth: 2)
            }
    }
}
