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
    @EnvironmentObject private var authManager: AuthManager
    @Binding var selectedTab: RootTabView.Tab
    @State private var showingSlipFlow = false
    @State private var showingCravingView = false
    @State private var showingPaywallTest = false
    @State private var showingAccountFlow = false
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

                        homeProgressSnapshot
                            .softEntrance(delay: 0.18, distance: 16, initialScale: 0.98)

                        if shouldShowRescueEntry {
                            homeCravingQuickAction
                                .softEntrance(delay: 0.24, distance: 16, initialScale: 0.98)
                        }

                        homeTodayFocus
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
            .sheet(isPresented: $showingAccountFlow) {
                AccountDestinationView()
                    .environmentObject(appState)
                    .environmentObject(authManager)
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
        .trackAnalyticsEvent(.homeViewed)
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

        return TodayAction.allCases.first(where: { !isTodayActionCompleted($0) }) ?? .deepBreaths
    }

    private var progressSummary: (progress: Double, currentDays: Int, previousMilestone: Int, targetDays: Int, daysRemaining: Int, supportingLine: String) {
        let milestones = [1, 3, 7, 14, 30, 60, 90]
        let currentDays = max(appState.nicotineFreeDays, 0)
        let targetDays = milestones.first(where: { currentDays < $0 }) ?? max(currentDays + 30, 120)
        let previousMilestone = milestones.last(where: { $0 < targetDays }) ?? 0
        let span = max(targetDays - previousMilestone, 1)
        let progressedDays = max(currentDays - previousMilestone, 0)
        let progress = min(max(Double(progressedDays) / Double(span), 0.06), 1)
        let daysRemaining = max(targetDays - currentDays, 0)
        let milestoneLabel = targetDays == 1 ? "first day" : "\(targetDays)-day mark"
        let supportingLine = daysRemaining == 0
            ? "You just reached your \(milestoneLabel)."
            : "\(daysRemaining) \(daysRemaining == 1 ? "day" : "days") until your \(milestoneLabel)"

        return (progress, currentDays, previousMilestone, targetDays, daysRemaining, supportingLine)
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
            title: heroStreakTitle,
            subtitle: appState.smokeFreeStreakStatusLine
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.sm) {
                MomentumCurveProgress(
                    currentDays: progressSummary.currentDays,
                    width: 308,
                    curveHeight: 164
                )
                .padding(.top, AppSpacing.xs)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .overlay(alignment: .topTrailing) {
            AccountEntryButton {
                showingAccountFlow = true
            }
            .padding(.top, 18)
            .padding(.trailing, 18)
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
        isTodayActionCompleted(selectedTodayFocus) ? "Done for today ✓" : "Mark as done"
    }

    private var todayFocusActionBackground: Color {
        isTodayActionCompleted(selectedTodayFocus) ? Color.accentWash.opacity(0.95) : Color.surfaceElevated
    }

    private var todayFocusActionStroke: Color {
        isTodayActionCompleted(selectedTodayFocus) ? Color.heroAccent.opacity(0.28) : Color.border
    }

    private var todayFocusTitle: String {
        isTodayActionCompleted(selectedTodayFocus) ? "That step is done" : "Today’s focus"
    }

    private var todayFocusSubtitle: String {
        isTodayActionCompleted(selectedTodayFocus)
            ? "One small win, done."
            : "One small step that can help today"
    }

    private var homeDailyCheckIn: some View {
        ActionCard(
            title: "Today’s check-in",
            subtitle: latestCheckinText,
            icon: "waveform.path.ecg",
            showsChevron: false
        ) {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Today")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)
                        .textCase(.uppercase)
                        .tracking(0.9)

                    Text(dailyCheckInStatusText)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(dailyCheckInStatusColor)
                }

                Button {
                    toggleSmokeFreeToday()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isSmokeFreeMarkedToday ? "checkmark.circle.fill" : "circle")
                            .font(.headline.weight(.semibold))

                        Text(smokeFreeTodayActionTitle)
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(Color.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(
                        LinearGradient(
                            colors: isSmokeFreeMarkedToday
                                ? [Color.buttonTop.opacity(0.88), Color.buttonBottom.opacity(0.94)]
                                : [Color.buttonTop, Color.buttonBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(
                                isSmokeFreeMarkedToday ? Color.cardBackground.opacity(0.24) : Color.buttonBottom.opacity(0.2),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.buttonBottom.opacity(isSmokeFreeMarkedToday ? 0.14 : 0.2), radius: 14, x: 0, y: 8)
                }
                .buttonStyle(CardPressButtonStyle())

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
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.accentWash.opacity(0.26),
                            Color.cardBackground.opacity(0.42),
                            Color.surfaceElevated.opacity(0.18)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.horizontal, 4)
        )
    }

    private var homeCravingQuickAction: some View {
        Button {
            showingCravingView = true
        } label: {
            ActionCard(
                title: "Need support right now?",
                subtitle: "Open rescue and take the next small step",
                icon: "bolt.heart.fill",
                emphasizesAction: false
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var homeTodayFocus: some View {
        let action = selectedTodayFocus
        let isCompleted = isTodayActionCompleted(action)

        return ActionCard(
            title: "A small extra step",
            subtitle: isCompleted ? "You already handled today’s extra step." : "Optional support if you want a little more momentum.",
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
                        appState.setTodayActionCompleted(action.rawValue, isCompleted: false)
                    } else {
                        appState.setTodayActionCompleted(action.rawValue, isCompleted: true)
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

    private func isTodayActionCompleted(_ action: TodayAction) -> Bool {
        appState.isTodayActionCompleted(action.rawValue)
    }

    private var isSmokeFreeMarkedToday: Bool {
        appState.didSmokeFreeCheckInToday
    }

    private var smokeFreeTodayActionTitle: String {
        isSmokeFreeMarkedToday ? "Marked today as smoke-free" : "Mark today as smoke-free"
    }

    private func toggleSmokeFreeToday() {
        guard !isSmokeFreeMarkedToday else { return }

        let previousState = appState.smokeFreeStreakState
        appState.markSmokeFreeForToday()
        OnboardingHaptics.success()
        appState.showRewardToast(
            title: smokeFreeCheckinToastTitle(for: previousState),
            message: smokeFreeCheckinToastMessage(for: previousState)
        )
    }

    private var heroStreakTitle: String {
        switch appState.smokeFreeStreakState {
        case .active:
            return appState.smokeFreeStreakCount > 0 ? "\(appState.smokeFreeStreakCount)-day streak" : "Start your streak"
        case .onIce:
            return appState.smokeFreeStreakCount > 0 ? "\(appState.smokeFreeStreakCount)-day streak" : "Streak on ice"
        case .lost:
            return "Start your streak"
        }
    }

    private var dailyCheckInStatusText: String {
        if isSmokeFreeMarkedToday {
            return "✓ Completed"
        }

        switch appState.smokeFreeStreakState {
        case .active:
            return "Not checked in yet"
        case .onIce:
            return "Streak on ice"
        case .lost:
            return "Streak lost"
        }
    }

    private var dailyCheckInStatusColor: Color {
        switch appState.smokeFreeStreakState {
        case .active:
            return isSmokeFreeMarkedToday ? Color.buttonBottom : Color.ink
        case .onIce:
            return Color.orange
        case .lost:
            return Color.secondaryText
        }
    }

    private func smokeFreeCheckinToastTitle(for previousState: SmokeFreeStreakState) -> String {
        switch previousState {
        case .active:
            return "Today is on the board."
        case .onIce:
            return "Streak recovered."
        case .lost:
            return "A new streak starts today."
        }
    }

    private func smokeFreeCheckinToastMessage(for previousState: SmokeFreeStreakState) -> String {
        switch previousState {
        case .active:
            return "That daily commitment gives the rest of the day direction."
        case .onIce:
            return "You brought the streak back before it slipped away."
        case .lost:
            return "This check-in starts a fresh run."
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

private struct MomentumCurveProgress: View {
    let currentDays: Int
    let width: CGFloat
    let curveHeight: CGFloat

    @State private var animatedProgress: CGFloat = 0
    @State private var markersVisible = false

    private let levels: [Int] = [0, 1, 2, 5, 10, 14, 21, 30, 45, 60, 90, 120]

    private var nextIndex: Int {
        levels.firstIndex(where: { currentDays < $0 }) ?? max(levels.count - 1, 1)
    }

    private var currentLevelIndex: Int {
        max(nextIndex - 1, 0)
    }

    private var currentLevelDay: Int {
        levels[currentLevelIndex]
    }

    private var nextLevelDay: Int {
        levels[min(nextIndex, levels.count - 1)]
    }

    private var visibleStartIndex: Int {
        max(currentLevelIndex - 1, 0)
    }

    private var visibleEndIndex: Int {
        min(nextIndex + 1, levels.count - 1)
    }

    private var visibleStartDay: Int {
        levels[visibleStartIndex]
    }

    private var visibleEndDay: Int {
        levels[visibleEndIndex]
    }

    private var visibleRangeSpan: CGFloat {
        CGFloat(max(visibleEndDay - visibleStartDay, 1))
    }

    private func normalizedPosition(for day: Int) -> CGFloat {
        let clampedDay = min(max(day, visibleStartDay), visibleEndDay)
        return CGFloat(clampedDay - visibleStartDay) / visibleRangeSpan
    }

    private var currentPosition: CGFloat {
        normalizedPosition(for: currentDays)
    }

    private var progressContextLine: String {
        "\(max(currentDays, 1)) days nicotine-free"
    }

    private var axisTicks: [AxisTick] {
        let tickDays = [visibleStartDay, nextLevelDay, visibleEndDay]
        var ticks: [AxisTick] = []

        for day in tickDays {
            if !ticks.contains(where: { $0.day == day }) {
                ticks.append(AxisTick(day: day, progress: normalizedPosition(for: day)))
            }
        }

        return Array(ticks.prefix(4))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topLeading) {
                Ellipse()
                    .fill(Color.cardBackground.opacity(0.22))
                    .frame(width: width - 8, height: curveHeight - 10)
                    .blur(radius: 14)
                    .offset(x: 4, y: 10)

                MomentumCurveShape(progress: 1)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.surfaceMuted.opacity(0.9),
                                Color.surfaceMuted.opacity(0.68)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .frame(width: width, height: curveHeight)

                MomentumCurveShape(progress: max(0.01, min(animatedProgress, 1)))
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 0.79, green: 0.68, blue: 0.98),
                                Color.buttonTop.opacity(0.98),
                                Color.buttonBottom
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round)
                    )
                    .shadow(color: Color.buttonBottom.opacity(0.14), radius: 16, x: 0, y: 6)
                    .frame(width: width, height: curveHeight)

                currentProgressMarker(at: currentPosition)
            }
            .frame(width: width, height: curveHeight)

            MomentumAxis(
                width: width,
                ticks: axisTicks,
                currentProgress: currentPosition
            )

            Text(progressContextLine)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.ink.opacity(0.78))
        }
        .frame(width: width, alignment: .leading)
        .onAppear {
            animatedProgress = 0
            markersVisible = false
            withAnimation(.easeOut(duration: 1.34)) {
                animatedProgress = currentPosition
            }
            withAnimation(.easeOut(duration: 0.36).delay(0.18)) {
                markersVisible = true
            }
        }
        .onChange(of: currentDays) {
            animatedProgress = 0
            markersVisible = false
            withAnimation(.easeOut(duration: 1.22)) {
                animatedProgress = currentPosition
            }
            withAnimation(.easeOut(duration: 0.32).delay(0.16)) {
                markersVisible = true
            }
        }
    }

    @ViewBuilder
    private func currentProgressMarker(at t: CGFloat) -> some View {
        let point = MomentumCurveShape.point(
            in: CGRect(origin: .zero, size: CGSize(width: width, height: curveHeight)),
            t: t
        )

        ZStack {
            Circle()
                .fill(Color.buttonBottom.opacity(markersVisible ? 0.16 : 0))
                .frame(width: 24, height: 24)
                .blur(radius: 2)

            Circle()
                .fill(Color.buttonBottom)
                .frame(width: 14, height: 14)
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.92), lineWidth: 2)
                )
        }
        .shadow(color: Color.buttonBottom.opacity(0.14), radius: 10, x: 0, y: 4)
        .opacity(markersVisible ? 1 : 0.86)
        .position(x: point.x, y: point.y)
    }
}

