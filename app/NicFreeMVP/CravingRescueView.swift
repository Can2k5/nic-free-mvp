import SwiftUI

struct CravingRescueView: View {
    private enum Phase {
        case timer
        case reflection
    }

    @EnvironmentObject private var appState: AppState
    @Binding var selectedTab: RootTabView.Tab
    @State private var secondsRemaining: Int = 60
    @State private var timerActive = false
    @State private var sessionStarted = false
    @State private var phase: Phase = .timer
    @State private var selectedIntensity: Int = 3
    @State private var selectedTrigger: CravingTrigger?
    @State private var handledSessionID: UUID?

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                VStack(spacing: 24) {
                    if phase == .timer {
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

                                    VStack(spacing: 4) {
                                        Text("Remember why you started")
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.heroAccent)

                                        Text(appState.highlightedQuitReason ?? "Add a personal reason in Settings to bring more support into this moment.")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondaryText)
                                            .multilineTextAlignment(.center)
                                    }
                                    .padding(.top, 8)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 12)
                                    .glassPanel(cornerRadius: 18, tint: Color.white, tintOpacity: 0.14, shadowOpacity: 0.04)
                                }
                                .padding(.horizontal, 10)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        if !sessionStarted {
                            Button {
                                sessionStarted = true
                                timerActive = true
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "play.fill")
                                        .font(.headline)
                                    Text("Start the minute")
                                        .font(.headline)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                            }
                            .buttonStyle(PrimaryButtonStyle())

                            Text("Start when you're ready. The timer begins only after you press the button.")
                                .font(.footnote)
                                .foregroundStyle(Color.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        } else {
                            Button {
                                phase = .reflection
                                timerActive = false
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

                            Text(secondsRemaining > 0 ? "The button becomes available once the full minute has passed." : "You did it. Tap to log what this craving felt like.")
                                .font(.footnote)
                                .foregroundStyle(Color.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 16)
                        }

                        Spacer()
                    } else {
                        reflectionContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 28)
            }
            .toolbar(.hidden, for: .navigationBar)
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
            }
        }
    }

    private var reflectionContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 18) {
                ScreenHeader(
                    eyebrow: "Post-Craving",
                    title: "You got through it.",
                    subtitle: "Capture a quick note so the app can learn what tends to show up for you."
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

                Button {
                    guard let selectedTrigger else { return }
                    appState.saveCravingEvent(
                        intensity: selectedIntensity,
                        trigger: selectedTrigger,
                        succeeded: true
                    )
                    resetFlow()
                    selectedTab = .home
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.headline)
                        Text("Save craving")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                }
                .buttonStyle(PrimaryButtonStyle(isEnabled: selectedTrigger != nil))
                .disabled(selectedTrigger == nil)

                Text("This adds the event to your local progress history and updates your survived cravings.")
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }
        }
    }

    private func resetFlow(startTimer: Bool = false) {
        secondsRemaining = 60
        timerActive = startTimer
        sessionStarted = startTimer
        phase = .timer
        selectedIntensity = 3
        selectedTrigger = nil
    }

    private func startSessionIfNeeded() {
        guard handledSessionID != appState.activeRescueSessionID else { return }
        handledSessionID = appState.activeRescueSessionID
        resetFlow(startTimer: false)
    }
}

#Preview {
    CravingRescueView(selectedTab: .constant(.rescue))
        .environmentObject(AppState())
}
