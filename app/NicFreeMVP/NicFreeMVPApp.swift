import SwiftUI

@main
struct NicFreeMVPApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            Group {
                if appState.onboardingCompleted {
                    RootTabView()
                } else {
                    OnboardingView()
                }
            }
            .environmentObject(appState)
        }
    }
}