private struct AxisTick: Identifiable {
    let day: Int
    let progress: CGFloat

    var id: Int { day }
}

private struct MomentumAxis: View {
    let width: CGFloat
    let ticks: [AxisTick]
    let currentProgress: CGFloat

    var body: some View {
        ZStack(alignment: .leading) {
            Capsule(style: .continuous)
                .fill(Color.border.opacity(0.2))
                .frame(width: width, height: 1)

            ForEach(ticks) { tick in
                VStack(spacing: 6) {
                    Capsule(style: .continuous)
                        .fill(tickFill(for: tick))
                        .frame(width: 1.5, height: tick.progress <= currentProgress ? 8 : 6)

                    Text("\(tick.day)")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(tick.progress <= currentProgress ? Color.ink.opacity(0.72) : Color.secondaryText.opacity(0.68))
                }
                .position(x: width * tick.progress, y: 16)
            }
        }
        .frame(width: width, height: 30, alignment: .leading)
    }

    private func tickFill(for tick: AxisTick) -> Color {
        tick.progress <= currentProgress ? Color.buttonBottom.opacity(0.52) : Color.border.opacity(0.42)
    }
}

private struct MomentumCurveShape: Shape {
    var progress: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let clamped = max(0, min(progress, 1))
        guard clamped > 0 else { return path }

