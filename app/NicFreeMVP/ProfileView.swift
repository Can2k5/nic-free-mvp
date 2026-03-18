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

    private var stats: [JourneyStat] {
        [
            JourneyStat(title: "Streak", value: "\(max(appState.nicotineFreeDays, 1)) days", symbol: "flame.fill"),
            JourneyStat(title: "Cravings resisted", value: "\(appState.cravingsDefeated)", symbol: "shield.fill"),
            JourneyStat(title: "Money saved", value: appState.moneySaved.formatted(.currency(code: currencyCode)), symbol: "eurosign.circle.fill"),
            JourneyStat(title: "Smoke-free time", value: appState.smokeFreeTimeText, symbol: "clock.fill")
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 22) {
                        headerSection
                            .softEntrance(delay: 0.02, distance: 12, initialScale: 0.985)

                        identityCard
                            .softEntrance(delay: 0.08, distance: 14, initialScale: 0.98)

                        statsSection
                            .softEntrance(delay: 0.14, distance: 16, initialScale: 0.98)

                        progressInsightSection
                            .softEntrance(delay: 0.2, distance: 16, initialScale: 0.98)

                        achievementsPreviewSection
                            .softEntrance(delay: 0.26, distance: 18, initialScale: 0.975)

                        motivationsSection
                            .softEntrance(delay: 0.32, distance: 16, initialScale: 0.98)

                        preferencesSection
                            .softEntrance(delay: 0.38, distance: 16, initialScale: 0.98)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Your Journey")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            Text("Personal progress, patterns, and what is opening up next.")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var identityCard: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [
                    Color.cardBackground.opacity(0.96),
                    Color.mist.opacity(0.26)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.62, green: 0.45, blue: 0.99),
                                        Color(red: 0.45, green: 0.24, blue: 0.90)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )

                        Text(String(displayName.prefix(1)).uppercased())
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                    }
                    .frame(width: 58, height: 58)

                    VStack(alignment: .leading, spacing: 5) {
                        Text(displayName)
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.ink)

                        Text("Nicotine-free since \(startDateText)")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Current focus")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)
                        .textCase(.uppercase)
                        .tracking(1.1)

                    Text(appState.dynamicMotivation)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)
                        .lineSpacing(3)
                }

                HStack(spacing: 10) {
                    journeyMetaPill(title: "Top trigger", value: appState.mostCommonTriggerTitle)
                    journeyMetaPill(title: "Most common time", value: appState.mostCommonTimeOfCravingTitle)
                }
            }
        }
    }

    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Progress snapshot")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            LazyVGrid(columns: statsColumns, spacing: 14) {
                ForEach(stats) { stat in
                    StatCard(title: stat.title, value: stat.value, symbol: stat.symbol)
                }
            }
        }
    }

    private var progressInsightSection: some View {
        CardSection(fill: AnyShapeStyle(Color.surface)) {
            VStack(alignment: .leading, spacing: 18) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Patterns this week")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("A cleaner read on how cravings are showing up lately.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    Image(systemName: "waveform.path.ecg")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.buttonBottom)
                        .padding(12)
                        .background(Color.accentWash.opacity(0.8))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }

                VStack(spacing: 12) {
                    journeyInsightRow(title: "Cravings survived", value: appState.weeklyCravingsSurvivedText)
                    journeyInsightRow(title: "Average intensity", value: appState.weeklyAverageIntensityText)
                    journeyInsightRow(title: "Strongest trigger", value: appState.strongestTriggerThisWeekText)
                }
            }
        }
    }

    private var achievementsPreviewSection: some View {
        Button {
            withAnimation(MicroAnimation.flow) {
                selectedTab = .achievements
            }
        } label: {
            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.cardBackground.opacity(0.96),
                        Color.accentWash.opacity(0.34)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Achievements")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text("\(appState.unlockedJourneyAchievements.count) of \(appState.journeyAchievements.count) unlocked")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(Color.secondaryText)
                        }

                        Spacer()

                        Image(systemName: "rosette")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(Color.white)
                            .frame(width: 48, height: 48)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.99, green: 0.64, blue: 0.76),
                                        Color(red: 0.76, green: 0.38, blue: 0.93)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }

                    HStack(spacing: 12) {
                        ForEach(appState.recentUnlockedJourneyAchievements) { achievement in
                            achievementPreviewBadge(achievement)
                        }

                        if appState.recentUnlockedJourneyAchievements.isEmpty {
                            Text("Start logging cravings and building streak days to unlock your first badge.")
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(Color.secondaryText)
                                .multilineTextAlignment(.leading)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if let next = appState.nextJourneyAchievement {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Next up")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .textCase(.uppercase)
                                .tracking(1.1)

                            HStack {
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(next.title)
                                        .font(.headline.weight(.semibold))
                                        .foregroundStyle(Color.ink)

                                    Text(next.progressText)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.secondaryText)
                                }

                                Spacer()

                                Text("See all")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.buttonBottom)
                            }
                        }
                        .padding(16)
                        .background(Color.surfaceMuted)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    }
                }
            }
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var motivationsSection: some View {
        CardSection(fill: AnyShapeStyle(Color.surface)) {
            VStack(alignment: .leading, spacing: 14) {
                Text("Why I quit")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)

                FlexibleChipLayout(spacing: 10, lineSpacing: 10) {
                    ForEach(appState.journeyMotivations, id: \.self) { motivation in
                        Text(motivation)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.buttonBottom.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
            }
        }
    }

    private var preferencesSection: some View {
        Button {
            withAnimation(MicroAnimation.flow) {
                selectedTab = .settings
            }
        } label: {
            CardSection(fill: AnyShapeStyle(Color.surface)) {
                HStack(spacing: 14) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.white)
                        .frame(width: 42, height: 42)
                        .background(Color.buttonBottom)
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings & preferences")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("Edit quit date, daily spend, reminders, and your personal setup.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.leading)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.footnote.weight(.bold))
                        .foregroundStyle(Color.secondaryText.opacity(0.8))
                }
            }
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private func journeyMetaPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.secondaryText)
                .textCase(.uppercase)
                .tracking(0.9)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func journeyInsightRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.secondaryText)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.trailing)
        }
    }

    private func achievementPreviewBadge(_ achievement: JourneyAchievement) -> some View {
        VStack(spacing: 8) {
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
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(Color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
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

private struct JourneyStat: Identifiable {
    let id = UUID()
    let title: String
    let value: String
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
