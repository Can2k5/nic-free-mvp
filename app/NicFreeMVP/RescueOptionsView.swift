import SwiftUI

struct RescueOptionsView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: AppSpacing.section + 4) {
                        rescueHeader
                            .softEntrance(delay: 0.02, distance: 14)

                        rescuePrimaryRecommendation
                            .softEntrance(delay: 0.08, distance: 18, initialScale: 0.968)

                        rescueAlternativesSection
                            .softEntrance(delay: 0.16, distance: 18, initialScale: 0.968)

                        rescueFooterGuidance
                            .softEntrance(delay: 0.24, distance: 14, animation: MicroAnimation.supportiveReveal, initialScale: 0.976)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var latestCheckinIsToday: Bool {
        guard let latestCheckin = appState.latestCheckin else { return false }
        return Calendar.current.isDateInToday(latestCheckin.date)
    }

    private var hasRecentSlip: Bool {
        appState.slipEvents.contains { Calendar.current.isDate($0.timestamp, inSameDayAs: .now) }
    }

    private var rescueHeader: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            Text("Rescue")
                .font(.caption.weight(.semibold))
                .tracking(1.1)
                .textCase(.uppercase)
                .foregroundStyle(Color.secondaryText)

            ConversationalRevealText(
                text: "Support for this moment",
                startDelay: 0.2,
                chunkDelay: 1.05,
                chunking: .phrases,
                style: .headline
            )

            Text(headerSupportingLine)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var headerSupportingLine: String {
        if hasRecentSlip {
            return "Start with one steadying step, then choose what helps next."
        }
        if latestCheckinIsToday, appState.latestCheckin?.cravingLevel == .high {
            return "Start with the easiest support path and let the intensity come down a little."
        }
        if !latestCheckinIsToday {
            return "Choose the kind of help that feels easiest to start right now."
        }
        return "Pick the support path that best matches what this moment needs."
    }

    private var primaryRecommendationTitle: String {
        if hasRecentSlip {
            return "Start by steadying the moment"
        }
        if latestCheckinIsToday, appState.latestCheckin?.cravingLevel == .high {
            return "Start here"
        }
        return "A good first step"
    }

    private var primaryRecommendationWhy: String {
        if hasRecentSlip {
            return "A short pause can help you settle before deciding what comes next."
        }
        if latestCheckinIsToday, appState.latestCheckin?.cravingLevel == .high {
            return "This gives you one simple next step when the urge feels loud."
        }
        if !latestCheckinIsToday {
            return "It is a simple place to begin when you want help without overthinking it."
        }
        return "It is a gentle starting point when you want support right away."
    }

    private var alternativesSectionTitle: String {
        if hasRecentSlip {
            return "Or choose what helps you reset the moment"
        }
        if latestCheckinIsToday, appState.latestCheckin?.cravingLevel == .high {
            return "Or choose what fits this urge"
        }
        return "Or choose what fits this moment"
    }

    private var rescueFooterTitle: String {
        if hasRecentSlip {
            return "Different moments need different support"
        }
        return "Choose what fits this moment"
    }

    private var rescueFooterBody: String {
        if hasRecentSlip {
            return "You do not need to fix everything at once. Start with the easiest next step."
        }
        if latestCheckinIsToday, appState.latestCheckin?.cravingLevel == .high {
            return "You do not have to do every step. Start with the one that feels most doable."
        }
        return "Not every craving needs the same response. Start with what feels easiest to do right now."
    }

    private var rescuePrimaryRecommendation: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(primaryRecommendationTitle)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.heroAccent)
                .textCase(.uppercase)
                .tracking(0.9)

            NavigationLink {
                CravingRescueView(selectedTab: $selectedTab)
            } label: {
                RescueOptionEntryCard(
                    title: "Ride it out",
                    subtitle: "Pause for 90 seconds and let the wave pass a little.",
                    symbol: "hourglass",
                    isPrimary: true,
                    supportingText: primaryRecommendationWhy
                )
            }
            .buttonStyle(CardPressButtonStyle())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rescueAlternativesSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text(alternativesSectionTitle)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            VStack(spacing: AppSpacing.md) {
                NavigationLink {
                    CalmDownView(selectedTab: $selectedTab)
                } label: {
                    RescueOptionEntryCard(
                        title: "Settle your body",
                        subtitle: "Lower the intensity before you decide anything.",
                        symbol: "wind",
                        isPrimary: false,
                        supportingText: "A grounding step when your body feels ahead of you."
                    )
                }
                .buttonStyle(CardPressButtonStyle())

                NavigationLink {
                    RememberWhyView()
                } label: {
                    RescueOptionEntryCard(
                        title: "Come back to your reason",
                        subtitle: "Reconnect with what matters more than this moment.",
                        symbol: "heart",
                        isPrimary: false,
                        supportingText: "A helpful choice when you need perspective and steadiness."
                    )
                }
                .buttonStyle(CardPressButtonStyle())

                NavigationLink {
                    ChangeMomentView()
                } label: {
                    RescueOptionEntryCard(
                        title: "Change the moment",
                        subtitle: "Shift the pattern with one small action.",
                        symbol: "bolt",
                        isPrimary: false,
                        supportingText: "A good fit when a quick change in context could help."
                    )
                }
                .buttonStyle(CardPressButtonStyle())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rescueFooterGuidance: some View {
        InsightCard(
            title: rescueFooterTitle,
            subtitle: rescueFooterBody
        ) {
            Text("The best next step is the one that feels easiest to begin.")
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
        }
    }
}

private struct RescueOptionEntryCard: View {
    let title: String
    let subtitle: String
    let symbol: String
    let isPrimary: Bool
    let supportingText: String

    var body: some View {
        ActionCard(
            title: title,
            subtitle: subtitle,
            icon: symbol,
            emphasizesAction: isPrimary
        ) {
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: isPrimary ? "sparkles" : "line.3.horizontal.decrease.circle")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isPrimary ? Color.heroAccent : Color.secondaryText)
                    .padding(.top, 1)

                Text(supportingText)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.ink.opacity(isPrimary ? 0.74 : 0.62))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, isPrimary ? 10 : 8)
            .background(isPrimary ? Color.surfaceMuted : Color.surfaceMuted.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    RescueOptionsView(selectedTab: .constant(.rescue))
}
