import SwiftUI

struct CravingInterventionView: View {
    private enum Phase {
        case exercise
        case success
    }

    private enum BreathState {
        case inhale
        case exhale

        var instruction: String {
            switch self {
            case .inhale:
                return "Breathe in"
            case .exhale:
                return "Breathe out"
            }
        }

        var duration: Int {
            switch self {
            case .inhale:
                return 4
            case .exhale:
                return 6
            }
        }

        var scale: CGFloat {
            switch self {
            case .inhale:
                return 1.06
            case .exhale:
                return 0.88
            }
        }
    }

    private enum AlternativeAction: String, CaseIterable, Identifiable {
        case drinkWater
        case walkTwoMinutes
        case delayTheUrge

        var id: String { rawValue }

        var title: String {
            switch self {
            case .drinkWater:
                return "Drink some water"
            case .walkTwoMinutes:
                return "Walk for 2 minutes"
            case .delayTheUrge:
                return "Wait five more minutes"
            }
        }

        var subtitle: String {
            switch self {
            case .drinkWater:
                return "A small reset for your body"
            case .walkTwoMinutes:
                return "A little movement can shift the moment"
            case .delayTheUrge:
                return "A little space can soften the urge"
            }
        }

        var symbol: String {
            switch self {
            case .drinkWater:
                return "drop.fill"
            case .walkTwoMinutes:
                return "figure.walk"
            case .delayTheUrge:
                return "hourglass"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var analytics: AnalyticsService

    @State private var phase: Phase = .exercise
    @State private var breathState: BreathState = .inhale
    @State private var secondsRemainingInPhase = 4
    @State private var completedCycles = 0
    @State private var selectedAction: AlternativeAction?
    @State private var hasCompletedIntervention = false

    private let totalCycles = 5
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if phase == .exercise {
                            exerciseContent
                                .transition(.calmFlow)
                        } else {
                            successContent
                                .transition(.calmSuccess)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                    .animation(MicroAnimation.flow, value: phase)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .onAppear {
            analytics.track(.cravingRescueStarted, properties: ["rescue_type": "breathing"])
            appState.beginCravingSession()
            resetBreathing()
        }
        .onReceive(timer) { _ in
            handleTimerTick()
        }
    }

    private var exerciseContent: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("A craving is here")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)

                Text("You only need to get through this moment.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(Color.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softEntrance(delay: 0.02, distance: 10)

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.98), Color.cardSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(spacing: 22) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.buttonTop.opacity(0.18), Color.buttonBottom.opacity(0.26)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 228, height: 228)
                            .blur(radius: 0.6)

                        Circle()
                            .fill(Color.surfaceElevated)
                            .frame(width: 184, height: 184)
                            .overlay(
                                Circle()
                                    .stroke(Color.border, lineWidth: 1)
                            )
                            .shadow(color: Color.buttonBottom.opacity(0.12), radius: 22, x: 0, y: 14)
                            .scaleEffect(breathState.scale)
                            .animation(.easeInOut(duration: Double(breathState.duration)), value: breathState)

                        VStack(spacing: 8) {
                            Text(breathState.instruction)
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text("\(secondsRemainingInPhase)s")
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(Color.ink)
                        }
                    }

                    VStack(spacing: 6) {
                        Text("Breath \(min(completedCycles + 1, totalCycles)) of \(totalCycles)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("About \(formattedTimeLeft) left")
                            .font(.footnote.weight(.medium))
                            .foregroundStyle(Color.secondaryText)
                            .monospacedDigit()
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .softEntrance(delay: 0.08, distance: 12)

            VStack(alignment: .leading, spacing: 12) {
                Text("A few gentle options")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)

                ForEach(AlternativeAction.allCases) { action in
                    alternativeActionCard(action)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .softEntrance(delay: 0.14, distance: 12, animation: MicroAnimation.supportiveReveal)
        }
    }

    private var successContent: some View {
        VStack(spacing: 22) {
            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.98), Color.accentWash.opacity(0.36)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 42, weight: .semibold))
                        .foregroundStyle(Color.buttonBottom)

                    Text("You stayed with it.")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)

                    Text("The wave eased without taking over.")
                        .font(.title3.weight(.medium))
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)

                    Text("That counts")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.buttonBottom)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.buttonBottom.opacity(0.12))
                        .clipShape(Capsule())
                }
                .frame(maxWidth: .infinity)
            }
            .softEntrance(delay: 0.03, distance: 12, animation: MicroAnimation.success, initialScale: 0.98)

            Button("Back to today") {
                dismiss()
            }
            .buttonStyle(PrimaryButtonStyle())
            .softEntrance(delay: 0.1, distance: 10, animation: MicroAnimation.success, initialScale: 0.985)
        }
    }

    private func alternativeActionCard(_ action: AlternativeAction) -> some View {
        let isSelected = selectedAction == action

        return Button {
            withAnimation(MicroAnimation.selection) {
                selectedAction = action
            }
            OnboardingHaptics.light()
        } label: {
            HStack(spacing: 14) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : action.symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(isSelected ? Color.buttonBottom : Color.secondaryText)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 3) {
                    Text(action.title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text(action.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.surfaceElevated : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.buttonBottom.opacity(0.3) : Color.border, lineWidth: 1)
            )
            .shadow(color: Color.shadowColor.opacity(0.06), radius: 12, x: 0, y: 8)
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var formattedTimeLeft: String {
        let totalSeconds = remainingTotalSeconds
        return String(format: "%d:%02d", totalSeconds / 60, totalSeconds % 60)
    }

    private var remainingTotalSeconds: Int {
        let cyclesLeftAfterCurrent = max(totalCycles - completedCycles - 1, 0)
        let futureCycleSeconds = cyclesLeftAfterCurrent * (BreathState.inhale.duration + BreathState.exhale.duration)
        let currentCycleRemaining = breathState == .inhale
            ? secondsRemainingInPhase + BreathState.exhale.duration
            : secondsRemainingInPhase
        return max(currentCycleRemaining + futureCycleSeconds, 0)
    }

    private func handleTimerTick() {
        guard phase == .exercise, !hasCompletedIntervention else { return }

        if secondsRemainingInPhase > 1 {
            secondsRemainingInPhase -= 1
            return
        }

        switch breathState {
        case .inhale:
            breathState = .exhale
            secondsRemainingInPhase = BreathState.exhale.duration
        case .exhale:
            completedCycles += 1
            if completedCycles >= totalCycles {
                completeIntervention()
            } else {
                breathState = .inhale
                secondsRemainingInPhase = BreathState.inhale.duration
            }
        }
    }

    private func completeIntervention() {
        hasCompletedIntervention = true
        analytics.track(.cravingRescueCompleted, properties: ["rescue_type": "breathing"])
        appState.saveCravingEvent(intensity: 2, trigger: .other, succeeded: true)
        appState.showRewardToast(title: "You stayed with it.", message: "That breath-by-breath pause helped this moment soften.")
        OnboardingHaptics.success()

        withAnimation(MicroAnimation.success) {
            phase = .success
        }
    }

    private func resetBreathing() {
        phase = .exercise
        breathState = .inhale
        secondsRemainingInPhase = BreathState.inhale.duration
        completedCycles = 0
        selectedAction = nil
        hasCompletedIntervention = false
    }
}

#Preview {
    CravingInterventionView()
        .environmentObject(AppState())
}
