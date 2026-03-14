import SwiftUI
import UIKit

struct RootTabView: View {
    enum Tab {
        case home
        case rescue
        case progress
        case settings
    }

    @State private var selectedTab: Tab = .home

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(style: .systemUltraThinMaterialLight)
        appearance.backgroundColor = UIColor.white.withAlphaComponent(0.72)
        appearance.shadowColor = UIColor(Color.shadowColor.opacity(0.12))
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor(Color.ink)
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
            .foregroundColor: UIColor(Color.ink)
        ]
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor(Color.secondaryText)
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
            .foregroundColor: UIColor(Color.secondaryText)
        ]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            CravingRescueView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Rescue", systemImage: "wind")
                }
                .tag(Tab.rescue)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.bar")
                }
                .tag(Tab.progress)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "slider.horizontal.3")
                }
                .tag(Tab.settings)
        }
        .tint(Color.ink)
        .toolbarBackground(.visible, for: .tabBar)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
}
