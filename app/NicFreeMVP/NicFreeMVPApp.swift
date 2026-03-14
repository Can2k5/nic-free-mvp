import SwiftUI

@main
struct NicFreeMVPApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.hasCompletedOnboarding {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            .id(appState.hasCompletedOnboarding)
            .environmentObject(appState)
        }
    }
}
