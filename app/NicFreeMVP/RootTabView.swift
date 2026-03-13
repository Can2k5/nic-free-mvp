import SwiftUI

struct RootTabView: View {
    enum Tab {
        case home
        case rescue
        case progress
    }

    @State private var selectedTab: Tab = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            CravingRescueView()
                .tabItem {
                    Label("Rescue", systemImage: "wind")
                }
                .tag(Tab.rescue)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
                .tag(Tab.progress)
        }
        .tint(Color.ink)
        .toolbarBackground(Color.white.opacity(0.95), for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
}
