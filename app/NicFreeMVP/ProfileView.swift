import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab

    private let statsColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var displayName: String {
        let trimmed = appState.profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "You" : trimmed
    }

    private var heroProgress: Double {
        if let next = appState.nextJourneyAchievement {
            return max(0.08, min(next.progress, 1))
        }
        return 1
    }

    private var stats: [JourneyStat] {
        [
            JourneyStat(title: "Days nicotine-free", value: "\(max(appState.nicotineFreeDays, 1))", detail: "so far", symbol: "flame.fill"),
            JourneyStat(title: "Urges outlasted", value: "\(appState.cravingsDefeated)", detail: "moments", symbol: "shield.fill"),
            JourneyStat(title: "Money kept", value: appState.moneySaved.formatted(.currency(code: currencyCode)), detail: "so far", symbol: "eurosign.circle.fill"),
            JourneyStat(title: "Nicotine-free time", value: appState.smokeFreeTimeText, detail: "total", symbol: "clock.fill")
        ]
    }

    private var hasPatternData: Bool {
        appState.cravingsThisWeek > 0
    }

    private var visibleAchievements: [JourneyAchievement] {
        let unlocked = appState.unlockedJourneyAchievements.suffix(2)
        if !unlocked.isEmpty {
            return Array(unlocked)
        }

        return Array(appState.journeyAchievements.prefix(2))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.section) {
                        JourneyHeroView(
                            displayName: displayName,
                            startDateText: startDateText,
                            headline: "Day \(max(appState.nicotineFreeDays, 1)) nicotine-free",
                            progress: heroProgress
                        )
                        .softEntrance(delay: 0.02, distance: 12, initialScale: 0.985)

                        JourneyStatsGridView(stats: stats, columns: statsColumns)
                            .softEntrance(delay: 0.08, distance: 14, initialScale: 0.98)

                        JourneyPatternsView(
                            hasPatternData: hasPatternData,
                            strongestTrigger: appState.strongestTriggerThisWeekText,
                            mostCommonTime: appState.mostCommonTimeOfCravingTitle,
                            averageIntensity: appState.averageCravingIntensityThisWeekText,
                            survivedCount: appState.weeklyCravingsSurvivedText
                        )
                        .softEntrance(delay: 0.14, distance: 16, initialScale: 0.98)

                        JourneyAchievementsView(
                            unlockedCount: appState.unlockedJourneyAchievements.count,
                            totalCount: appState.journeyAchievements.count,
                            achievements: visibleAchievements,
                            nextAchievement: appState.nextJourneyAchievement,
                            onTap: {
                                withAnimation(MicroAnimation.flow) {
                                    selectedTab = .achievements
                                }
                            }
                        )
                        .softEntrance(delay: 0.2, distance: 16, initialScale: 0.98)

                        JourneyMotivationView(
                            reasons: appState.journeyMotivations,
                            highlightedReason: appState.highlightedQuitReason
                        )
                        .softEntrance(delay: 0.26, distance: 16, initialScale: 0.98)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var startDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: appState.quitDate)
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }
}

private struct JourneyHeroView: View {
    let displayName: String
    let startDateText: String
    let headline: String
    let progress: Double

