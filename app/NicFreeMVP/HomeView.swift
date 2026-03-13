import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab

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

                                Text("The goal is not perfection. It is getting through the next minute with care.")
                                    .font(.footnote.weight(.medium))
                                    .foregroundStyle(Color.ink.opacity(0.72))
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

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
