import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    HeroCard(days: appState.nicotineFreeDays)

                    HStack(spacing: 16) {
                        StatCard(
                            title: "Money saved",
                            value: appState.moneySaved.formatted(.currency(code: "USD"))
                        )
                        StatCard(
                            title: "Cravings defeated",
                            value: "\(appState.cravingsDefeated)"
                        )
                    }

                    CardSection {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("A craving can pass.")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text("Take one calm minute in Craving Rescue when you need support.")
                                .font(.subheadline)
                                .foregroundStyle(Color.secondaryText)

                            Button {
                                selectedTab = .rescue
                            } label: {
                                Text("I have a craving")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    }
                }
                .padding(20)
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("NicFree")
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(.home))
        .environmentObject(AppState())
}
