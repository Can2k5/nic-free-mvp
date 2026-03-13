import SwiftUI

struct CravingRescueView: View {
    @EnvironmentObject private var appState: AppState
    @State private var secondsRemaining: Int = 60
    @State private var timerActive = true

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                CardSection {
                    VStack(spacing: 14) {
                        Text("Breathe. This urge will rise and fall.")
                            .font(.title3.weight(.semibold))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.ink)

                        Text("Relax your jaw, drop your shoulders, and stay with this minute.")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.secondaryText)

                        Text("\(secondsRemaining)s")
                            .font(.system(size: 56, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .monospacedDigit()
                    }
                    .frame(maxWidth: .infinity)
                }

                Button {
                    appState.recordCravingVictory()
                    secondsRemaining = 60
                    timerActive = true
                } label: {
                    Text("I made it")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(secondsRemaining > 0)
                .opacity(secondsRemaining > 0 ? 0.45 : 1)

                Text(secondsRemaining > 0 ? "The button unlocks after 60 seconds." : "Nice work. Count this craving as defeated.")
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)

                Spacer()
            }
            .padding(20)
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Craving Rescue")
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
