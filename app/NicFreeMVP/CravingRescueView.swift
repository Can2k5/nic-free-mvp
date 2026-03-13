import SwiftUI

struct CravingRescueView: View {
    @EnvironmentObject private var appState: AppState
    @State private var secondsRemaining: Int = 60
    @State private var timerActive = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 24) {
                    ScreenHeader(
                        eyebrow: "Support Mode",
                        title: "Stay with this minute.",
                        subtitle: "Slow your breath, soften your body, and let the urge move through without rushing it."
                    )

                    Spacer(minLength: 10)

                    CardSection(fill: AnyShapeStyle(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.95),
                                Color(red: 0.90, green: 0.94, blue: 0.95)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )) {
                        VStack(spacing: 22) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.82))
                                    .frame(width: 232, height: 232)
                                    .shadow(color: Color.shadowColor.opacity(0.08), radius: 25, x: 0, y: 14)

                                Circle()
                                    .stroke(Color.accentWash, lineWidth: 18)
                                    .frame(width: 210, height: 210)

                                VStack(spacing: 8) {
                                    Text("Breathe in. Breathe out.")
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(Color.secondaryText)

                                    Text("\(secondsRemaining)")
                                        .font(.system(size: 72, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.ink)
                                        .monospacedDigit()

                                    Text("seconds")
                                        .font(.footnote.weight(.semibold))
                                        .foregroundStyle(Color.secondaryText)
                                        .textCase(.uppercase)
                                        .tracking(1.2)
                                }
                            }

                            VStack(spacing: 8) {
                                Text("Drop your shoulders. Unclench your jaw. Let the feeling crest and pass.")
                                    .font(.body.weight(.medium))
                                    .multilineTextAlignment(.center)
                                    .foregroundStyle(Color.ink)

                                Text("You only need to get through this one minute.")
                                    .font(.footnote)
                                    .foregroundStyle(Color.secondaryText)
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(maxWidth: .infinity)
                    }

                    Button {
                        appState.recordCravingVictory()
                        secondsRemaining = 60
                        timerActive = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: secondsRemaining > 0 ? "moon.zzz.fill" : "checkmark.circle.fill")
                                .font(.headline)
                            Text("I made it")
                                .font(.headline)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                    }
                    .buttonStyle(PrimaryButtonStyle(isEnabled: secondsRemaining == 0))
                    .disabled(secondsRemaining > 0)

                    Text(secondsRemaining > 0 ? "The button becomes available once the full minute has passed." : "You did it. Tap to count this craving as defeated and begin fresh.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onReceive(timer) { _ in
                guard timerActive, secondsRemaining > 0 else { return }
                secondsRemaining -= 1
                if secondsRemaining == 0 {
                    timerActive = false
                }
            }
        }
    }
}

#Preview {
    CravingRescueView()
        .environmentObject(AppState())
}
