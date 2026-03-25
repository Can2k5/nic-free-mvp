import SwiftUI

struct AchievementsView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var subscriptionManager: SubscriptionManager

    @Namespace private var achievementNamespace

    @State private var showingPaywall = false
    @State private var selectedAchievementID: JourneyAchievementID?
    @State private var selectedAchievementSource: AchievementTransitionSource?
    @State private var detailDragOffset: CGFloat = 0
    @State private var detailContentVisible = false
    @State private var confettiRunID = UUID()
    @State private var showConfetti = false
    @AppStorage("markers_locked_paywall_last_presented_at") private var markersLockedPaywallLastPresentedAt = 0.0

    private let badgeColumns = [
        GridItem(.flexible(), spacing: 14),
        GridItem(.flexible(), spacing: 14)
    ]

    private var unlockedCount: Int {
        appState.unlockedJourneyAchievements.count
    }

    private var totalCount: Int {
        appState.journeyAchievements.count
    }

    private var selectedAchievement: JourneyAchievement? {
        guard let selectedAchievementID else { return nil }
        return appState.journeyAchievements.first(where: { $0.id == selectedAchievementID })
    }

    private var detailDismissProgress: CGFloat {
        min(max(detailDragOffset / 240, 0), 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                achievementsBackground

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.section) {
                        headerSection
                            .softEntrance(delay: 0.02, distance: 12, initialScale: 0.985)

                        rewardSummaryCard
                            .softEntrance(delay: 0.08, distance: 16, initialScale: 0.98)

                        if !appState.recentUnlockedJourneyAchievements.isEmpty {
                            recentUnlocksSection
                                .softEntrance(delay: 0.14, distance: 18, initialScale: 0.98)
                        }

                        nextUpSection
                            .softEntrance(delay: 0.2, distance: 18, initialScale: 0.98)

                        allAchievementsSection
                            .softEntrance(delay: 0.26, distance: 18, initialScale: 0.98)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
                .blur(radius: selectedAchievement == nil ? 0 : 10)
                .scaleEffect(selectedAchievement == nil ? 1 : 0.985)
                .allowsHitTesting(selectedAchievement == nil)
                .animation(.easeInOut(duration: 0.28), value: selectedAchievementID)

                if let selectedAchievement {
                    Color.overlayScrim
                        .opacity(0.18 * (1 - detailDismissProgress))
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            closeAchievement()
                        }

                    achievementDetailOverlay(selectedAchievement)
                        .zIndex(20)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(
                onClose: {
                    showingPaywall = false
                }
            )
            .presentationBackground(.clear)
        }
    }

    private var achievementsBackground: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color.appBackgroundTop,
                    Color.appBackgroundBottom
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Circle()
                .fill(Color.cardBackground.opacity(0.18))
                .frame(width: 360, height: 360)
                .blur(radius: 56)
                .offset(x: 120, y: -220)

            Circle()
                .fill(Color.mist.opacity(0.22))
                .frame(width: 320, height: 320)
                .blur(radius: 60)
                .offset(x: -130, y: 300)
        }
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Progress markers")
                .font(.system(size: 34, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)

            Text("Each one reflects a real step forward.")
                .font(.title3.weight(.medium))
                .foregroundStyle(Color.secondaryText)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rewardSummaryCard: some View {
        HeroCard(
            eyebrow: "So far",
            title: "\(unlockedCount) / \(totalCount)",
            subtitle: unlockedCount == 0 ? "Your first one will come with time." : "Your progress is starting to feel more visible.",
            icon: "sparkles"
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    HStack {
                        Text("Overall progress")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.heroSecondaryText)

                        Spacer()

                        Text("\(Int((Double(unlockedCount) / Double(max(totalCount, 1)) * 100).rounded()))%")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(Color.ink)
                    }

                    GeometryReader { proxy in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.cardBackground.opacity(0.44))

                            Capsule()
                                .fill(Color.buttonBottom.opacity(0.8))
                                .frame(width: proxy.size.width * CGFloat(Double(unlockedCount) / Double(max(totalCount, 1))))
                        }
                    }
                    .frame(height: 12)
                }

                Button {
                    showingPaywall = true
                } label: {
                    Text("See the full version")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.buttonBottom)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.cardBackground.opacity(0.84))
                        .clipShape(Capsule())
                }
                .buttonStyle(CardPressButtonStyle())
            }
        }
    }

    private var recentUnlocksSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Reached recently")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(appState.recentUnlockedJourneyAchievements) { achievement in
                        recentAchievementCard(achievement)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var nextUpSection: some View {
        Group {
            if let next = appState.nextJourneyAchievement {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Coming up next")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Button {
                        openAchievement(next, source: .standalone)
                    } label: {
                        ActionCard(
                            title: next.title,
                            subtitle: next.subtitle,
                            icon: next.symbol
                        ) {
                            HStack(spacing: 14) {
                                Text(next.progressText)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Spacer()

                                Text("\(Int((next.progress * 100).rounded()))%")
                                    .font(.footnote.weight(.bold))
                                    .foregroundStyle(Color.secondaryText)
                            }

                            GeometryReader { proxy in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color.surfaceMuted)

                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [next.accentTop, next.accentBottom],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                        .frame(width: proxy.size.width * CGFloat(next.progress))
                                }
                            }
                            .frame(height: 12)
                        }
                    }
                    .buttonStyle(CardPressButtonStyle())
                }
            }
        }
    }

    private var allAchievementsSection: some View {
        PremiumLockedContent(
            isLocked: subscriptionManager.isFree,
            message: "Unlock all progress markers.",
            action: { presentLockedMarkersPaywallIfNeeded() }
        ) {
            VStack(alignment: .leading, spacing: 14) {
                Text("All progress markers")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)

                LazyVGrid(columns: badgeColumns, spacing: 14) {
                    ForEach(appState.journeyAchievements) { achievement in
                        achievementGridCard(achievement)
                    }
                }
            }
        }
    }

    private func presentLockedMarkersPaywallIfNeeded() {
        guard subscriptionManager.isFree else {
            showingPaywall = true
            return
        }

        let now = Date().timeIntervalSince1970
        let cooldown: TimeInterval = 120
        guard now - markersLockedPaywallLastPresentedAt >= cooldown else { return }

        markersLockedPaywallLastPresentedAt = now
        showingPaywall = true
    }

    private func recentAchievementCard(_ achievement: JourneyAchievement) -> some View {
        Button {
            openAchievement(achievement, source: .recent)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    badgeIcon(for: achievement, size: 52)
                        .matchedGeometryEffect(id: animationID("icon", for: achievement.id, source: .recent), in: achievementNamespace)

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .font(.headline)
                        .foregroundStyle(Color.white.opacity(0.92))
                }

                Spacer(minLength: 0)

                Text(achievement.title)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color.white)
                    .lineLimit(2)

                        Text("Reached")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.white.opacity(0.84))
            }
            .padding(18)
            .frame(width: 168, height: 176, alignment: .topLeading)
            .background(
                LinearGradient(
                    colors: [achievement.accentTop, achievement.accentBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(Color.border.opacity(0.72), lineWidth: 1)
            )
            .shadow(color: achievement.accentBottom.opacity(0.22), radius: 18, x: 0, y: 12)
            .matchedGeometryEffect(id: animationID("card", for: achievement.id, source: .recent), in: achievementNamespace)
            .opacity(selectedAchievementID == achievement.id && selectedAchievementSource == .recent ? 0 : 1)
        }
        .buttonStyle(.plain)
    }

    private func achievementGridCard(_ achievement: JourneyAchievement) -> some View {
        Button {
            openAchievement(achievement, source: .grid)
        } label: {
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    badgeIcon(for: achievement, size: 48, dimmed: !achievement.isUnlocked)
                        .matchedGeometryEffect(id: animationID("icon", for: achievement.id, source: .grid), in: achievementNamespace)

                    Spacer()

                    if achievement.isUnlocked {
                        Text("Reached")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(Color.cardBackground.opacity(0.22))
                            .clipShape(Capsule())
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.secondaryText.opacity(0.8))
                    }
                }

                VStack(alignment: .leading, spacing: 5) {
                    Text(achievement.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(achievement.isUnlocked ? Color.white : Color.ink)
                        .lineLimit(2)

                    Text(achievement.subtitle)
                        .font(.footnote)
                        .foregroundStyle(achievement.isUnlocked ? Color.white.opacity(0.84) : Color.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                if achievement.isUnlocked {
                    Text("Reached")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.white.opacity(0.88))
                } else {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(achievement.progressText)
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)

                        GeometryReader { proxy in
                            ZStack(alignment: .leading) {
                                Capsule()
                                    .fill(Color.surfaceMuted)

                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [achievement.accentTop.opacity(0.92), achievement.accentBottom.opacity(0.92)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: proxy.size.width * CGFloat(achievement.progress))
                            }
                        }
                        .frame(height: 10)
                    }
                }
            }
            .padding(18)
            .frame(maxWidth: .infinity, minHeight: 210, alignment: .topLeading)
            .background(cardBackground(for: achievement))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(achievement.isUnlocked ? Color.border.opacity(0.7) : Color.border, lineWidth: 1)
            )
            .shadow(
                color: achievement.isUnlocked ? achievement.accentBottom.opacity(0.2) : Color.shadowColor.opacity(0.06),
                radius: achievement.isUnlocked ? 18 : 14,
                x: 0,
                y: achievement.isUnlocked ? 12 : 8
            )
            .matchedGeometryEffect(id: animationID("card", for: achievement.id, source: .grid), in: achievementNamespace)
            .opacity(selectedAchievementID == achievement.id && selectedAchievementSource == .grid ? 0 : 1)
        }
        .buttonStyle(CardPressButtonStyle())
    }

    @ViewBuilder
    private func achievementDetailOverlay(_ achievement: JourneyAchievement) -> some View {
        GeometryReader { proxy in
            let dragScale = 1 - (detailDismissProgress * 0.08)

            ZStack(alignment: .topTrailing) {
                detailCardBackground(for: achievement)

                VStack(alignment: .leading, spacing: 22) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 16) {
                            detailBadgeIcon(for: achievement)

                            VStack(alignment: .leading, spacing: 8) {
                                detailTitle(for: achievement)

                                Text(detailStatusText(for: achievement))
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(achievement.isUnlocked ? Color.white.opacity(0.92) : Color.secondaryText)
                            }
                            .opacity(detailContentVisible ? 1 : 0)
                            .offset(y: detailContentVisible ? 0 : 10)
                            .animation(.easeOut(duration: 0.18).delay(0.02), value: detailContentVisible)
                        }

                        Spacer(minLength: 16)

                        Button {
                            closeAchievement()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(achievement.isUnlocked ? Color.white : Color.ink)
                                .frame(width: 40, height: 40)
                                .background(
                                    Circle()
                                        .fill(achievement.isUnlocked ? Color.cardBackground.opacity(0.18) : Color.inputBackground)
                                )
                        }
                        .buttonStyle(.plain)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        detailInfoCard(
                            title: "What this means",
                            body: achievement.subtitle,
                            achievement: achievement
                        )

                        detailInfoCard(
                            title: achievement.isUnlocked ? "Why it matters" : "How to reach this",
                            body: unlockGuidance(for: achievement),
                            achievement: achievement
                        )

                        if !achievement.isUnlocked {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack {
                                    Text("Progress")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.ink)

                                    Spacer()

                                    Text(achievement.progressText)
                                        .font(.footnote.weight(.bold))
                                        .foregroundStyle(Color.secondaryText)
                                }

                                GeometryReader { progressProxy in
                                    ZStack(alignment: .leading) {
                                        Capsule()
                                            .fill(Color.surfaceMuted)

                                        Capsule()
                                            .fill(
                                                LinearGradient(
                                                    colors: [achievement.accentTop, achievement.accentBottom],
                                                    startPoint: .leading,
                                                    endPoint: .trailing
                                                )
                                            )
                                            .frame(width: progressProxy.size.width * CGFloat(achievement.progress))
                                    }
                                }
                                .frame(height: 14)
                            }
                            .padding(20)
                            .background(Color.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        }

                        detailInfoCard(
                            title: "Keep going",
                            body: motivationalDetailText(for: achievement),
                            achievement: achievement
                        )
                    }
                    .opacity(detailContentVisible ? 1 : 0)
                    .offset(y: detailContentVisible ? 0 : 12)
                    .animation(.easeOut(duration: 0.24).delay(0.06), value: detailContentVisible)

                    Spacer(minLength: 0)

                    Text("Swipe down or close this card to go back.")
                        .font(.footnote.weight(.medium))
                        .foregroundStyle(achievement.isUnlocked ? Color.white.opacity(0.84) : Color.secondaryText)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .opacity(detailContentVisible ? 1 : 0)
                        .offset(y: detailContentVisible ? 0 : 8)
                        .animation(.easeOut(duration: 0.2).delay(0.1), value: detailContentVisible)
                }
                .padding(24)
                .padding(.top, 18)

                if achievement.isUnlocked && showConfetti {
                    LightweightConfettiOverlay(trigger: confettiRunID)
                        .allowsHitTesting(false)
                        .transition(.opacity)
                }
            }
            .frame(width: proxy.size.width - 24, height: proxy.size.height - 24, alignment: .topLeading)
            .offset(y: detailDragOffset)
            .scaleEffect(dragScale, anchor: .top)
            .shadow(color: Color.black.opacity(0.12 * (1 - detailDismissProgress)), radius: 32, x: 0, y: 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .gesture(detailDragGesture)
            .transition(.identity)
            .task(id: achievement.id) {
                detailContentVisible = false
                try? await Task.sleep(for: .milliseconds(120))
                guard selectedAchievementID == achievement.id else { return }
                withAnimation(.easeOut(duration: 0.22)) {
                    detailContentVisible = true
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }

    private var detailDragGesture: some Gesture {
        DragGesture(minimumDistance: 8, coordinateSpace: .global)
            .onChanged { value in
                guard value.translation.height > 0 else { return }
                detailDragOffset = value.translation.height
            }
            .onEnded { value in
                if value.translation.height > 140 || value.predictedEndTranslation.height > 220 {
                    closeAchievement()
                } else {
                    withAnimation(.spring(duration: 0.42, bounce: 0.18)) {
                        detailDragOffset = 0
                    }
                }
            }
    }

    private func detailInfoCard(title: String, body: String, achievement: JourneyAchievement) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(achievement.isUnlocked ? Color.white.opacity(0.84) : Color.secondaryText)
                .textCase(.uppercase)
                .tracking(1.0)

            Text(body)
                .font(.body.weight(.medium))
                .foregroundStyle(achievement.isUnlocked ? Color.white : Color.ink)
                .lineSpacing(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            achievement.isUnlocked
                ? Color.cardBackground.opacity(0.16)
                : Color.inputBackground
        )
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }

    private func badgeIcon(for achievement: JourneyAchievement, size: CGFloat, dimmed: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.34, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            achievement.accentTop.opacity(dimmed ? 0.34 : 1),
                            achievement.accentBottom.opacity(dimmed ? 0.34 : 1)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: achievement.symbol)
                .font(.system(size: size * 0.34, weight: .bold))
                .foregroundStyle(Color.white.opacity(dimmed ? 0.78 : 1))
        }
        .frame(width: size, height: size)
    }

    @ViewBuilder
    private func detailBadgeIcon(for achievement: JourneyAchievement) -> some View {
        let icon = badgeIcon(for: achievement, size: 92, dimmed: !achievement.isUnlocked)

        if let selectedAchievementSource, selectedAchievementSource != .standalone {
            icon.matchedGeometryEffect(
                id: animationID("icon", for: achievement.id, source: selectedAchievementSource),
                in: achievementNamespace
            )
        } else {
            icon
        }
    }

    @ViewBuilder
    private func detailTitle(for achievement: JourneyAchievement) -> some View {
        Text(achievement.title)
            .font(.system(size: 34, weight: .bold, design: .rounded))
            .foregroundStyle(achievement.isUnlocked ? Color.white : Color.ink)
    }

    @ViewBuilder
    private func detailCardBackground(for achievement: JourneyAchievement) -> some View {
        let background = RoundedRectangle(cornerRadius: 30, style: .continuous)
            .fill(
                achievement.isUnlocked
                    ? AnyShapeStyle(
                        LinearGradient(
                            colors: [achievement.accentTop, achievement.accentBottom],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    : AnyShapeStyle(Color.inputBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 30, style: .continuous)
                    .stroke(
                        achievement.isUnlocked ? Color.border.opacity(0.7) : Color.border,
                        lineWidth: 1
                    )
            )

        if let selectedAchievementSource, selectedAchievementSource != .standalone {
            background.matchedGeometryEffect(
                id: animationID("card", for: achievement.id, source: selectedAchievementSource),
                in: achievementNamespace
            )
        } else {
            background
        }
    }

    private func cardBackground(for achievement: JourneyAchievement) -> AnyShapeStyle {
        if achievement.isUnlocked {
            return AnyShapeStyle(
                LinearGradient(
                    colors: [achievement.accentTop, achievement.accentBottom],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }

        return AnyShapeStyle(Color.surface)
    }

    private func openAchievement(_ achievement: JourneyAchievement, source: AchievementTransitionSource) {
        detailDragOffset = 0
        detailContentVisible = false
        withAnimation(.spring(duration: 0.6, bounce: 0.14)) {
            selectedAchievementSource = source
            selectedAchievementID = achievement.id
        }

        guard achievement.isUnlocked else {
            showConfetti = false
            return
        }

        confettiRunID = UUID()
        showConfetti = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.75) {
            guard selectedAchievementID == achievement.id else { return }
            withAnimation(.easeOut(duration: 0.25)) {
                showConfetti = false
            }
        }
    }

    private func closeAchievement() {
        withAnimation(.spring(duration: 0.56, bounce: 0.12)) {
            detailDragOffset = 0
            detailContentVisible = false
            showConfetti = false
            selectedAchievementID = nil
            selectedAchievementSource = nil
        }
    }

    private func animationID(_ part: String, for id: JourneyAchievementID, source: AchievementTransitionSource?) -> String {
        "\(source?.rawValue ?? "standalone")-\(part)-\(id.rawValue)"
    }

    private func detailStatusText(for achievement: JourneyAchievement) -> String {
        achievement.isUnlocked ? "Reached" : "On the way"
    }

    private func unlockGuidance(for achievement: JourneyAchievement) -> String {
        switch achievement.id {
        case .firstDay:
            return "Stay nicotine-free for one full day."
        case .firstRescue:
            return "Get through one urge and log it."
        case .threeDays:
            return "Stay with it until you reach day three."
        case .saver50:
            return "Save your first visible EUR 50."
        case .sevenDays:
            return "Reach a full nicotine-free week."
        case .tenRescues:
            return "Get through ten urges over time."
        case .saver100:
            return "Stay with it until your saved money reaches EUR 100."
        case .fourteenDays:
            return "Stay with the plan for two full weeks."
        }
    }

    private func motivationalDetailText(for achievement: JourneyAchievement) -> String {
        if achievement.isUnlocked {
            return "This one is already yours. Small steps like this are how change starts to feel real."
        }
        return "You are closer than it looks. Each nicotine-free day and each urge you outlast helps this take shape."
    }
}

private enum AchievementTransitionSource: String {
    case recent
    case grid
    case standalone
}

private struct LightweightConfettiOverlay: View {
    let trigger: UUID

    @State private var startDate = Date()

    private let duration: Double = 1.6
    private let particles: [ConfettiParticle] = (0..<22).map { index in
        ConfettiParticle(index: index)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
            let elapsed = timeline.date.timeIntervalSince(startDate)

            GeometryReader { proxy in
                ZStack {
                    ForEach(particles) { particle in
                        let progress = min(max((elapsed - particle.delay) / duration, 0), 1)

                        if progress > 0 && progress < 1 {
                            RoundedRectangle(cornerRadius: particle.cornerRadius, style: .continuous)
                                .fill(particle.color)
                                .frame(width: particle.width, height: particle.height)
                                .rotationEffect(.degrees(particle.rotation + (progress * particle.spin)))
                                .offset(
                                    x: (proxy.size.width * particle.startX) + sin(progress * .pi * 2 * particle.waveFrequency) * particle.waveAmplitude - (proxy.size.width / 2),
                                    y: (-40 + (proxy.size.height * 0.72 * progress) + (progress * particle.extraFall)) - (proxy.size.height / 2)
                                )
                                .opacity(1 - progress)
                                .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onAppear {
            startDate = .now
        }
        .onChange(of: trigger, initial: false) { _, _ in
            startDate = .now
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id: Int
    let startX: CGFloat
    let delay: Double
    let width: CGFloat
    let height: CGFloat
    let cornerRadius: CGFloat
    let rotation: Double
    let spin: Double
    let waveAmplitude: CGFloat
    let waveFrequency: CGFloat
    let extraFall: CGFloat
    let color: Color

    init(index: Int) {
        let palette: [Color] = [
            Color(red: 0.99, green: 0.80, blue: 0.41),
            Color(red: 0.99, green: 0.57, blue: 0.76),
            Color(red: 0.53, green: 0.78, blue: 0.99),
            Color(red: 0.54, green: 0.88, blue: 0.70),
            Color(red: 0.75, green: 0.48, blue: 0.98)
        ]

        id = index
        startX = 0.08 + CGFloat((index * 11) % 84) / 100
        delay = Double(index % 6) * 0.04
        width = index.isMultiple(of: 3) ? 8 : 10
        height = index.isMultiple(of: 2) ? 14 : 18
        cornerRadius = index.isMultiple(of: 4) ? 6 : 3
        rotation = Double((index * 19) % 120)
        spin = Double(180 + ((index * 31) % 220))
        waveAmplitude = CGFloat(8 + ((index * 7) % 18))
        waveFrequency = CGFloat(1 + ((index * 3) % 3))
        extraFall = CGFloat(30 + ((index * 13) % 70))
        color = palette[index % palette.count]
    }
}

#Preview {
    AchievementsView()
        .environmentObject(AppState())
}
