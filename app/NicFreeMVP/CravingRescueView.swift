import SwiftUI

struct CravingRescueView: View {
    private enum Phase {
        case timer
        case success
        case reflection
    }

    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab
    let startInReflection: Bool
    @State private var secondsRemaining: Int = 90
    @State private var timerActive = false
    @State private var sessionStarted = false
    @State private var phase: Phase = .timer
    @State private var selectedIntensity: Int = 3
    @State private var selectedTrigger: CravingTrigger?
    @State private var handledSessionID: UUID?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(selectedTab: Binding<RootTabView.Tab>, startInReflection: Bool = false) {
        self._selectedTab = selectedTab
        self.startInReflection = startInReflection
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    if phase == .timer {
                        timerContent
                    } else if phase == .success {
                        successContent
                    } else {
                        reflectionContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onReceive(timer) { _ in
            guard phase == .timer, timerActive, secondsRemaining > 0 else { return }
            secondsRemaining -= 1
            if secondsRemaining == 0 {
                timerActive = false
            }
        }
        .onChange(of: appState.activeRescueSessionID) { _ in
            startSessionIfNeeded()
        }
        .onAppear {
            startSessionIfNeeded()
            if startInReflection {
                phase = .reflection
            }
        }
    }

    private var timerContent: some View {
        VStack(spacing: 24) {
            ScreenHeader(
                eyebrow: "Wait It Out",
                title: "Do not decide right now.",
                subtitle: "Give the urge a moment. Most cravings pass if you do not act immediately."
            )

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
                            .fill(.ultraThinMaterial)
                            .overlay(
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.42),
                                                Color.mist.opacity(0.18)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .frame(width: 232, height: 232)
                            .shadow(color: Color.shadowColor.opacity(0.08), radius: 25, x: 0, y: 14)
                            .overlay(
                                Circle()
                                    .stroke(Color.white.opacity(0.55), lineWidth: 1)
                            )

                        Circle()
                            .stroke(Color.accentWash, lineWidth: 18)
                            .frame(width: 210, height: 210)

                        Circle()
                            .trim(from: 0.06, to: 0.32)
                            .stroke(
                                Color.white.opacity(timerActive ? 0.88 : 0.42),
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .frame(width: 210, height: 210)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: timerActive ? 0.2 : 0.6)

                        VStack(spacing: 8) {
                            Text("90-second hold")
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
                    .scaleEffect(timerActive ? 1.02 : 1)
                    .animation(
                        timerActive
                            ? .easeInOut(duration: 1.5).repeatForever(autoreverses: true)
                            : .easeOut(duration: 0.2),
                        value: timerActive
                    )

                    VStack(spacing: 8) {
                        Text("The urge feels urgent. It is still temporary.")
                            .font(.body.weight(.medium))
                            .multilineTextAlignment(.center)
                            .foregroundStyle(Color.ink)

                        Text("This is a wave. Let it crest and pass.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                    }
                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)
            }

            if !sessionStarted {
                primaryActionButton(title: "Start the 90 seconds", systemImage: "play.fill") {
                    sessionStarted = true
                    timerActive = true
                }

                helperText("You are not deciding forever. You are only giving this urge one short window to pass.")
            } else {
                primaryActionButton(
                    title: "I made it",
                    systemImage: secondsRemaining > 0 ? "moon.zzz.fill" : "checkmark.circle.fill",
                    isEnabled: secondsRemaining == 0
                ) {
                    phase = .success
                    timerActive = false
                }

                helperText(
                    secondsRemaining > 0
                        ? "Stay with the countdown. Every second you do not act weakens the pattern."
                        : "You made it through the wave."
                )
            }
        }
    }

    private var successContent: some View {
        VStack(spacing: 22) {
            rescueSuccessCard(
                eyebrow: "Craving Defeated",
                symbol: "checkmark.circle.fill",
                title: "You got through that wave.",
                subtitle: "That urge did not decide for you."
            )

            primaryActionButton(title: "Continue to reflection", systemImage: "square.and.pencil") {
                phase = .reflection
            }
        }
    }

    private var reflectionContent: some View {
        VStack(spacing: 18) {
            ScreenHeader(
                eyebrow: "Post-Craving",
                title: "You got through it.",
                subtitle: "Log this moment so we can understand your patterns."
            )

            CardSection {
                VStack(alignment: .leading, spacing: 16) {
                    Text("1. How intense was this craving?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    HStack(spacing: 10) {
                        ForEach(1...5, id: \.self) { value in
                            Button {
                                selectedIntensity = value
                            } label: {
                                Text("\(value)")
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(selectedIntensity == value ? Color.white : Color.ink)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                                            .fill(selectedIntensity == value ? Color.buttonBottom : Color.white.opacity(0.75))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            CardSection {
                VStack(alignment: .leading, spacing: 16) {
                    Text("2. What triggered it?")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                        ForEach(CravingTrigger.allCases) { trigger in
                            Button {
                                selectedTrigger = trigger
                            } label: {
                                Text(trigger.title)
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selectedTrigger == trigger ? Color.white : Color.ink)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .padding(.horizontal, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(selectedTrigger == trigger ? Color.buttonBottom : Color.white.opacity(0.75))
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }

            primaryActionButton(title: "Save craving", systemImage: "checkmark.circle.fill", isEnabled: selectedTrigger != nil) {
                guard let selectedTrigger else { return }
                appState.saveCravingEvent(
                    intensity: selectedIntensity,
                    trigger: selectedTrigger,
                    succeeded: true
                )
                resetFlow()
                selectedTab = .home
            }

            helperText("This adds the event to your local progress history and updates your survived cravings.")
        }
    }

    private func primaryActionButton(
        title: String,
        systemImage: String,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: systemImage)
                    .font(.headline)
                Text(title)
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }

    private func helperText(_ text: String) -> some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(Color.secondaryText)
            .multilineTextAlignment(.center)
            .padding(.horizontal, 16)
    }

    private func resetFlow() {
        secondsRemaining = 90
        timerActive = false
        sessionStarted = false
        phase = .timer
        selectedIntensity = 3
        selectedTrigger = nil
    }

    private func startSessionIfNeeded() {
        guard handledSessionID != appState.activeRescueSessionID else { return }
        handledSessionID = appState.activeRescueSessionID
        resetFlow()
        if startInReflection {
            phase = .reflection
        }
    }
}

#Preview {
    NavigationStack {
        CravingRescueView(selectedTab: .constant(.rescue))
            .environmentObject(AppState())
    }
}
