import SwiftUI

struct HomeView: View {
    private enum TodayAction: String, CaseIterable, Identifiable {
        case delayFirstPuff
        case drinkWater
        case deepBreaths
        case walkTwoMinutes

        var id: String { rawValue }

        var title: String {
            switch self {
            case .delayFirstPuff:
                return "Wait five more minutes"
            case .drinkWater:
                return "Drink some water"
            case .deepBreaths:
                return "Take 3 slow breaths"
            case .walkTwoMinutes:
                return "Walk for 2 minutes"
            }
        }

        var helperText: String {
            switch self {
            case .delayFirstPuff:
                return "A little space can soften the urge"
            case .drinkWater:
                return "A small reset for your body"
            case .deepBreaths:
                return "Let your body settle first"
            case .walkTwoMinutes:
                return "A change in motion can change the moment"
            }
        }

        var symbol: String {
            switch self {
            case .delayFirstPuff:
                return "timer"
            case .drinkWater:
                return "drop.fill"
            case .deepBreaths:
                return "wind"
            case .walkTwoMinutes:
                return "figure.walk"
            }
        }
    }

    private enum Milestone: String, CaseIterable, Identifiable {
        case first24Hours
        case firstCravingResisted
        case threeDays
        case sevenDays

        var id: String { rawValue }

        var title: String {
            switch self {
            case .first24Hours:
                return "First full day"
            case .firstCravingResisted:
                return "First urge outlasted"
            case .threeDays:
                return "3 steady days"
            case .sevenDays:
                return "One steady week"
            }
        }

        var compactTitle: String {
            switch self {
            case .first24Hours:
                return "24h"
            case .firstCravingResisted:
                return "First urge"
            case .threeDays:
                return "3 days"
            case .sevenDays:
                return "1 week"
            }
        }
    }

