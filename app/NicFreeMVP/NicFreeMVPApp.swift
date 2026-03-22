import SwiftUI
import RevenueCat

@main
struct AyoMVPApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var onboardingManager = OnboardingManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var subscriptionManager = SubscriptionManager()

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "test_eurzmiwsmfEhMemMlWsqmdUcYos")
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    RootTabView()
                        .preferredColorScheme(themeManager.preferredColorScheme)
                } else {
                    OnboardingView()
                        .preferredColorScheme(.light)
                }
            }
            .id(appState.hasCompletedOnboarding)
            .environmentObject(appState)
            .environmentObject(onboardingManager)
            .environmentObject(themeManager)
            .environmentObject(subscriptionManager)
            .rewardToast(appState.rewardToast)
            .task {
                subscriptionManager.start()
            }
        }
    }
}
