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
            ScrollView {
                VStack(spacing: 20) {
                    HStack(spacing: 16) {
                        StatCard(title: "Current streak", value: "\(appState.nicotineFreeDays) days")
                        StatCard(title: "Cravings defeated", value: "\(appState.cravingsDefeated)")
                    }

                    CardSection {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Milestones")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            ForEach(milestones) { milestone in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
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
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Progress")
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

#Preview {
    ProgressView()
        .environmentObject(AppState())
}