    struct CheckinDay: Identifiable {
        let id: Date
        let date: Date
        let level: DailyCravingLevel?
    }

    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab
    @State private var showingSlipFlow = false
    @State private var showingCravingView = false
    @State private var showingPaywallTest = false
    @State private var completedTodayActions: Set<TodayAction> = []
    @State private var animatedMilestones: Set<Milestone> = []
    @State private var seenUnlockedMilestones: Set<Milestone> = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.section + 4) {
                        homeHeroSummary
                            .softEntrance(delay: 0.04, distance: 16, initialScale: 0.97)
                            .padding(.bottom, AppSpacing.sm)

                        homeDailyCheckIn
                            .softEntrance(delay: 0.11, distance: 16, initialScale: 0.98)

                        homeTodayFocus
                            .softEntrance(delay: 0.18, distance: 16, initialScale: 0.98)

                        if shouldShowRescueEntry {
                            homeCravingQuickAction
                                .softEntrance(delay: 0.24, distance: 16, initialScale: 0.98)
                        }

                        homeProgressSnapshot
                            .softEntrance(delay: 0.29, distance: 16, initialScale: 0.98)

                        utilityFooter
                            .softEntrance(delay: 0.34, distance: 12, initialScale: 0.99)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
            .sheet(isPresented: $showingCravingView) {
                CravingInterventionView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingSlipFlow) {
                SlipRecoveryFlowView()
                    .environmentObject(appState)
            }
            .sheet(isPresented: $showingPaywallTest) {
                paywallTestSheet
            }
            .onAppear {
                syncMilestones()
            }
            .onChange(of: appState.nicotineFreeDays) {
                syncMilestones()
            }
            .onChange(of: appState.cravingsDefeated) {
                syncMilestones()
            }
        }
    }

    @ViewBuilder
    private var paywallTestSheet: some View {
        PaywallView(
            onClose: {
                showingPaywallTest = false
            }
        )
    }

    private var latestCheckinText: String {
        guard let latest = appState.latestCheckin else {
            return "A quick check-in can help steady the day."
        }

        if Calendar.current.isDateInToday(latest.date) {
            return checkinReflection(for: latest.cravingLevel)
        }

        return "Your last check-in felt \(latest.cravingLevel.title.lowercased())."
    }

    private var emotionalAnchor: String {
        if let reason = appState.highlightedQuitReason {
            return reason
        }
        return appState.dynamicMotivation
    }

    private var selectedTodayFocus: TodayAction {
        if let latest = appState.latestCheckin?.cravingLevel {
            switch latest {
            case .high:
                return .deepBreaths
            case .medium:
                return .drinkWater
            case .low:
                return .walkTwoMinutes
            }
        }

        if appState.cravingsDefeated == 0 {
            return .delayFirstPuff
        }

        return TodayAction.allCases.first(where: { !completedTodayActions.contains($0) }) ?? .deepBreaths
    }

    private var progressSummary: (title: String, progress: Double, current: String, target: String) {
        let days = appState.nicotineFreeDays

        if days < 1 {
            return ("Next step", min(Double(days), 1), "\(days)d", "1 day")
        } else if days < 3 {
            let segmentProgress = Double(days - 1) / 2
            return ("Next step", max(0, min(segmentProgress, 1)), "\(days)d", "3 days")
        } else if days < 7 {
            let segmentProgress = Double(days - 3) / 4
            return ("Next step", max(0, min(segmentProgress, 1)), "\(days)d", "7 days")
        } else {
            let span = max(appState.nicotineFreeDays, 7)
            let progress = min(Double(span - 7) / 7, 1)
            return ("Building momentum", progress, "\(span)d", "14 days")
        }
    }

    private var weekCheckins: [CheckinDay] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        return (0..<7).reversed().compactMap { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { return nil }
            let checkin = appState.dailyCheckins.first(where: { calendar.isDate($0.date, inSameDayAs: date) })
            return CheckinDay(id: date, date: date, level: checkin?.cravingLevel)
        }
    }

    private var homeHeroSummary: some View {
        HeroCard(
            eyebrow: "Daily dashboard",
            title: "Day \(max(appState.nicotineFreeDays, 1))",
            subtitle: "nicotine-free",
            badge: statusBadgeTitle
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                ProgressRing(
                    progress: progressSummary.progress,
                    lineWidth: 9,
                    diameter: 82
                )
                .opacity(0.82)
                .overlay {
                    Text(progressRingValue)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color.ink)
                }
                .padding(.bottom, 2)

                Text(emotionalAnchor)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.ink.opacity(0.72))
                    .lineSpacing(3)
                    .lineLimit(1)

                Text("\(progressSummary.current) toward \(progressSummary.target)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.heroSecondaryText.opacity(0.82))
                    .textCase(.uppercase)
                    .tracking(0.8)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var shouldShowRescueEntry: Bool {
        let hasNoCheckinToday = !hasCheckinToday
        let hasHighCravingToday = appState.latestCheckin?.cravingLevel == .high && hasCheckinToday
        let hasRecentSlip = appState.slipEvents.contains {
            Calendar.current.isDate($0.timestamp, inSameDayAs: .now)
        }

        return hasNoCheckinToday || hasHighCravingToday || hasRecentSlip
    }

    private var hasCheckinToday: Bool {
        guard let latest = appState.latestCheckin else { return false }
        return Calendar.current.isDateInToday(latest.date)
    }

    private var homeProgressSnapshot: some View {
        InsightCard(
            title: "Progress snapshot",
            subtitle: progressSnapshotSubtitle,
            icon: "chart.bar"
        ) {
            HStack(spacing: AppSpacing.md) {
                CompactStat(
                    label: "Streak",
                    value: appState.smokeFreeTimeText,
                    emphasis: .primary
                )
                CompactStat(
                    label: "Saved",
                    value: appState.moneySaved.formatted(.currency(code: currencyCode))
                )
                CompactStat(
                    label: "Resisted",
                    value: "\(appState.cravingsDefeated)"
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var todayCheckInTitle: String {
        if hasCheckinToday {
            return "How are cravings today?"
        }
        return "How are cravings today?"
    }

    private func isSelectedCheckinLevel(_ level: DailyCravingLevel) -> Bool {
        hasCheckinToday && appState.latestCheckin?.cravingLevel == level
    }

    private func checkinStatusText(for level: DailyCravingLevel) -> String {
        isSelectedCheckinLevel(level) ? "Selected" : levelDescriptor(for: level)
    }

    private func checkinButtonBackground(for level: DailyCravingLevel) -> Color {
        isSelectedCheckinLevel(level) ? Color.buttonBottom.opacity(0.88) : Color.surfaceElevated
    }

    private func checkinTitleColor(for level: DailyCravingLevel) -> Color {
        isSelectedCheckinLevel(level) ? Color.white : Color.ink
    }

    private func checkinSubtitleColor(for level: DailyCravingLevel) -> Color {
        isSelectedCheckinLevel(level) ? Color.white.opacity(0.82) : Color.secondaryText
    }

    private var todayFocusActionTitle: String {
        completedTodayActions.contains(selectedTodayFocus) ? "Done for today ✓" : "Mark as done"
    }

    private var todayFocusActionBackground: Color {
        completedTodayActions.contains(selectedTodayFocus) ? Color.accentWash.opacity(0.95) : Color.surfaceElevated
    }

    private var todayFocusActionStroke: Color {
        completedTodayActions.contains(selectedTodayFocus) ? Color.heroAccent.opacity(0.28) : Color.border
    }

    private var todayFocusTitle: String {
        completedTodayActions.contains(selectedTodayFocus) ? "That step is done" : "Today’s focus"
    }

    private var todayFocusSubtitle: String {
        completedTodayActions.contains(selectedTodayFocus)
            ? "One small win, done."
            : "One small step that can help today"
    }

    private var homeDailyCheckIn: some View {
        ActionCard(
            title: todayCheckInTitle,
            subtitle: latestCheckinText,
            icon: "waveform.path.ecg",
            showsChevron: false
        ) {
            VStack(alignment: .leading, spacing: 12) {
                if hasCheckinToday {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.heroAccent)

                        Text(checkinAffirmation)
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color.secondaryText)
                    }
                    .transition(.opacity)
                }

                HStack(spacing: 10) {
                ForEach(DailyCravingLevel.allCases) { level in
                    Button {
                        appState.saveDailyCheckin(level: level)
                        OnboardingHaptics.light()
                        appState.showRewardToast(
                            title: checkinToastTitle(for: level),
                            message: checkinToastMessage(for: level),
                            duration: 1.6
                        )
                    } label: {
                        VStack(spacing: 6) {
                            Text(level.title)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(checkinTitleColor(for: level))

                            Text(checkinStatusText(for: level))
                                .font(.caption.weight(.medium))
                                .foregroundStyle(checkinSubtitleColor(for: level))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .fill(checkinButtonBackground(for: level))
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(
                                    isSelectedCheckinLevel(level) ? Color.white.opacity(0.18) : Color.border,
                                    lineWidth: 1
                                )
                        )
                    }
                    .buttonStyle(SelectableButtonStyle(isSelected: isSelectedCheckinLevel(level)))
                }
                }
            }
        }
    }

    private var homeCravingQuickAction: some View {
        Button {
            showingCravingView = true
        } label: {
            ActionCard(
                title: "Need support right now?",
                subtitle: "Open rescue and take the next small step",
                icon: "bolt.heart.fill",
                emphasizesAction: true
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var homeTodayFocus: some View {
        let action = selectedTodayFocus
        let isCompleted = completedTodayActions.contains(action)

        return ActionCard(
            title: todayFocusTitle,
            subtitle: todayFocusSubtitle,
            icon: isCompleted ? "checkmark.circle.fill" : action.symbol,
            showsChevron: false
        ) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(action.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text(action.helperText)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Button {
                    if isCompleted {
                        completedTodayActions.remove(action)
                    } else {
                        completedTodayActions.insert(action)
                        OnboardingHaptics.success()
                        appState.showRewardToast(
                            title: "That is one step forward.",
                            message: todayFocusRewardMessage
                        )
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.headline.weight(.semibold))

                        Text(todayFocusActionTitle)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(isCompleted ? Color.buttonBottom : Color.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(todayFocusActionBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(todayFocusActionStroke, lineWidth: 1)
                    )
                }
                .buttonStyle(CardPressButtonStyle())
            }
        }
    }

    private func compactMilestoneTile(for milestone: Milestone) -> some View {
        let unlocked = isMilestoneUnlocked(milestone)
        let shouldAnimate = animatedMilestones.contains(milestone)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: unlocked ? "checkmark.circle.fill" : "clock")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(unlocked ? Color.white : Color.heroAccent)

                Spacer()
            }

            Spacer(minLength: 0)

            Text(milestone.compactTitle)
                .font(.headline.weight(.semibold))
                .foregroundStyle(unlocked ? Color.white : Color.ink)

            Text(milestone.title)
                .font(.caption.weight(.medium))
                .foregroundStyle(unlocked ? Color.white.opacity(0.82) : Color.secondaryText)
                .lineLimit(2)
        }
        .padding(16)
        .frame(width: 146, height: 112, alignment: .topLeading)
        .background(
            unlocked
                ? AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.buttonTop.opacity(0.95), Color.buttonBottom.opacity(0.98)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                : AnyShapeStyle(Color.surface)
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(unlocked ? Color.cardBackground.opacity(0.18) : Color.border, lineWidth: 1)
        )
        .shadow(color: unlocked ? Color.buttonBottom.opacity(0.14) : Color.shadowColor.opacity(0.05), radius: 14, x: 0, y: 8)
        .scaleEffect(shouldAnimate ? 1.08 : 1)
        .animation(.easeInOut(duration: 0.25), value: shouldAnimate)
    }

    private var utilityFooter: some View {
        HStack(spacing: 18) {
            Button {
                showingSlipFlow = true
            } label: {
                Text("I need to reset")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .buttonStyle(SecondaryButtonStyle())

            Spacer()

            Button {
                showingPaywallTest = true
            } label: {
                Text("Open Paywall")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, 4)
    }

    private var progressRingValue: String {
        String(max(appState.nicotineFreeDays, 1))
    }

    private var statusBadgeTitle: String {
        if appState.nicotineFreeDays >= 7 {
            return "Building momentum"
        } else if appState.cravingsDefeated >= 1 {
            return "Keep going"
        } else {
            return "Getting started"
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private func levelDescriptor(for level: DailyCravingLevel) -> String {
        switch level {
        case .low:
            return "Manageable"
        case .medium:
            return "Present"
        case .high:
            return "Strong"
        }
    }

    private func checkinReflection(for level: DailyCravingLevel) -> String {
        switch level {
        case .low:
            return "Today feels more manageable."
        case .medium:
            return "Today feels present, but manageable."
        case .high:
            return "Today feels heavy. Support is close."
        }
    }

    private var checkinAffirmation: String {
        if let latest = appState.latestCheckin?.cravingLevel, hasCheckinToday {
            switch latest {
            case .low:
                return "You checked in and gave yourself a clearer read on today."
            case .medium:
                return "You named the moment. That makes the next step easier."
            case .high:
                return "You noticed the intensity early. That is a steady move."
            }
        }
        return "You checked in."
    }

    private func checkinToastTitle(for level: DailyCravingLevel) -> String {
        switch level {
        case .low:
            return "Nice check-in."
        case .medium:
            return "You named the moment."
        case .high:
            return "You checked in early."
        }
    }

    private func checkinToastMessage(for level: DailyCravingLevel) -> String {
        switch level {
        case .low:
            return "A quick note like this helps you stay in touch with your rhythm."
        case .medium:
            return "You gave yourself a clearer read on today."
        case .high:
            return "Support tends to work better when you catch the moment early."
        }
    }

    private var todayFocusRewardMessage: String {
        if appState.nicotineFreeDays >= 7 {
            return "Small steady choices are helping this routine stick."
        }
        if appState.cravingsDefeated > 0 {
            return "You are building trust with yourself."
        }
        return "Small wins like this are how momentum begins."
    }

    private var progressSnapshotSubtitle: String {
        if appState.nicotineFreeDays >= 7 {
            return "Your steady days are adding up."
        }
        if appState.cravingsDefeated > 0 {
            return "Your recent choices are starting to build momentum."
        }
        return "Even small progress counts."
    }

    private func isMilestoneUnlocked(_ milestone: Milestone) -> Bool {
        switch milestone {
        case .first24Hours:
            return appState.nicotineFreeDays >= 1
        case .firstCravingResisted:
            return appState.cravingsDefeated >= 1
        case .threeDays:
            return appState.nicotineFreeDays >= 3
        case .sevenDays:
            return appState.nicotineFreeDays >= 7
        }
    }

    private func syncMilestones() {
        let currentlyUnlocked = Set(Milestone.allCases.filter(isMilestoneUnlocked))
        let newlyUnlocked = currentlyUnlocked.subtracting(seenUnlockedMilestones)

        seenUnlockedMilestones = currentlyUnlocked

        for milestone in newlyUnlocked {
            appState.showRewardToast(
                title: "A step forward.",
                message: "You’re building momentum."
            )
            animatedMilestones.insert(milestone)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
                withAnimation(.easeInOut(duration: 0.2)) {
                    _ = animatedMilestones.remove(milestone)
                }
            }
        }
    }
}

private struct HomeMetricPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.ink)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.heroSecondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.sm)
        .background(Color.cardBackground.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CompactStat: View {
    let label: String
    let value: String
    var emphasis: StatEmphasis = .secondary

    enum StatEmphasis {
        case primary
        case secondary
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(emphasis == .primary ? Color.heroSecondaryText : Color.secondaryText)

            Text(value)
                .font(emphasis == .primary ? .title3.weight(.bold) : .subheadline.weight(.semibold))
                .foregroundStyle(Color.ink.opacity(emphasis == .primary ? 1 : 0.8))
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProgressRing: View {
    let progress: Double
    let lineWidth: CGFloat
    let diameter: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.surfaceMuted, lineWidth: lineWidth)

            Circle()
                .trim(from: 0, to: max(0.06, min(progress, 1)))
                .stroke(
                    AngularGradient(
                        colors: [Color.heroAccent, Color.buttonTop, Color.buttonBottom],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
        }
        .frame(width: diameter, height: diameter)
    }
}

private struct WeeklyCheckinStrip: View {
    let days: [HomeView.CheckinDay]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Last 7 days")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            HStack(spacing: 8) {
                ForEach(days) { day in
                    VStack(spacing: 6) {
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .fill(fillColor(for: day.level))
                            .frame(width: 24, height: 40)
                            .overlay(
                                RoundedRectangle(cornerRadius: 7, style: .continuous)
                                    .stroke(strokeColor(for: day.level), lineWidth: 1)
                            )

                        Text(dayLabel(for: day.date))
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
        }
    }

    private func fillColor(for level: DailyCravingLevel?) -> Color {
        switch level {
        case .low:
            return Color.heroAccent.opacity(0.34)
        case .medium:
            return Color.buttonTop.opacity(0.24)
        case .high:
            return Color.buttonBottom.opacity(0.28)
        case nil:
            return Color.surfaceMuted
        }
    }

    private func strokeColor(for level: DailyCravingLevel?) -> Color {
        switch level {
        case nil:
            return Color.border
        default:
            return Color.clear
        }
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