        let start = CGPoint(x: rect.minX + 4, y: rect.maxY - 14)
        let end = CGPoint(x: rect.maxX - 4, y: rect.minY + 24)
        let firstControl = CGPoint(x: rect.minX + (rect.width * 0.16), y: rect.minY - 8)
        let secondControl = CGPoint(x: rect.minX + (rect.width * 0.56), y: rect.minY + 4)
        let steps = max(Int(110 * clamped), 2)

        path.move(to: start)

        for step in 1...steps {
            let t = CGFloat(step) / CGFloat(steps)
            let scaledT = t * clamped
            let point = Self.cubicBezierPoint(
                t: scaledT,
                start: start,
                control1: firstControl,
                control2: secondControl,
                end: end
            )
            path.addLine(to: point)
        }

        return path
    }

    static func point(in rect: CGRect, t: CGFloat) -> CGPoint {
        let clamped = max(0, min(t, 1))
        let start = CGPoint(x: rect.minX + 4, y: rect.maxY - 14)
        let end = CGPoint(x: rect.maxX - 4, y: rect.minY + 24)
        let firstControl = CGPoint(x: rect.minX + (rect.width * 0.16), y: rect.minY - 8)
        let secondControl = CGPoint(x: rect.minX + (rect.width * 0.56), y: rect.minY + 4)
        return cubicBezierPoint(t: clamped, start: start, control1: firstControl, control2: secondControl, end: end)
    }

    private static func cubicBezierPoint(
        t: CGFloat,
        start: CGPoint,
        control1: CGPoint,
        control2: CGPoint,
        end: CGPoint
    ) -> CGPoint {
        let inverseT = 1 - t
        let x =
            (inverseT * inverseT * inverseT * start.x) +
            (3 * inverseT * inverseT * t * control1.x) +
            (3 * inverseT * t * t * control2.x) +
            (t * t * t * end.x)
        let y =
            (inverseT * inverseT * inverseT * start.y) +
            (3 * inverseT * inverseT * t * control1.y) +
            (3 * inverseT * t * t * control2.y) +
            (t * t * t * end.y)
        return CGPoint(x: x, y: y)
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
        .environmentObject(AuthManager())
}