    var body: some View {
        HeroCard(
            eyebrow: displayName,
            title: headline,
            subtitle: "Started \(startDateText)",
            icon: "person.crop.circle.fill",
            alignment: .center
        ) {
            VStack(spacing: AppSpacing.md) {
                MilestoneProgressBar(progress: progress)
                    .frame(height: 12)

                HStack {
                    Text("Start")
                    Spacer()
                    Text(progress >= 1 ? "Step reached" : "Next step")
                }
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct JourneyStatsGridView: View {
    let stats: [JourneyStat]
    let columns: [GridItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Your progress")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            KPIGrid(columns: columns) {
                ForEach(stats) { stat in
                    KPIBlock(
                        value: stat.value,
                        label: stat.title,
                        detail: stat.detail,
                        icon: stat.symbol
                    )
                }
            }
        }
    }
}

private struct JourneyPatternsView: View {
    let hasPatternData: Bool
    let strongestTrigger: String
    let mostCommonTime: String
    let averageIntensity: String
    let survivedCount: String

    var body: some View {
        InsightCard(
            title: "Patterns",
            subtitle: hasPatternData ? "A simple read on your recent cravings." : "Your patterns will start to show here.",
            icon: "waveform.path.ecg"
        ) {
            VStack(alignment: .leading, spacing: 18) {
                if hasPatternData {
                    InsightSignalStrip(
                        values: [
                            signalValue(from: survivedCount),
                            normalizedIntensity(from: averageIntensity),
                            strongestTrigger == "Log a few moments to see this" ? 0.2 : 0.72,
                            mostCommonTime == "Still getting to know your rhythm" ? 0.24 : 0.58,
                            normalizedIntensity(from: averageIntensity) * 0.9,
                            signalValue(from: survivedCount) * 0.78,
                            0.35 + (signalValue(from: survivedCount) * 0.45)
                        ]
                    )

                    VStack(spacing: 12) {
                        patternRow(
                            title: "Most common trigger",
                            value: strongestTrigger,
                            symbol: "bolt.badge.clock",
                            tint: Color(red: 0.93, green: 0.58, blue: 0.39)
                        )
                        patternRow(
                            title: "Most common time",
                            value: mostCommonTime,
                            symbol: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                            tint: Color(red: 0.44, green: 0.64, blue: 0.93)
                        )
                        patternRow(
                            title: "Average intensity",
                            value: averageIntensity,
                            symbol: "waveform.path.ecg",
                            tint: Color(red: 0.45, green: 0.74, blue: 0.62)
                        )
                    }
                } else {
                    VStack(spacing: 14) {
                        PlaceholderSignalStrip()

                        VStack(spacing: 4) {
                            Text("Your patterns will start to show here.")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text("Log a few cravings to start seeing what repeats.")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
    }

    private func patternRow(title: String, value: String, symbol: String, tint: Color) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(tint)
                .frame(width: 34, height: 34)
                .background(tint.opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(0.8)

                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ink)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func signalValue(from text: String) -> Double {
        guard let value = Double(text), value > 0 else { return 0.25 }
        return min(max(value / 7, 0.22), 1)
    }

    private func normalizedIntensity(from text: String) -> Double {
        let lowercased = text.lowercased()
        if lowercased.contains("high") {
            return 0.86
        }
        if lowercased.contains("medium") {
            return 0.58
        }
        if lowercased.contains("low") {
            return 0.34
        }
        if let value = Double(text), value > 0 {
            return min(max(value / 10, 0.25), 1)
        }
        return 0.28
    }
}

private struct JourneyAchievementsView: View {
    let unlockedCount: Int
    let totalCount: Int
    let achievements: [JourneyAchievement]
    let nextAchievement: JourneyAchievement?
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            ActionCard(
                title: "Progress markers",
                subtitle: "\(unlockedCount) of \(totalCount) reached",
                icon: "rosette",
                emphasizesAction: true
            ) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 12) {
                        ForEach(achievements) { achievement in
                            achievementTile(achievement)
                        }
                    }

                    if let nextAchievement {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Coming up")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .textCase(.uppercase)
                                .tracking(0.9)

                            HStack(alignment: .center, spacing: 14) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(nextAchievement.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.ink)

                                    Text(nextAchievement.progressText)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.heroSecondaryText)
                                }

                                Spacer()

                                Image(systemName: nextAchievement.symbol)
                                    .font(.headline.weight(.bold))
                                    .foregroundStyle(Color.white)
                                    .frame(width: 42, height: 42)
                                    .background(
                                        LinearGradient(
                                            colors: [nextAchievement.accentTop, nextAchievement.accentBottom],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                        .padding(16)
                        .background(
                            LinearGradient(
                                colors: [Color.cardBackground.opacity(0.84), Color.surfaceMuted],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Color.borderStrong.opacity(0.55), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private func achievementTile(_ achievement: JourneyAchievement) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: achievement.symbol)
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.white)
                .frame(width: 44, height: 44)
                .background(
                    LinearGradient(
                        colors: [achievement.accentTop, achievement.accentBottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            Text(achievement.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
                .lineLimit(2)

            Text(achievement.isUnlocked ? "Reached" : achievement.progressText)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, minHeight: 132, alignment: .topLeading)
        .padding(16)
        .background(Color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct JourneyMotivationView: View {
    let reasons: [String]
    let highlightedReason: String?

    var body: some View {
        InsightCard(
            title: "Your reasons",
            subtitle: "The reminders you want close when things feel harder."
        ) {
            VStack(alignment: .leading, spacing: 14) {
                FlexibleChipLayout(spacing: 10, lineSpacing: 10) {
                    ForEach(reasons, id: \.self) { reason in
                        Text(reason)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(reason == highlightedReason ? Color.white : Color.buttonBottom)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(reasonChipBackground(reason))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private func reasonChipBackground(_ reason: String) -> some ShapeStyle {
        if reason == highlightedReason {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [Color.buttonTop.opacity(0.94), Color.buttonBottom.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(Color.buttonBottom.opacity(0.10))
    }
}

private struct MilestoneProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.cardBackground.opacity(0.6))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.buttonTop.opacity(0.9), Color.buttonBottom.opacity(0.98)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(proxy.size.width * progress, 22))
            }
        }
    }
}

private struct InsightSignalStrip: View {
    let values: [Double]

    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(fill(for: index))
                    .frame(maxWidth: .infinity)
                    .frame(height: 30 + (max(0, min(value, 1)) * 42))
            }
        }
        .frame(height: 84, alignment: .bottom)
    }

    private func fill(for index: Int) -> some ShapeStyle {
        let colors: [[Color]] = [
            [Color.heroAccent.opacity(0.42), Color.heroAccent],
            [Color.buttonTop.opacity(0.35), Color.buttonTop],
            [Color.buttonBottom.opacity(0.34), Color.buttonBottom]
        ]
        let pair = colors[index % colors.count]
        return AnyShapeStyle(
            LinearGradient(colors: pair, startPoint: .top, endPoint: .bottom)
        )
    }
}

private struct PlaceholderSignalStrip: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            ForEach([0.26, 0.35, 0.22, 0.42, 0.31, 0.48, 0.28], id: \.self) { value in
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(Color.surfaceMuted)
                    .frame(maxWidth: .infinity)
                    .frame(height: 28 + (value * 40))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(Color.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
                    )
            }
        }
        .frame(height: 82, alignment: .bottom)
    }
}

private struct JourneyStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
    let detail: String
    let symbol: String
}

private struct FlexibleChipLayout: Layout {
    var spacing: CGFloat = 8
    var lineSpacing: CGFloat = 8

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) -> CGSize {
        let maxWidth = proposal.width ?? 320
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }

            lineHeight = max(lineHeight, size.height)
            currentX += size.width + spacing
        }

        return CGSize(width: maxWidth, height: currentY + lineHeight)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout ()
    ) {
        var currentX = bounds.minX
        var currentY = bounds.minY
        var lineHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            if currentX + size.width > bounds.maxX, currentX > bounds.minX {
                currentX = bounds.minX
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }

            subview.place(
                at: CGPoint(x: currentX, y: currentY),
                proposal: ProposedViewSize(width: size.width, height: size.height)
            )

            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
        }
    }
}

#Preview {
    ProfileView(selectedTab: .constant(.profile))
        .environmentObject(AppState())
        .environmentObject(OnboardingManager())
}
