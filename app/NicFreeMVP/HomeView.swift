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
    }

    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab
    @State private var showingSlipFlow = false
    @State private var showingCravingView = false
    @State private var showingPaywallTest = false
    @State private var cravingCardBreathing = false
    @State private var completedTodayActions: Set<TodayAction> = []
    @State private var showingInsightDetails = false
    @State private var animatedMilestones: Set<Milestone> = []
    @State private var seenUnlockedMilestones: Set<Milestone> = []

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        homeHeader
                            .softEntrance(delay: 0.02, distance: 14)

                        progressCard
                            .softEntrance(delay: 0.08, distance: 16, initialScale: 0.97)

                        cravingActionCard
                            .softEntrance(delay: 0.14, distance: 16, initialScale: 0.97)

                        todayActionsSection
                            .softEntrance(delay: 0.18, distance: 16, initialScale: 0.97)

                        insightCard
                            .softEntrance(delay: 0.2, distance: 16, initialScale: 0.97)

                        milestonesSection
                            .softEntrance(delay: 0.24, distance: 16, initialScale: 0.97)

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.cardBackground.opacity(0.98), Color.cardSecondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 16) {
                                ConversationalRevealText(
                                    text: "Keep going",
                                    startDelay: 0.15,
                                    chunkDelay: 0.95,
                                    chunking: .phrases,
                                    style: .init(
                                        font: .title3.weight(.semibold),
                                        finalColor: Color.ink,
                                        mutedColor: Color.secondaryText,
                                        lineSpacing: 4,
                                        initialOpacity: 0.1,
                                        animation: .easeOut(duration: 0.5)
                                    )
                                )

                                ConversationalRevealText(
                                    text: appState.dynamicMotivation,
                                    startDelay: 0.8,
                                    chunkDelay: 1.1,
                                    chunking: .sentences,
                                    style: .init(
                                        font: .subheadline,
                                        finalColor: Color.secondaryText,
                                        mutedColor: Color.secondaryText,
                                        lineSpacing: 4,
                                        initialOpacity: 0.12,
                                        animation: .easeOut(duration: 0.5)
                                    )
                                )

                                if let reason = appState.highlightedQuitReason {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Why this matters")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.heroAccent)
                                            .textCase(.uppercase)
                                            .tracking(1.1)

                                        Text(reason)
                                            .font(.body.weight(.semibold))
                                            .foregroundStyle(Color.ink)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .glassPanel(cornerRadius: 20, tint: Color.cardBackground, tintOpacity: 0.14, shadowOpacity: 0.04)
                                } else {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Make this more personal")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.heroAccent)
                                            .textCase(.uppercase)
                                            .tracking(1.1)

                                        Text("Add a quit reason in Settings so the app can bring it back when cravings hit.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.secondaryText)
                                            .lineSpacing(4)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .glassPanel(cornerRadius: 20, tint: Color.cardBackground, tintOpacity: 0.12, shadowOpacity: 0.03)
                                }

                                if appState.cravingEvents.isEmpty {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("No cravings logged yet")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(Color.ink)

                                        Text("When you use Rescue and log a craving, your patterns and progress will start to show up here.")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondaryText)
                                            .lineSpacing(3)
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.surfaceMuted)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                Button {
                                    showingSlipFlow = true
                                } label: {
                                    Text("I slipped")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.secondaryText)
                                }
                                .buttonStyle(SecondaryButtonStyle())

                                Button {
                                    showingPaywallTest = true
                                } label: {
                                    Text("Open Paywall")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.secondaryText)
                                }
                                .buttonStyle(SecondaryButtonStyle())
                            }
                        }
                        .softEntrance(delay: 0.28, distance: 18, animation: MicroAnimation.supportiveReveal, initialScale: 0.968)

                        CardSection {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Daily check-in")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text("How strong are cravings today?")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)

                                HStack(spacing: 10) {
                                    ForEach(DailyCravingLevel.allCases) { level in
                                        Button {
                                            appState.saveDailyCheckin(level: level)
                                        } label: {
                                            Text(level.title)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(appState.latestCheckin?.cravingLevel == level ? Color.white : Color.ink)
                                                .frame(maxWidth: .infinity)
                                                .padding(.vertical, 14)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                                        .fill(appState.latestCheckin?.cravingLevel == level ? Color.buttonBottom : Color.surfaceElevated)
                                                )
                                        }
                                        .buttonStyle(SelectableButtonStyle(isSelected: appState.latestCheckin?.cravingLevel == level))
                                    }
                                }

                                Text(latestCheckinText)
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                        .softEntrance(delay: 0.34, distance: 18, initialScale: 0.968)
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
                cravingCardBreathing = true
                syncMilestones()
            }
            .onChange(of: appState.nicotineFreeDays) { _ in
                syncMilestones()
            }
            .onChange(of: appState.cravingsDefeated) { _ in
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
            return "No check-in yet today. A quick check-in helps the app understand how cravings are showing up."
        }

        return "Latest check-in: \(latest.cravingLevel.title)"
    }

    private var homeHeader: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Today")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            Text("Day \(max(appState.nicotineFreeDays, 1)) smoke free")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.ink.opacity(0.9))

            Text(currentWeekday)
                .font(.footnote.weight(.medium))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 10)
    }

    private var progressCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 10) {
                Text("🔥")
                    .font(.title3)

                Text("Streak")
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.ink)
            }

            Text("\(max(appState.nicotineFreeDays, 1)) days nicotine free")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.ink)

            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cravings resisted: \(appState.cravingsDefeated)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.ink)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Text("Money saved: \(appState.moneySaved.formatted(.currency(code: currencyCode)))")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.ink)
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
        .shadow(color: Color.shadowColor.opacity(0.08), radius: 18, x: 0, y: 10)
    }

    private var cravingActionCard: some View {
        Button {
            showingCravingView = true
        } label: {
            HStack(spacing: 14) {
                Text("⚡")
                    .font(.title2)

                VStack(alignment: .leading, spacing: 6) {
                    Text("I have a craving")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.white)

                    Text("Tap for help")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.82))
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.buttonTop.opacity(0.94),
                                Color.buttonBottom.opacity(0.96)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: Color.buttonBottom.opacity(0.18), radius: 18, x: 0, y: 10)
            .scaleEffect(cravingCardBreathing ? 1.02 : 1)
            .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: cravingCardBreathing)
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var todayActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            ForEach(TodayAction.allCases) { action in
                TodayActionCard(
                    title: action.title,
                    helperText: action.helperText,
                    isCompleted: completedTodayActions.contains(action)
                ) {
                    if completedTodayActions.contains(action) {
                        completedTodayActions.remove(action)
                    } else {
                        completedTodayActions.insert(action)
                        appState.showRewardToast(
                            title: "Nice",
                            message: "Small steps beat cravings."
                        )
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var insightCard: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.3)) {
                showingInsightDetails.toggle()
            }
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                Text("Why cravings happen")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(Color.ink)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Nicotine spikes dopamine.")
                        .font(.body)
                        .foregroundStyle(Color.secondaryText)

                    Text("When the level drops, your brain asks for more.")
                        .font(.body)
                        .foregroundStyle(Color.secondaryText)

                    Text("Most cravings pass within 2–3 minutes.")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.ink)
                }

                if showingInsightDetails {
                    Text("That is why short replacement actions matter so much. You usually do not need to solve the whole day. You only need to outlast the peak of the urge.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(3)
                        .transition(.opacity.combined(with: .offset(y: 8)))
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(Color.border, lineWidth: 1)
            )
            .shadow(color: Color.shadowColor.opacity(0.08), radius: 18, x: 0, y: 10)
        }
        .buttonStyle(.plain)
    }

    private var milestonesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Milestones")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)], spacing: 12) {
                ForEach(Milestone.allCases) { milestone in
                    milestoneTile(for: milestone)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func milestoneTile(for milestone: Milestone) -> some View {
        let unlocked = isMilestoneUnlocked(milestone)
        let shouldAnimate = animatedMilestones.contains(milestone)

        return VStack(alignment: .leading, spacing: 10) {
            Image(systemName: unlocked ? "checkmark.circle.fill" : "lock.fill")
                .font(.headline.weight(.semibold))
                .foregroundStyle(unlocked ? Color.white : Color.secondaryText)

            Spacer(minLength: 0)

            Text(milestone.title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(unlocked ? Color.white : Color.ink)
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(14)
        .frame(maxWidth: .infinity, minHeight: 78, maxHeight: 78, alignment: .topLeading)
        .background(unlocked ? Color.buttonBottom : Color.surface)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(unlocked ? Color.cardBackground.opacity(0.18) : Color.border, lineWidth: 1)
        )
        .shadow(color: unlocked ? Color.buttonBottom.opacity(0.16) : Color.shadowColor.opacity(0.05), radius: 12, x: 0, y: 8)
        .scaleEffect(shouldAnimate ? 1.1 : 1)
        .animation(.easeInOut(duration: 0.25), value: shouldAnimate)
    }

    private var currentWeekday: String {
        let formatter = DateFormatter()
        formatter.locale = .current
        formatter.dateFormat = "EEEE"
        return formatter.string(from: .now)
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
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

private struct TodayActionCard: View {
    let title: String
    let helperText: String
    let isCompleted: Bool
    let action: () -> Void

    @State private var tapPulse = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.1)) {
                tapPulse = true
            }
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.easeInOut(duration: 0.12)) {
                    tapPulse = false
                }
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isCompleted ? Color.buttonBottom : Color.secondaryText)
                    .animation(.easeInOut(duration: 0.16), value: isCompleted)

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)
                        .multilineTextAlignment(.leading)

                    Text(helperText)
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, minHeight: 64, alignment: .leading)
            .background(isCompleted ? Color.surfaceElevated : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isCompleted ? Color.buttonBottom.opacity(0.3) : Color.border, lineWidth: 1)
            )
            .shadow(color: Color.shadowColor.opacity(0.06), radius: 12, x: 0, y: 8)
            .scaleEffect(tapPulse ? 0.97 : 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
