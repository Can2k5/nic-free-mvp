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
                return "Delay first puff"
            case .drinkWater:
                return "Drink water"
            case .deepBreaths:
                return "Take 3 deep breaths"
            case .walkTwoMinutes:
                return "Walk for 2 minutes"
            }
        }

        var helperText: String {
            switch self {
            case .delayFirstPuff:
                return "Wait 5 minutes before smoking"
            case .drinkWater:
                return "Reset the urge with one glass"
            case .deepBreaths:
                return "Slow your body down first"
            case .walkTwoMinutes:
                return "Break the pattern with movement"
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
                return "First 24 hours"
            case .firstCravingResisted:
                return "First craving resisted"
            case .threeDays:
                return "3 days nicotine free"
            case .sevenDays:
                return "7 days nicotine free"
            }
        }

        var compactTitle: String {
            switch self {
            case .first24Hours:
                return "24h"
            case .firstCravingResisted:
                return "First save"
            case .threeDays:
                return "3 days"
            case .sevenDays:
                return "7 days"
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
                    VStack(spacing: 18) {
                        homeHeader
                            .softEntrance(delay: 0.02, distance: 14)

                        homeHeroSummary
                            .softEntrance(delay: 0.08, distance: 16, initialScale: 0.97)

                        homeProgressVisual
                            .softEntrance(delay: 0.13, distance: 16, initialScale: 0.975)

                        homeDailyCheckIn
                            .softEntrance(delay: 0.17, distance: 16, initialScale: 0.98)

                        homeCravingQuickAction
                            .softEntrance(delay: 0.21, distance: 16, initialScale: 0.98)

                        homeTodayFocus
                            .softEntrance(delay: 0.24, distance: 16, initialScale: 0.98)

                        homeMilestonesStrip
                            .softEntrance(delay: 0.28, distance: 16, initialScale: 0.98)

                        utilityFooter
                            .softEntrance(delay: 0.32, distance: 12, initialScale: 0.99)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
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
            return "No check-in yet today"
        }

        if Calendar.current.isDateInToday(latest.date) {
            return "Checked in today: \(latest.cravingLevel.title)"
        }

        return "Latest check-in: \(latest.cravingLevel.title)"
    }

    private var currentContextLabel: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: .now)
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
            return ("Next milestone", min(Double(days), 1), "\(days)d", "1 day")
        } else if days < 3 {
            let segmentProgress = Double(days - 1) / 2
            return ("Next milestone", max(0, min(segmentProgress, 1)), "\(days)d", "3 days")
        } else if days < 7 {
            let segmentProgress = Double(days - 3) / 4
            return ("Next milestone", max(0, min(segmentProgress, 1)), "\(days)d", "7 days")
        } else {
            let span = max(appState.nicotineFreeDays, 7)
            let progress = min(Double(span - 7) / 7, 1)
            return ("Momentum", progress, "\(span)d", "14 days")
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

    private var homeHeader: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Today")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text(currentContextLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.secondaryText)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                Text("Smoke-free time")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.heroAccent)
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text(appState.smokeFreeTimeText)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.ink)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(Color.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    private var homeHeroSummary: some View {
        CardSection(
            fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.heroTop.opacity(0.98), Color.heroBottom.opacity(0.98)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        ) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(alignment: .top, spacing: 14) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Day \(max(appState.nicotineFreeDays, 1))")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)

                        Text("Nicotine-free")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.heroSecondaryText)
                    }

                    Spacer()

                    Text(statusBadgeTitle)
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.heroAccent)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 9)
                        .background(Color.cardBackground.opacity(0.58))
                        .clipShape(Capsule())
                }

                Text(emotionalAnchor)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.ink.opacity(0.86))
                    .lineSpacing(4)

                HStack(spacing: 10) {
                    HomeMetricPill(
                        title: "Saved",
                        value: appState.moneySaved.formatted(.currency(code: currencyCode))
                    )
                    HomeMetricPill(
                        title: "Resisted",
                        value: "\(appState.cravingsDefeated)"
                    )
                    HomeMetricPill(
                        title: "Avoided",
                        value: "\(appState.cigarettesAvoided)"
                    )
                }
            }
        }
    }

    private var homeProgressVisual: some View {
        CardSection {
            HStack(alignment: .center, spacing: 18) {
                ProgressRing(
                    progress: progressSummary.progress,
                    lineWidth: 10,
                    diameter: 92
                )
                .overlay {
                    VStack(spacing: 2) {
                        Text(progressRingValue)
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.ink)

                        Text("days")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                VStack(alignment: .leading, spacing: 14) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(progressSummary.title)
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("\(progressSummary.current) of \(progressSummary.target)")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }

                    WeeklyCheckinStrip(days: weekCheckins)

                    HStack(spacing: 12) {
                        CompactStat(
                            label: "This week",
                            value: appState.weeklyCravingsSurvivedText
                        )
                        CompactStat(
                            label: "Check-in",
                            value: appState.latestCheckin?.cravingLevel.title ?? "Open"
                        )
                    }
                }
            }
        }
    }

    private var homeDailyCheckIn: some View {
        CardSection {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily check-in")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("How strong are cravings today?")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    Text(latestCheckinText)
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(Color.heroAccent)
                        .multilineTextAlignment(.trailing)
                }

                HStack(spacing: 10) {
                    ForEach(DailyCravingLevel.allCases) { level in
                        Button {
                            appState.saveDailyCheckin(level: level)
                        } label: {
                            VStack(spacing: 6) {
                                Text(level.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(appState.latestCheckin?.cravingLevel == level ? Color.white : Color.ink)

                                Text(levelDescriptor(for: level))
                                    .font(.caption.weight(.medium))
                                    .foregroundStyle(appState.latestCheckin?.cravingLevel == level ? Color.white.opacity(0.82) : Color.secondaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(appState.latestCheckin?.cravingLevel == level ? Color.buttonBottom : Color.surfaceElevated)
                            )
                        }
                        .buttonStyle(SelectableButtonStyle(isSelected: appState.latestCheckin?.cravingLevel == level))
                    }
                }
            }
        }
    }

    private var homeCravingQuickAction: some View {
        Button {
            showingCravingView = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "bolt.heart.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.buttonBottom)
                    .frame(width: 40, height: 40)
                    .background(Color.cardBackground.opacity(0.72))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text("Need help now?")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text("Open Rescue for a craving reset")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .stroke(Color.border, lineWidth: 1)
            )
            .shadow(color: Color.shadowColor.opacity(0.05), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var homeTodayFocus: some View {
        let action = selectedTodayFocus
        let isCompleted = completedTodayActions.contains(action)

        return CardSection {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today focus")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("One small move to keep momentum")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }

                    Spacer()

                    Image(systemName: action.symbol)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.heroAccent)
                        .frame(width: 38, height: 38)
                        .background(Color.accentWash.opacity(0.95))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

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
                        appState.showRewardToast(
                            title: "Nice",
                            message: "Small steps beat cravings."
                        )
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                            .font(.headline.weight(.semibold))

                        Text(isCompleted ? "Marked complete" : "Mark as done")
                            .font(.subheadline.weight(.semibold))
                    }
                    .foregroundStyle(isCompleted ? Color.buttonBottom : Color.ink)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(isCompleted ? Color.accentWash : Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .stroke(isCompleted ? Color.heroAccent.opacity(0.28) : Color.border, lineWidth: 1)
                    )
                }
                .buttonStyle(CardPressButtonStyle())
            }
        }
    }

    private var homeMilestonesStrip: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Milestones")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)

                Spacer()

                Text("\(Milestone.allCases.filter(isMilestoneUnlocked).count)/\(Milestone.allCases.count)")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Milestone.allCases) { milestone in
                        compactMilestoneTile(for: milestone)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
                Text("I slipped")
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
            return "Strong week"
        } else if appState.cravingsDefeated >= 1 {
            return "Building rhythm"
        } else {
            return "Fresh start"
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private func levelDescriptor(for level: DailyCravingLevel) -> String {
        switch level {
        case .low:
            return "Steady"
        case .medium:
            return "Manageable"
        case .high:
            return "Heavy"
        }
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
                title: "Milestone reached.",
                message: "Keep going."
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
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.heroSecondaryText)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.cardBackground.opacity(0.56))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct CompactStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
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
