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
                            eyebrow: "Daily Reset",
                            title: "You are doing beautifully.",
                            subtitle: "A calm snapshot of your quit progress, with one place to go when a craving arrives."
                        )

                        HeroCard(days: appState.nicotineFreeDays)

                        HStack(alignment: .top, spacing: 16) {
                            StatCard(
                                title: "Money saved",
                                value: appState.moneySaved.formatted(.currency(code: "USD")),
                                symbol: "dollarsign"
                            )
                            StatCard(
                                title: "Cravings defeated",
                                value: "\(appState.cravingsDefeated)",
                                symbol: "bolt.heart"
                            )
                        }

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

                        Button {
                            showingSlipFlow = true
                        } label: {
                            Text("I slipped")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white.opacity(0.64))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                                        .stroke(Color.white.opacity(0.65), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.white.opacity(0.96), Color(red: 0.95, green: 0.97, blue: 0.95)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(spacing: 10) {
                                    Image(systemName: "heart.text.square.fill")
                                        .font(.title3)
                                        .foregroundStyle(Color.heroAccent)

                                    Text("Support for this moment")
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(Color.ink)
                                }

                                Text("Cravings are temporary. Give yourself one soft minute, let the wave pass, and come back to your day.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                Text(appState.dynamicMotivation)
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(Color.ink.opacity(0.72))
                                    .lineSpacing(3)

                                Text(appState.highlightedQuitReason.map { "For: \($0)" } ?? "Add a personal quit reason in Settings to make this support feel more personal.")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.heroAccent)
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
            return "No check-in yet today."
        }

        return "Latest check-in: \(latest.cravingLevel.title)"
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
