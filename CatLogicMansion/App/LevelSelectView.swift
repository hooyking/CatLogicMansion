import SwiftUI

struct LevelSelectView: View {
    @ObservedObject var progressStore: ProgressStore
    let onSelectLevel: (String) -> Void

    private let chapterIndexes = LevelLoader.loadChapterIndexes()
    private let levelIds = LevelLoader.availableLevelIds()

    private let columns = [
        GridItem(.adaptive(minimum: 96), spacing: 16)
    ]

    var body: some View {
        ZStack {
            MansionBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    heroHeader

                    ForEach(chapterIndexes, id: \.chapterId) { chapterIndex in
                        chapterSection(chapterIndex)
                    }
                }
                .padding(20)
            }
        }
    }

    private func chapterSection(_ chapterIndex: ChapterIndex) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                Text(L10n.tr(chapterIndex.titleKey))
                    .font(.headline.weight(.black))
                    .foregroundStyle(AppDesign.ColorToken.walnut)

                Text(L10n.tr(chapterIndex.subtitleKey))
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.58))
            }

            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(chapterIndex.levels.map { $0.replacingOccurrences(of: ".json", with: "") }, id: \.self) { levelId in
                    let progress = progressStore.progress(for: levelId)
                    let isUnlocked = progressStore.isUnlocked(levelId: levelId, in: levelIds)

                    Button {
                        guard isUnlocked else {
                            return
                        }

                        onSelectLevel(levelId)
                    } label: {
                        LevelCard(
                            levelNumber: levelNumber(for: levelId),
                            progress: progress,
                            isUnlocked: isUnlocked
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUnlocked)
                }
            }
        }
    }

    private var heroHeader: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(L10n.tr("level_select.title"))
                    .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundStyle(AppDesign.ColorToken.walnut)

                    Text(L10n.tr("level_select.subtitle"))
                        .font(.callout)
                        .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.72))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()

                Image(systemName: "pawprint.fill")
                    .font(.system(size: 42, weight: .black))
                    .foregroundStyle(AppDesign.ColorToken.catOrange)
                    .padding(16)
                    .background(
                        LinearGradient(
                            colors: [
                                AppDesign.ColorToken.cream,
                                AppDesign.ColorToken.peach.opacity(0.55)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                    .shadow(color: AppDesign.ColorToken.catOrange.opacity(0.18), radius: 12, y: 6)
            }

            HStack(spacing: 10) {
                Label(L10n.tr("level_select.offline"), systemImage: "wifi.slash")
                Label(L10n.tr("level_select.no_ads"), systemImage: "sparkles")
                Label(
                    "\(progressStore.totalStars)/\(levelIds.count * 3) \(L10n.tr("level_select.stars_suffix"))",
                    systemImage: "star.fill"
                )
            }
            .font(.caption.bold())
            .foregroundStyle(AppDesign.ColorToken.moonBlue)
        }
        .padding(24)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.sheet))
        .shadow(color: AppDesign.Shadow.card, radius: 18, y: 10)
    }

    private func levelNumber(for levelId: String) -> Int {
        Int(levelId.replacingOccurrences(of: "level_", with: "")) ?? 0
    }
}

private struct LevelCard: View {
    let levelNumber: Int
    let progress: LevelProgress?
    let isUnlocked: Bool

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? AppDesign.ColorToken.peach.opacity(0.42) : .gray.opacity(0.12))
                    .frame(width: 58, height: 58)
                    .overlay {
                        Circle()
                            .stroke(AppDesign.ColorToken.cream.opacity(0.86), lineWidth: 4)
                    }

                if isUnlocked {
                    Text("\(levelNumber)")
                        .font(.system(size: 28, weight: .black, design: .rounded))
                        .foregroundStyle(AppDesign.ColorToken.walnut)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.42))
                }
            }

            HStack(spacing: 2) {
                ForEach(1...3, id: \.self) { index in
                    Image(systemName: index <= (progress?.stars ?? 0) ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(index <= (progress?.stars ?? 0) ? .yellow : .gray.opacity(isUnlocked ? 0.45 : 0.24))
                }
            }

            if !isUnlocked {
                Text(L10n.tr("level_select.locked"))
                    .font(.caption2)
                    .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.42))
            } else if let progress {
                Text("\(progress.bestMoves) \(L10n.tr("level_select.moves_suffix"))")
                    .font(.caption2)
                    .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.62))
            } else {
                Text(L10n.tr("level_select.not_cleared"))
                    .font(.caption2)
                    .foregroundStyle(AppDesign.ColorToken.walnut.opacity(0.48))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 136)
        .background(
            LinearGradient(
                colors: [
                    AppDesign.ColorToken.cream.opacity(0.98),
                    AppDesign.ColorToken.peach.opacity(0.28),
                    AppDesign.ColorToken.parchment.opacity(0.72)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .overlay {
            RoundedRectangle(cornerRadius: AppDesign.Radius.card)
                .stroke(AppDesign.ColorToken.walnut.opacity(0.08), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: AppDesign.Radius.card))
        .shadow(color: AppDesign.Shadow.card, radius: 12, y: 7)
        .opacity(isUnlocked ? 1 : 0.68)
    }
}
