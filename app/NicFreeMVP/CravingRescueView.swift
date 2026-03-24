import SwiftUI

struct CravingRescueView: View {
    private enum Phase {
        case timer
        case success
        case reflection
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var analytics: AnalyticsService
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
                            .transition(.calmFlow)
                            .zIndex(1)
                    } else if phase == .success {
                        successContent
                            .transition(.calmSuccess)
                            .zIndex(2)
                    } else {
                        reflectionContent
                            .transition(.calmFlow)
                            .zIndex(1)
                    }
                }
                .animation(MicroAnimation.flow, value: phase)
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
            analytics.track(.cravingRescueStarted, properties: ["rescue_type": "timer"])
            startSessionIfNeeded()
            if startInReflection {
                phase = .reflection
            }
        }
    }

    private var timerContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Ride It Out")
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.secondaryText)

                ConversationalRevealText(
                    text: "You do not need to decide right now.",
                    startDelay: 0.18,
                    chunkDelay: 0.95,
                    chunking: .phrases,
                    style: .headline
                )

                ConversationalRevealText(
                    text: "Give the urge a little room. Most cravings ease when you do not act on them right away.",
                    startDelay: 0.95,
                    chunkDelay: 1.05,
                    chunking: .sentences,
                    style: .init(
                        font: .subheadline,
                        finalColor: Color.secondaryText,
                        mutedColor: Color.secondaryText,
                        lineSpacing: 3,
                        initialOpacity: 0.12,
                        animation: .easeOut(duration: 0.5)
                    )
                )
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softEntrance(delay: 0.02, distance: 10)

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [
                        Color.cardBackground.opacity(0.98),
                        Color.cardSecondary
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
                                                Color.surfaceElevated.opacity(0.62),
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
                                    .stroke(Color.border, lineWidth: 1)
                            )

                        Circle()
                            .stroke(Color.accentWash, lineWidth: 18)
                            .frame(width: 210, height: 210)

                        Circle()
                            .trim(from: 0.06, to: 0.32)
                            .stroke(
                                Color.cardBackground.opacity(timerActive ? 0.92 : 0.42),
                                style: StrokeStyle(lineWidth: 7, lineCap: .round)
                            )
                            .frame(width: 210, height: 210)
                            .rotationEffect(.degrees(-90))
                            .blur(radius: timerActive ? 0.2 : 0.6)

                        VStack(spacing: 8) {
                            Text("90-second pause")
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
                        ConversationalRevealText(
                            text: "This feels urgent. It is still temporary.",
                            startDelay: 0.35,
                            chunkDelay: 0.95,
                            chunking: .sentences,
                            style: .init(
                                font: .body.weight(.medium),
                                finalColor: Color.ink,
                                mutedColor: Color.secondaryText,
                                lineSpacing: 4,
                                initialOpacity: 0.1,
                                animation: .easeOut(duration: 0.48)
                            )
                        )
                        .multilineTextAlignment(.center)

                        Text("Let the wave rise, then pass.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                    }
                    .padding(.horizontal, 10)
                }
                .frame(maxWidth: .infinity)
            }
            .softEntrance(delay: 0.1, distance: 12)

            if !sessionStarted {
                primaryActionButton(title: "Start the 90-second pause", systemImage: "play.fill") {
                    sessionStarted = true
                    timerActive = true
                }

                helperText("You are not making a forever decision. You are just giving this moment a little space.")
                    .softEntrance(delay: 0.18, distance: 10, animation: MicroAnimation.supportiveReveal)
            } else {
                primaryActionButton(
                    title: "I’m still with it",
                    systemImage: secondsRemaining > 0 ? "moon.zzz.fill" : "checkmark.circle.fill",
                    isEnabled: secondsRemaining == 0
                ) {
                    withAnimation(MicroAnimation.success) {
                        phase = .success
                        timerActive = false
                    }
                }

                helperText(
                    secondsRemaining > 0
                        ? "Stay with the countdown. Each second creates a little more space."
                        : "You made it through the strongest part."
                )
                .softEntrance(delay: 0.1, distance: 10, animation: MicroAnimation.supportiveReveal)
            }
        }
    }

    private var successContent: some View {
        VStack(spacing: 22) {
            rescueSuccessCard(
                eyebrow: "That Counts",
                symbol: "checkmark.circle.fill",
                title: "You stayed with it.",
                subtitle: "That moment eased without taking over."
            )
            .softEntrance(delay: 0.03, distance: 14, animation: MicroAnimation.success, initialScale: 0.97)

            primaryActionButton(title: "Let this moment count", systemImage: "square.and.pencil") {
                withAnimation(MicroAnimation.flow) {
                    phase = .reflection
                }
            }
            .softEntrance(delay: 0.08, distance: 12, animation: MicroAnimation.success, initialScale: 0.985)
        }
        .transition(.calmSuccess)
    }

    private var reflectionContent: some View {
        VStack(spacing: 18) {
            ScreenHeader(
                eyebrow: "After The Urge",
                title: "You stayed with it.",
                subtitle: "A quick note now helps this feel clearer later."
            )
            .softEntrance(delay: 0.02, distance: 10)

            CardSection {
                VStack(alignment: .leading, spacing: 16) {
                    Text("How strong did it feel?")
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
                                            .fill(selectedIntensity == value ? Color.buttonBottom : Color.surfaceElevated)
                                    )
                            }
                            .buttonStyle(SelectableButtonStyle(isSelected: selectedIntensity == value))
                        }
                    }
                }
            }
            .softEntrance(delay: 0.1, distance: 12)

            CardSection {
                VStack(alignment: .leading, spacing: 16) {
                    Text("What seems to have set it off?")
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
                                            .fill(selectedTrigger == trigger ? Color.buttonBottom : Color.surfaceElevated)
                                    )
                            }
                            .buttonStyle(SelectableButtonStyle(isSelected: selectedTrigger == trigger))
                        }
                    }
                }
            }
            .softEntrance(delay: 0.16, distance: 12)

            primaryActionButton(title: "Save and keep going", systemImage: "checkmark.circle.fill", isEnabled: selectedTrigger != nil) {
                guard let selectedTrigger else { return }
                analytics.track(
                    .cravingRescueCompleted,
                    properties: [
                        "rescue_type": "timer",
                        "trigger": selectedTrigger.rawValue,
                        "intensity": selectedIntensity
                    ]
                )
                appState.saveCravingEvent(
                    intensity: selectedIntensity,
                    trigger: selectedTrigger,
                    succeeded: true
                )
                OnboardingHaptics.success()
                appState.showRewardToast(
                    title: "You stayed with it.",
                    message: "That moment now counts toward the progress you are building."
                )
                withAnimation(MicroAnimation.success) {
                    resetFlow()
                    selectedTab = .home
                }
            }
            .softEntrance(delay: 0.22, distance: 10)

            helperText("This helps the app learn your patterns and keeps your progress up to date.")
                .softEntrance(delay: 0.26, distance: 10, animation: MicroAnimation.supportiveReveal)
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
