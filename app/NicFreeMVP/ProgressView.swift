import SwiftUI

struct ProgressView: View {
    @EnvironmentObject private var appState: AppState

    private var milestones: [Milestone] {
        [
            Milestone(title: "First Day", currentValue: appState.nicotineFreeDays, target: 1),
            Milestone(title: "One Week", currentValue: appState.nicotineFreeDays, target: 7),
            Milestone(title: "Ten Cravings", currentValue: appState.cravingsDefeated, target: 10),
            Milestone(title: "Two Weeks", currentValue: appState.nicotineFreeDays, target: 14)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ScreenHeader(
                            eyebrow: "Momentum",
                            title: "Progress worth seeing.",
                            subtitle: "A simple view of your streak, the cravings you’ve moved through, and the milestones coming into reach."
                        )

                        HStack(spacing: 16) {
                            StatCard(
                                title: "Current streak",
                                value: "\(appState.nicotineFreeDays) days",
                                symbol: "calendar"
                            )
                            StatCard(
                                title: "Cravings defeated",
                                value: "\(appState.cravingsDefeated)",
                                symbol: "bolt.shield"
                            )
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("Insights")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                InsightRow(
                                    title: "Most common trigger",
                                    value: appState.mostCommonTriggerTitle
                                )
                                InsightRow(
                                    title: "Cravings this week",
                                    value: "\(appState.cravingsThisWeek)"
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
                                    value: appState.averageCravingIntensityThisWeekText
                                )
                            }
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                Text("This Week")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                InsightRow(
                                    title: "Cravings survived this week",
                                    value: appState.weeklyCravingsSurvivedText
                                )
                                InsightRow(
                                    title: "Strongest trigger this week",
                                    value: appState.strongestTriggerThisWeekText
                                )
                                InsightRow(
                                    title: "Average craving intensity",
                                    value: appState.weeklyAverageIntensityText
                                )
                            }
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                HStack {
                                    Text("Milestones")
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

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.95), Color(red: 0.96, green: 0.95, blue: 0.92)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Keep going gently.")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text("Consistency matters more than intensity. Every craving you outlast makes the next one easier to face.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)
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

private struct Milestone: Identifiable {
    let id = UUID()
    let title: String
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
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(milestone.isComplete ? Color.greenBadge : Color.pendingBadge)
                    .frame(width: 48, height: 48)

                Image(systemName: milestone.isComplete ? "checkmark" : "sparkles")
                    .font(.headline.weight(.bold))
                    .foregroundStyle(milestone.isComplete ? Color.greenBadgeText : Color.pendingBadgeText)
            }

            VStack(alignment: .leading, spacing: 5) {
                Text(milestone.title)
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                Text(milestone.progressText)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
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
        .background(Color.white.opacity(0.7))
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

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
