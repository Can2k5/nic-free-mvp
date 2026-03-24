import SwiftUI
import FirebaseCore
import FirebaseAuth
import RevenueCat

@main
struct AyoMVPApp: App {
    @StateObject private var appState: AppState
    @StateObject private var onboardingManager: OnboardingManager
    @StateObject private var themeManager: ThemeManager
    @StateObject private var subscriptionManager: SubscriptionManager
    @StateObject private var analytics: AnalyticsService
    @StateObject private var authManager: AuthManager

    init() {
        // Firebase starts here when the app launches.
        // This reads the existing GoogleService-Info.plist that is already in the app target.
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }

        // FirebaseAuth is the app's identity layer.
        // Apple, Google, and Email Link sign-in all feed into this same Firebase Auth session.
        _ = Auth.auth()

        let analyticsService = AnalyticsService.makeLive()
        _appState = StateObject(wrappedValue: AppState())
        _onboardingManager = StateObject(wrappedValue: OnboardingManager())
        _themeManager = StateObject(wrappedValue: ThemeManager())
        _subscriptionManager = StateObject(wrappedValue: SubscriptionManager(analytics: analyticsService))
        _analytics = StateObject(wrappedValue: analyticsService)
        _authManager = StateObject(wrappedValue: AuthManager())

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
            .environmentObject(analytics)
            .environmentObject(authManager)
            .rewardToast(appState.rewardToast)
            .onOpenURL { url in
                // Firebase email link sign-in comes back into the app through an incoming URL.
                // AuthManager checks whether that URL is a Firebase email sign-in link and, if it is,
                // completes sign-in with the email address that was saved locally when the link was sent.
                Task {
                    await authManager.handleIncomingEmailLink(url)
                }
            }
            .task {
                analytics.trackAppOpenedIfNeeded()
                subscriptionManager.start()
                authManager.start()
            }
        }
    }
}
