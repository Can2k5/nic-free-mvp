import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var appState: AppState

    private var milestones: [Milestone] {
        [
            Milestone(
                title: "First day completed",
                subtitle: "You got through the first full day without nicotine.",
                currentValue: appState.nicotineFreeDays,
                target: 1
            ),
            Milestone(
                title: "One week nicotine-free",
                subtitle: "A full week is often where the quit starts to feel more real.",
                currentValue: appState.nicotineFreeDays,
                target: 7
            ),
            Milestone(
                title: "10 cravings defeated",
                subtitle: "You have already interrupted the urge pattern many times.",
                currentValue: appState.cravingsDefeated,
                target: 10
            ),
            Milestone(
                title: "Two weeks completed",
                subtitle: "Two weeks shows real momentum, not just a good day.",
                currentValue: appState.nicotineFreeDays,
                target: 14
            )
        ]
    }

    private var recoveryMilestones: [RecoveryMilestone] {
        [
            RecoveryMilestone(title: "20 minutes", subtitle: "Heart rate and blood pressure often begin to settle.", daysRequired: 0),
            RecoveryMilestone(title: "8 hours", subtitle: "Oxygen levels often start to improve.", daysRequired: 0),
            RecoveryMilestone(title: "24 hours", subtitle: "Nicotine continues clearing from the body.", daysRequired: 1),
            RecoveryMilestone(title: "1 week", subtitle: "Cravings often begin to feel more manageable.", daysRequired: 7),
            RecoveryMilestone(title: "1 month", subtitle: "Breathing often starts to feel easier.", daysRequired: 30)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ScreenHeader(
                            eyebrow: "Progress",
                            title: "Proof that this is working.",
                            subtitle: "See your quit in numbers, milestones, patterns, and the steady recovery happening underneath it."
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Current progress")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .textCase(.uppercase)
                                .tracking(1.1)

                            HeroProgressCard(
                                days: appState.nicotineFreeDays,
                                cravingsDefeated: appState.cravingsDefeated,
                                moneySaved: appState.moneySaved.formatted(.currency(code: "USD"))
                            )
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    Text("Key achievements")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color.ink)

                                    Spacer()

                                    Text("\(milestones.filter(\.isComplete).count)/\(milestones.count)")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Color.secondaryText)
                                }

                                ForEach(milestones) { milestone in
                                    MilestoneRow(milestone: milestone)
                                }
                            }
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Practical insights")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                if appState.cravingEvents.isEmpty {
                                    EmptyInsightsState(
                                        title: "No cravings logged yet",
                                        subtitle: "Your patterns will appear here over time. Use Rescue and log a craving when you want the app to start learning from the moment."
                                    )
                                } else {
                                    Text("The app is starting to show where cravings tend to come from and how they show up.")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondaryText)
                                        .lineSpacing(4)

                                    InsightRow(
                                        title: "Most common trigger",
                                        value: appState.mostCommonTriggerTitle
                                    )
                                    InsightRow(
                                        title: "Cravings this week",
                                        value: appState.cravingsThisWeek == 0 ? "No data this week" : "\(appState.cravingsThisWeek)"
                                    )
                                    InsightRow(
                                        title: "Total cravings survived",
                                        value: "\(appState.totalCravingsSurvived)"
                                    )
                                    InsightRow(
                                        title: "Most common time of craving",
                                        value: appState.mostCommonTimeOfCravingTitle
                                    )
                                    InsightRow(
                                        title: "Average intensity this week",
                                        value: appState.averageCravingIntensityThisWeekText == "No data yet" ? "No data this week" : appState.averageCravingIntensityThisWeekText
                                    )
                                }
                            }
                        }

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.95), Color(red: 0.96, green: 0.95, blue: 0.92)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Recovery and improvement")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text("These are general recovery milestones that many people notice over time.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                ForEach(recoveryMilestones) { milestone in
                                    RecoveryRow(
                                        milestone: milestone,
                                        currentDays: appState.nicotineFreeDays
                                    )
                                }

                                Text("General recovery milestones, not medical advice.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}

private struct HeroProgressCard: View {
    let days: Int
    let cravingsDefeated: Int
    let moneySaved: String

    var body: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.heroTop, Color.heroBottom],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Nicotine-free")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.heroSecondaryText)
                        .textCase(.uppercase)
                        .tracking(1.2)

                    Text("\(days) days")
                        .font(.system(size: 54, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)

                    Text("This is your current streak and your clearest proof of momentum.")
                        .font(.subheadline)
                        .foregroundStyle(Color.heroSecondaryText)
                        .lineSpacing(3)
                }

                HStack(spacing: 14) {
                    ProgressStatPill(title: "Cravings defeated", value: "\(cravingsDefeated)")
                    ProgressStatPill(title: "Money saved", value: moneySaved)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}

private struct ProgressStatPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.title3.weight(.bold))
                .foregroundStyle(Color.ink)

            Text(title)
                .font(.footnote)
                .foregroundStyle(Color.secondaryText)
                .lineSpacing(2)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }
}

private struct Milestone: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let currentValue: Int
    let target: Int

    var isComplete: Bool {
        currentValue >= target
    }

    var progressText: String {
        isComplete ? "Reached" : "\(currentValue)/\(target)"
    }
}

private struct MilestoneRow: View {
    let milestone: Milestone

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(milestone.isComplete ? Color.greenBadge : Color.pendingBadge)
                    .frame(width: 50, height: 50)

                Image(systemName: milestone.isComplete ? "checkmark" : "sparkles")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(milestone.isComplete ? Color.greenBadgeText : Color.pendingBadgeText)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(milestone.title)
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                Text(milestone.subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(3)

                Text(milestone.progressText)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(milestone.isComplete ? Color.greenBadgeText : Color.pendingBadgeText)
            }

            Spacer()

            Text(milestone.isComplete ? "Done" : "Next")
                .font(.caption.weight(.bold))
                .foregroundStyle(milestone.isComplete ? Color.greenBadgeText : Color.pendingBadgeText)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(milestone.isComplete ? Color.greenBadge : Color.pendingBadge)
                .clipShape(Capsule())
        }
        .padding(16)
        .background(milestone.isComplete ? Color.white.opacity(0.82) : Color.white.opacity(0.62))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct InsightRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            Spacer()

            Text(value)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
        .padding(.vertical, 2)
    }
}

private struct EmptyInsightsState: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundStyle(Color.ink)

            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)
                .lineSpacing(4)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
    }
}

private struct RecoveryMilestone: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let daysRequired: Int
}

private struct RecoveryRow: View {
    let milestone: RecoveryMilestone
    let currentDays: Int

    private var isReached: Bool {
        currentDays >= milestone.daysRequired
    }

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(isReached ? Color.greenBadge : Color.white.opacity(0.55))
                    .frame(width: 34, height: 34)

                Image(systemName: isReached ? "checkmark" : "circle.fill")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isReached ? Color.greenBadgeText : Color.pendingBadgeText)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                Text(milestone.subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(3)
            }

            Spacer()
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
