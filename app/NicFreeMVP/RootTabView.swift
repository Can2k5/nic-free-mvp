import SwiftUI
import UIKit

struct RootTabView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @Environment(\.colorScheme) private var colorScheme

    enum Tab {
        case home
        case rescue
        case profile
        case achievements
        case settings
    }

    @State private var selectedTab: Tab = .home

    init() {
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "house")
                }
                .tag(Tab.home)

            RescueOptionsView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Rescue", systemImage: "wind")
                }
                .tag(Tab.rescue)

            ProfileView(selectedTab: $selectedTab)
                .tabItem {
                    Label("Progress", systemImage: "person.crop.circle")
                }
                .tag(Tab.profile)

            AchievementsView()
                .tabItem {
                    Label("Markers", systemImage: "rosette")
                }
                .tag(Tab.achievements)

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
        .onAppear {
            configureTabBarAppearance(for: colorScheme)
        }
        .onChange(of: colorScheme, initial: false) { _, newValue in
            configureTabBarAppearance(for: newValue)
        }
        .onChange(of: themeManager.mode, initial: false) { _, _ in
            configureTabBarAppearance(for: colorScheme)
        }
    }

    private func configureTabBarAppearance(for scheme: ColorScheme) {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundEffect = UIBlurEffect(
            style: scheme == .dark ? .systemUltraThinMaterialDark : .systemUltraThinMaterialLight
        )
        appearance.backgroundColor = UIColor(Color.tabBarBackground)
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
}

#Preview {
    RootTabView()
        .environmentObject(AppState())
        .environmentObject(ThemeManager())
}
