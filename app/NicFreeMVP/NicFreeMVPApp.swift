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
    @StateObject private var notificationManager: LocalNotificationManager
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

        Purchases.logLevel = .debug

        let revenueCatAPIKey = (Bundle.main.object(forInfoDictionaryKey: "REVENUECAT_API_KEY") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        let revenueCatIsConfigured: Bool

        if let revenueCatAPIKey, !revenueCatAPIKey.isEmpty {
            Purchases.configure(withAPIKey: revenueCatAPIKey)
            revenueCatIsConfigured = true
        } else {
            revenueCatIsConfigured = false
            NSLog("[RevenueCat] Missing REVENUECAT_API_KEY in Info.plist. Falling back to free access.")
        }

        let analyticsService = AnalyticsService.makeLive()
        _appState = StateObject(wrappedValue: AppState())
        _onboardingManager = StateObject(wrappedValue: OnboardingManager())
        _themeManager = StateObject(wrappedValue: ThemeManager())
        _subscriptionManager = StateObject(
            wrappedValue: SubscriptionManager(
                analytics: analyticsService,
                revenueCatIsConfigured: revenueCatIsConfigured
            )
        )
        _notificationManager = StateObject(wrappedValue: LocalNotificationManager.shared)
        _analytics = StateObject(wrappedValue: analyticsService)
        _authManager = StateObject(wrappedValue: AuthManager())
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                Group {
                    if appState.hasCompletedOnboarding {
                        RootTabView()
                            .preferredColorScheme(themeManager.preferredColorScheme)
                    } else {
                        OnboardingView()
                            .preferredColorScheme(.light)
                    }
                }

                if appState.hasCompletedOnboarding && subscriptionManager.isAccessLoading {
                    AccessSyncOverlay {
                        Task {
                            await subscriptionManager.refreshCustomerInfo()
                        }
                    }
                }
            }
            .id(appState.hasCompletedOnboarding)
            .environmentObject(appState)
            .environmentObject(onboardingManager)
            .environmentObject(themeManager)
            .environmentObject(subscriptionManager)
            .environmentObject(notificationManager)
            .environmentObject(analytics)
            .environmentObject(authManager)
            .rewardToast(appState.rewardToast)
            .onOpenURL { url in
                // onOpenURL handles normal incoming URLs, including custom URL schemes.
                // Some auth callbacks arrive this way, so we pass them through the same AuthManager entry point.
                Task {
                    await authManager.handleIncomingEmailLink(url)
                }
            }
            .onContinueUserActivity(NSUserActivityTypeBrowsingWeb) { userActivity in
                // Universal links from Firebase Hosting usually arrive as browsing web activities on iOS,
                // not as plain URLs. This is the common path when a user taps the email link from Mail or Safari.
                guard let incomingURL = userActivity.webpageURL else { return }

                Task {
                    await authManager.handleIncomingEmailLink(incomingURL)
                }
            }
            .task {
                analytics.trackAppOpenedIfNeeded()
                subscriptionManager.start()
                authManager.start()
                await notificationManager.refreshSchedules(appState: appState)
            }
            .onChange(of: appState.smokeFreeStreakState) { _ in
                Task {
                    await notificationManager.refreshSchedules(appState: appState)
                }
            }
            .onChange(of: appState.didSmokeFreeCheckInToday) { _ in
                Task {
                    await notificationManager.refreshSchedules(appState: appState)
                }
            }
        }
    }
}

private struct AccessSyncOverlay: View {
    let retryAction: () -> Void

    var body: some View {
        ZStack {
            Color.appBackgroundTop.opacity(0.92)
                .ignoresSafeArea()

            VStack(spacing: 18) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(Color.buttonBottom)
                    .scaleEffect(1.15)

                VStack(spacing: 8) {
                    Text("Your access is updating.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text("Please give us a moment to confirm your plan.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                }

                Button("Try again", action: retryAction)
                    .buttonStyle(SecondaryButtonStyle())
            }
            .padding(28)
            .frame(maxWidth: 340)
            .background(Color.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(Color.border, lineWidth: 1)
            )
            .padding(24)
        }
    }
}
