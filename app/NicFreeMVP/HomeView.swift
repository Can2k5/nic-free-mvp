import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab
    @State private var showingSlipFlow = false

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ScreenHeader(
                            eyebrow: "Home",
                            title: "Your quit, right now.",
                            subtitle: "See your progress, get support fast, and remember why you are staying with it."
                        )

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Get support now")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .textCase(.uppercase)
                                .tracking(1.1)

                            Button {
                                appState.beginCravingSession()
                                selectedTab = .rescue
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "sparkles")
                                        .font(.headline)
                                    Text("I have a craving")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            Text("Get support for this moment.")
                                .font(.footnote)
                                .foregroundStyle(Color.secondaryText)
                                .padding(.horizontal, 4)
                        }

                        VStack(alignment: .leading, spacing: 14) {
                            Text("Progress snapshot")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .textCase(.uppercase)
                                .tracking(1.1)

                            HeroCard(days: appState.nicotineFreeDays)

                            HStack(alignment: .top, spacing: 16) {
                                StatCard(
                                    title: "Cravings defeated",
                                    value: "\(appState.cravingsDefeated)",
                                    symbol: "bolt.heart"
                                )
                                StatCard(
                                    title: "Money saved",
                                    value: appState.moneySaved.formatted(.currency(code: "USD")),
                                    symbol: "dollarsign"
                                )
                            }
                        }

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.96), Color(red: 0.95, green: 0.97, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Keep going")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text(appState.dynamicMotivation)
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

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
                                    .glassPanel(cornerRadius: 20, tint: Color.white, tintOpacity: 0.14, shadowOpacity: 0.04)
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
                                    .glassPanel(cornerRadius: 20, tint: Color.white, tintOpacity: 0.12, shadowOpacity: 0.03)
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
                                    .background(Color.white.opacity(0.56))
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }

                                Button {
                                    showingSlipFlow = true
                                } label: {
                                    Text("I slipped")
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(Color.secondaryText)
                                }
                                .buttonStyle(.plain)
                            }
                        }

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
                                                        .fill(appState.latestCheckin?.cravingLevel == level ? Color.buttonBottom : Color.white.opacity(0.74))
                                                )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }

                                Text(latestCheckinText)
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
            .sheet(isPresented: $showingSlipFlow) {
                SlipRecoveryFlowView()
                    .environmentObject(appState)
            }
        }
    }

    private var latestCheckinText: String {
        guard let latest = appState.latestCheckin else {
            return "No check-in yet today. A quick check-in helps the app understand how cravings are showing up."
        }

        return "Latest check-in: \(latest.cravingLevel.title)"
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
