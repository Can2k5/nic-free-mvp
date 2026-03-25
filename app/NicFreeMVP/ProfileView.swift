import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @Binding var selectedTab: RootTabView.Tab
    @State private var showingPaywall = false
    @State private var hasShownLockedProgressPaywallThisSession = false

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

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.section) {
                        journeyHero
                        .softEntrance(delay: 0.02, distance: 12, initialScale: 0.985)

                        journeyCheckInContinuity
                            .softEntrance(delay: 0.08, distance: 14, initialScale: 0.98)

                        journeyKeyMetrics
                            .softEntrance(delay: 0.14, distance: 16, initialScale: 0.98)

                        journeyProgressStory
                            .softEntrance(delay: 0.2, distance: 16, initialScale: 0.98)

                        journeyPatternInsight
                            .softEntrance(delay: 0.26, distance: 16, initialScale: 0.98)

                        journeyTriggersAndContext
                            .softEntrance(delay: 0.32, distance: 16, initialScale: 0.98)

                        journeyNextStep
                            .softEntrance(delay: 0.38, distance: 16, initialScale: 0.98)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(onClose: { showingPaywall = false })
                .presentationBackground(.clear)
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

    private var hasPatternData: Bool {
        appState.cravingsThisWeek > 0
    }

    private var journeyHero: some View {
        HeroCard(
            eyebrow: displayName,
            title: appState.smokeFreeStreakCount > 0 ? "\(appState.smokeFreeStreakCount)-day streak" : "Your streak",
            subtitle: heroSupportLine,
            icon: "person.crop.circle.fill",
            alignment: .center
        ) {
            VStack(spacing: AppSpacing.md) {
                MilestoneProgressBar(progress: heroProgress)
                    .frame(height: 10)

                Text("Started \(startDateText)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.heroSecondaryText)

                Text(appState.smokeFreeStreakStatusLine)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(streakStatusColor)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var journeyKeyMetrics: some View {
        KPIGrid {
            KPIBlock(
                value: "\(appState.smokeFreeStreakCount)",
                label: "Streak",
                detail: streakDetailText,
                icon: "clock.fill"
            )
            KPIBlock(
                value: appState.moneySaved.formatted(.currency(code: currencyCode)),
                label: "Money saved",
                detail: "kept for yourself",
                icon: "eurosign.circle.fill"
            )
            KPIBlock(
                value: "\(appState.cravingsDefeated)",
                label: "Cravings resisted",
                detail: "moments outlasted",
                icon: "shield.fill"
            )
        }
    }

    private var journeyCheckInContinuity: some View {
        InsightCard(
            title: "Recent continuity",
            subtitle: continuitySubtitle,
            icon: "calendar.badge.clock"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(spacing: 10) {
                    ForEach(recentCheckInDays) { day in
                        recentCheckInDayPill(day)
                    }
                }

                HStack(spacing: 10) {
                    continuityLegend(label: "Checked in", color: Color.buttonBottom)
                    continuityLegend(label: "Missed", color: Color.surfaceMuted)
                    if appState.smokeFreeStreakState == .onIce {
                        continuityLegend(label: "On ice", color: Color.orange.opacity(0.9))
                    }
                }
            }
        }
    }

    private var journeyPatternInsight: some View {
        PremiumLockedContent(
            isLocked: subscriptionManager.isFree,
            message: "Unlock deeper pattern insights.",
            action: { showingPaywall = true }
        ) {
            InsightCard(
                title: "What your pattern suggests",
                subtitle: hasPatternData ? "A simple read on what has been showing up lately." : "This will fill in over time as you log more cravings.",
                icon: "waveform.path.ecg"
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    if hasPatternData {
                        ForEach(patternInsights, id: \.self) { insight in
                            JourneyInsightLine(text: insight)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
                            Text("You are just getting started.")
                                .font(.headline.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text("Log a few cravings and this section will start to reflect your rhythm.")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)
                        }
                    }
                }
            }
        }
    }

    private var journeyTriggersAndContext: some View {
        PremiumLockedContent(
            isLocked: subscriptionManager.isFree,
            message: "Unlock trigger and context details.",
            action: { showingPaywall = true }
        ) {
            InsightCard(
                title: "Triggers and context",
                subtitle: hasPatternData ? "The situations most tied to your recent cravings." : "This will get more personal as you keep logging.",
                icon: "bolt.badge.clock"
            ) {
                VStack(spacing: AppSpacing.sm) {
                    contextRow(
                        title: "Most common trigger",
                        value: hasPatternData ? appState.strongestTriggerThisWeekText : "Your common triggers will show up here",
                        symbol: "bolt.fill"
                    )

                    contextRow(
                        title: "Most common time",
                        value: hasPatternData ? appState.mostCommonTimeOfCravingTitle : "Your timing patterns will show up here",
                        symbol: "clock.fill"
                    )

                    contextRow(
                        title: "Recent check-in",
                        value: recentCheckinContext,
                        symbol: "waveform.path.ecg"
                    )
                }
            }
        }
    }

    private var journeyProgressStory: some View {
        PremiumLockedContent(
            isLocked: subscriptionManager.isFree,
            message: "Unlock your full progress story.",
            action: { showingPaywall = true }
        ) {
            InsightCard(
                title: "Your progress story",
                subtitle: "A quick read on how things are moving.",
                icon: "book.closed"
            ) {
                VStack(alignment: .leading, spacing: AppSpacing.md) {
                    Text(progressStoryHeadline)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text(progressStoryDetail)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)

                    Text(continuityStatusLine)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(streakStatusColor)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(streakStatusColor.opacity(0.12))
                        .clipShape(Capsule())

                    if let highlightedReason = appState.highlightedQuitReason {
                        Text(highlightedReason)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 10)
                            .background(Color.buttonBottom.opacity(0.10))
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .onAppear {
            triggerLockedProgressPaywallIfNeeded()
        }
    }

    private var journeyNextStep: some View {
        Button {
            withAnimation(MicroAnimation.flow) {
                selectedTab = appState.cravingsThisWeek == 0 ? .rescue : .achievements
            }
        } label: {
            ActionCard(
                title: nextStepTitle,
                subtitle: nextStepSubtitle,
                icon: nextStepIcon
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var heroSupportLine: String {
        switch appState.smokeFreeStreakState {
        case .onIce:
            return "Your streak is still recoverable today."
        case .lost:
            return "A fresh streak can start with the next smoke-free check-in."
        case .active:
            break
        }

        if appState.nicotineFreeDays >= 7 {
            return "You are building a steadier rhythm."
        }
        if appState.cravingsDefeated > 0 {
            return "You are already learning how to get through hard moments."
        }
        return "Early days count, even when they feel uneven."
    }

    private var patternInsights: [String] {
        var insights: [String] = []

        if appState.mostCommonTimeOfCravingTitle != "Still getting to know your rhythm" {
            insights.append("Your cravings tend to show up most in the \(appState.mostCommonTimeOfCravingTitle.lowercased()).")
        }

        if appState.strongestTriggerThisWeekText != "Log a few moments to see this" {
            insights.append("Stress around \(appState.strongestTriggerThisWeekText.lowercased()) moments may be worth noticing more closely.")
        }

        if appState.weeklyCravingsSurvivedText != "Log a few moments to see this" {
            insights.append("You have already gotten through \(appState.weeklyCravingsSurvivedText) craving moments this week.")
        }

        if insights.isEmpty {
            insights.append("Your first few logs will start to show what tends to repeat.")
        }

        return Array(insights.prefix(2))
    }

    private var recentCheckinContext: String {
        guard let latestCheckin = appState.latestCheckin else {
            return "Log a daily check-in to add more context here."
        }

        if Calendar.current.isDateInToday(latestCheckin.date) {
            return "Today feels \(latestCheckin.cravingLevel.title.lowercased())."
        }

        return "Your last check-in felt \(latestCheckin.cravingLevel.title.lowercased())."
    }

    private var progressStoryHeadline: String {
        if appState.smokeFreeStreakState == .onIce {
            return "Your streak is on ice, but it is still in reach."
        }
        if appState.didSmokeFreeCheckInToday {
            return "You checked in today and kept your continuity visible."
        }
        if appState.nicotineFreeDays >= 7 {
            return "You have held this change for over a week."
        }
        if appState.cravingsDefeated > 0 {
            return "You are proving you can get through urges."
        }
        return "You are laying the groundwork for a steadier routine."
    }

    private var progressStoryDetail: String {
        if appState.smokeFreeStreakState == .onIce {
            return "A smoke-free check-in today brings the streak back to active. You are not starting from zero."
        }
        if appState.didSmokeFreeCheckInToday {
            return "Today is already counted. That kind of visible follow-through is what keeps a streak feeling real."
        }
        if let nextAchievement = appState.nextJourneyAchievement {
            return "Your next progress marker is \(nextAchievement.title.lowercased()). You are already moving toward it."
        }

        return "Each logged craving and each nicotine-free day adds more clarity to what helps you."
    }

    private var nextStepTitle: String {
        appState.cravingsThisWeek == 0 ? "Keep logging and this will fill in" : "See what is building next"
    }

    private var nextStepSubtitle: String {
        appState.cravingsThisWeek == 0
            ? "A few logged cravings will make this screen more personal."
            : appState.nextJourneyAchievement?.progressText ?? "You are still building momentum."
    }

    private var nextStepIcon: String {
        appState.cravingsThisWeek == 0 ? "square.and.pencil" : "rosette"
    }

    private func contextRow(title: String, value: String, symbol: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.heroAccent)
                .frame(width: 34, height: 34)
                .background(Color.accentWash.opacity(0.9))
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
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(14)
        .background(Color.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func triggerLockedProgressPaywallIfNeeded() {
        guard subscriptionManager.isFree, !hasShownLockedProgressPaywallThisSession else { return }
        hasShownLockedProgressPaywallThisSession = true
        showingPaywall = true
    }

    private var streakDetailText: String {
        switch appState.smokeFreeStreakState {
        case .active:
            return "active"
        case .onIce:
            return "on ice"
        case .lost:
            return "restart ready"
        }
    }

    private var streakStatusColor: Color {
        switch appState.smokeFreeStreakState {
        case .active:
            return Color.heroSecondaryText
        case .onIce:
            return Color.orange
        case .lost:
            return Color.secondaryText
        }
    }

    private var continuitySubtitle: String {
        switch appState.smokeFreeStreakState {
        case .active:
            return appState.didSmokeFreeCheckInToday
                ? "Today is already marked smoke-free."
                : "Your recent check-ins show how the streak is holding."
        case .onIce:
            return "One missed day put the streak on ice, but it can still recover."
        case .lost:
            return "A fresh check-in restarts the chain from today."
        }
    }

    private var continuityStatusLine: String {
        switch appState.smokeFreeStreakState {
        case .active:
            return appState.didSmokeFreeCheckInToday ? "Checked in today" : "Still active today"
        case .onIce:
            return "On ice, still recoverable"
        case .lost:
            return "Ready for a fresh start"
        }
    }

    private var recentCheckInDays: [RecentCheckInDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let checkedInDays = Set(
            appState.dailyCheckins.map { calendar.startOfDay(for: $0.date) }
        )

        return (0..<7).compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let status: RecentCheckInDay.Status

            if checkedInDays.contains(date) {
                status = .checkedIn
            } else if offset == 0 && appState.smokeFreeStreakState == .onIce {
                status = .onIce
            } else {
                status = .missed
            }

            return RecentCheckInDay(date: date, status: status)
        }
        .reversed()
    }

    private func recentCheckInDayPill(_ day: RecentCheckInDay) -> some View {
        VStack(spacing: 8) {
            Text(day.weekdayLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(day.status.fillColor)
                    .frame(width: 38, height: 46)

                Image(systemName: day.status.symbolName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(day.status.symbolColor)
            }

            Text(day.dayNumberLabel)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity)
    }

    private func continuityLegend(label: String, color: Color) -> some View {
        HStack(spacing: 6) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)

            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText)
        }
    }
}

private struct RecentCheckInDay: Identifiable {
    enum Status {
        case checkedIn
        case missed
        case onIce

        var fillColor: Color {
            switch self {
            case .checkedIn:
                return Color.buttonBottom.opacity(0.16)
            case .missed:
                return Color.surfaceMuted
            case .onIce:
                return Color.orange.opacity(0.18)
            }
        }

        var symbolName: String {
            switch self {
            case .checkedIn:
                return "checkmark"
            case .missed:
                return "minus"
            case .onIce:
                return "snowflake"
            }
        }

        var symbolColor: Color {
            switch self {
            case .checkedIn:
                return Color.buttonBottom
            case .missed:
                return Color.secondaryText.opacity(0.75)
            case .onIce:
                return Color.orange
            }
        }
    }

    let date: Date
    let status: Status

    var id: Date { date }

    var weekdayLabel: String {
        date.formatted(.dateTime.weekday(.narrow))
    }

    var dayNumberLabel: String {
        date.formatted(.dateTime.day())
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

private struct JourneyInsightLine: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Circle()
                .fill(Color.heroAccent)
                .frame(width: 8, height: 8)
                .padding(.top, 6)

            Text(text)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.ink)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(14)
        .background(Color.surfaceMuted)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
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
