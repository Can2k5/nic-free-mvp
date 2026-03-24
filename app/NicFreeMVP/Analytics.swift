import SwiftUI
import PostHog

// MARK: - Analytics vocabulary
//
// Keep event and screen names in one place so they stay consistent.
// This also makes it easier to audit what the app sends.

enum AnalyticsEventName: String {
    case appOpened = "app_opened"
    case onboardingStarted = "onboarding_started"
    case onboardingStepViewed = "onboarding_step_viewed"
    case onboardingCompleted = "onboarding_completed"
    case homeViewed = "home_viewed"
    case cravingRescueStarted = "craving_rescue_started"
    case cravingRescueCompleted = "craving_rescue_completed"
    case paywallViewed = "paywall_viewed"
    case purchaseCompleted = "purchase_completed"
}

// MARK: - Service abstraction

protocol AnalyticsClient {
    func capture(event: AnalyticsEventName, properties: [String: Any])
}

struct NoOpAnalyticsClient: AnalyticsClient {
    func capture(event: AnalyticsEventName, properties: [String: Any]) {}
}

struct PostHogAnalyticsClient: AnalyticsClient {
    init(configuration: AnalyticsConfiguration) {
        let config = PostHogConfig(apiKey: configuration.apiKey, host: configuration.host)
        // Keep PostHog intentionally small and manual.
        //
        // Disabled on purpose:
        // - automatic screen view capture
        // - automatic app lifecycle events
        // - element autocapture
        // - session replay
        // - surveys
        // - feature flag request events
        //
        // This keeps the event stream readable so we only see our own
        // human-named screens and product events.
        config.captureScreenViews = false
        config.captureApplicationLifecycleEvents = false
        config.enableSwizzling = false
        config.sendFeatureFlagEvent = false
        config.preloadFeatureFlags = false
        #if os(iOS) || targetEnvironment(macCatalyst)
        config.captureElementInteractions = false
        #endif
        #if os(iOS)
        config.sessionReplay = false
        if #available(iOS 15.0, *) {
            config.surveys = false
        }
        #endif

        PostHogSDK.shared.setup(config)
    }

    func capture(event: AnalyticsEventName, properties: [String: Any]) {
        PostHogSDK.shared.capture(event.rawValue, properties: properties)
    }
}

struct AnalyticsConfiguration {
    let apiKey: String
    let host: String

    // Set these in Info.plist:
    // - POSTHOG_API_KEY
    // - POSTHOG_HOST
    //
    // If the key is missing or empty, analytics stays disabled and the app
    // still builds and runs normally.
    static func fromBundle() -> AnalyticsConfiguration? {
        guard
            let rawKey = Bundle.main.object(forInfoDictionaryKey: "POSTHOG_API_KEY") as? String,
            !rawKey.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        else {
            return nil
        }

        let rawHost = (Bundle.main.object(forInfoDictionaryKey: "POSTHOG_HOST") as? String)?
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return AnalyticsConfiguration(
            apiKey: rawKey,
            host: (rawHost?.isEmpty == false ? rawHost! : "https://us.i.posthog.com")
        )
    }
}

@MainActor
final class AnalyticsService: ObservableObject {
    private let client: AnalyticsClient
    private var hasTrackedAppOpen = false

    init(client: AnalyticsClient) {
        self.client = client
    }

    static func makeLive() -> AnalyticsService {
        if let configuration = AnalyticsConfiguration.fromBundle() {
            return AnalyticsService(client: PostHogAnalyticsClient(configuration: configuration))
        }

        return AnalyticsService(client: NoOpAnalyticsClient())
    }

    func track(_ event: AnalyticsEventName, properties: [String: Any] = [:]) {
        client.capture(event: event, properties: sanitized(properties))
    }

    func trackAppOpenedIfNeeded() {
        guard !hasTrackedAppOpen else { return }
        hasTrackedAppOpen = true
        track(.appOpened)
    }

    private func sanitized(_ properties: [String: Any]) -> [String: Any] {
        // Keep analytics intentionally small and privacy-conscious.
        // Only simple values should be sent, never raw personal free-text.
        properties.reduce(into: [:]) { partialResult, entry in
            switch entry.value {
            case let value as String:
                partialResult[entry.key] = value
            case let value as Int:
                partialResult[entry.key] = value
            case let value as Double:
                partialResult[entry.key] = value
            case let value as Bool:
                partialResult[entry.key] = value
            default:
                break
            }
        }
    }
}

// MARK: - SwiftUI helpers

private struct AnalyticsEventTrackingModifier: ViewModifier {
    @EnvironmentObject private var analytics: AnalyticsService

    let event: AnalyticsEventName
    let properties: [String: Any]
    @State private var hasTracked = false

    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasTracked else { return }
                hasTracked = true
                analytics.track(event, properties: properties)
            }
    }
}

extension View {
    // Use this to send one intentional custom event on first appearance.
    // This does not send PostHog "Screen" events. It only sends our custom event name.
    func trackAnalyticsEvent(
        _ event: AnalyticsEventName,
        properties: [String: Any] = [:]
    ) -> some View {
        modifier(AnalyticsEventTrackingModifier(event: event, properties: properties))
    }
}

// Anonymous tracking note:
// We do not call identify() yet.
// Until login exists, PostHog will treat each install/device as an anonymous user
// using the SDK's generated distinct ID.
