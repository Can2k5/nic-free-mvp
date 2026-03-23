import SwiftUI

struct CalmDownView: View {
    private enum Phase {
        case content
        case success
    }

    @Binding var selectedTab: RootTabView.Tab
    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .content
    @State private var currentStep = 0

    private let prompts = [
        "Unclench your jaw",
        "Drop your shoulders",
        "Inhale slowly",
        "Exhale longer"
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    if phase == .content {
                        ScreenHeader(
                            eyebrow: "Settle First",
                            title: "Let your body settle first.",
                            subtitle: "You do not need to figure everything out right now. Start by lowering the intensity."
                        )
                        .softEntrance(delay: 0.02, distance: 10)

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.cardBackground.opacity(0.98), Color.mist.opacity(0.42)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(spacing: 18) {
                                VStack(spacing: 12) {
                                    Circle()
                                        .fill(Color.surfaceElevated)
                                        .frame(width: 84, height: 84)
                                        .overlay(
                                            Circle()
                                                .stroke(Color.border, lineWidth: 1)
                                        )
                                        .overlay(
                                            Image(systemName: "wind")
                                                .font(.system(size: 24, weight: .medium))
                                                .foregroundStyle(Color.heroAccent)
                                        )
                                        .scaleEffect(currentStep >= 2 ? 1.04 : 1)
                                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: currentStep >= 2)

                                    Text(prompts[currentStep])
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color.ink)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .glassPanel(cornerRadius: 24, tint: Color.cardBackground, tintOpacity: 0.16, shadowOpacity: 0.05)

                                VStack(spacing: 10) {
                                    ForEach(Array(prompts.enumerated()), id: \.offset) { index, prompt in
                                        HStack(spacing: 12) {
                                            ZStack {
                                                Circle()
                                                    .fill(index <= currentStep ? Color.heroAccent.opacity(0.18) : Color.surfaceMuted)
                                                    .frame(width: 28, height: 28)

                                                Image(systemName: index < currentStep ? "checkmark" : "\(index + 1).circle.fill")
                                                    .font(.footnote.weight(.semibold))
                                                    .foregroundStyle(index <= currentStep ? Color.heroAccent : Color.secondaryText)
                                            }

                                            Text(prompt)
                                                .font(.subheadline.weight(index == currentStep ? .semibold : .medium))
                                                .foregroundStyle(index == currentStep ? Color.ink : Color.secondaryText)

                                            Spacer()
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(index == currentStep ? Color.surfaceElevated : Color.surfaceMuted)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                }
                            }
                        }
                        .softEntrance(delay: 0.1, distance: 12)

                        if currentStep < prompts.count - 1 {
                            Button {
                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                    currentStep += 1
                                }
                            } label: {
                                Text("Next")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        } else {
                            Button {
                                withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                    phase = .success
                                }
                            } label: {
                                Text("I feel calmer")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                            }
                            .buttonStyle(PrimaryButtonStyle())
                        }
                    } else {
                        rescueSuccessCard(
                            eyebrow: "More Steady",
                            symbol: "wind",
                            title: "A calmer body gives you more room.",
                            subtitle: "The urge may still be here, but it does not have the same grip."
                        )
                        .softEntrance(delay: 0.04, distance: 10, animation: MicroAnimation.success, initialScale: 0.985)

                        Button {
                            dismiss()
                        } label: {
                            Text("Back to rescue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .softEntrance(delay: 0.1, distance: 10)

                        NavigationLink {
                            CravingRescueView(selectedTab: $selectedTab)
                        } label: {
                            Text("Log this moment")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.secondaryText)
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        .softEntrance(delay: 0.14, distance: 10)
                    }
                }
                .animation(MicroAnimation.success, value: phase)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear {
            currentStep = 0
        }
    }
}

struct RememberWhyView: View {
    private enum Phase {
        case content
        case success
    }

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .content

    private var primaryReason: String? {
        appState.quitReasons.first
    }

    private var supportingReasons: [String] {
        Array(appState.quitReasons.dropFirst())
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    if phase == .content {
                        ScreenHeader(
                            eyebrow: "Your Reason",
                            title: "Come back to what matters.",
                            subtitle: "You chose this for a reason. Let that reason feel closer than the urge."
                        )
                        .softEntrance(delay: 0.02, distance: 10)

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.cardBackground.opacity(0.98), Color.heroTop.opacity(0.78)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 16) {
                                if appState.quitReasons.isEmpty {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("Your reasons will show up here.")
                                            .font(.system(size: 28, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.ink)

                                        Text("Add one in onboarding or settings, and this space will become more personal.")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.secondaryText)
                                            .lineSpacing(4)

                                        Text("That way it’s ready when a hard moment hits.")
                                            .font(.footnote.weight(.medium))
                                            .foregroundStyle(Color.secondaryText)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(20)
                                    .glassPanel(cornerRadius: 24, tint: Color.cardBackground, tintOpacity: 0.14, shadowOpacity: 0.04)
                                } else {
                                    if let primaryReason {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("Come back to this")
                                                .font(.footnote.weight(.semibold))
                                                .foregroundStyle(Color.heroAccent)
                                                .textCase(.uppercase)
                                                .tracking(1.2)

                                            Text(primaryReason)
                                                .font(.system(size: 38, weight: .bold, design: .rounded))
                                                .foregroundStyle(Color.ink)
                                                .fixedSize(horizontal: false, vertical: true)

                                            Text("This matters more than what the urge is asking for right now.")
                                                .font(.body.weight(.medium))
                                                .foregroundStyle(Color.secondaryText)
                                                .lineSpacing(4)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(20)
                                        .glassPanel(cornerRadius: 24, tint: Color.cardBackground, tintOpacity: 0.16, shadowOpacity: 0.05)
                                    }

                                    if !supportingReasons.isEmpty {
                                        VStack(alignment: .leading, spacing: 12) {
                                            Text("Also for")
                                                .font(.footnote.weight(.semibold))
                                                .foregroundStyle(Color.secondaryText)

                                            ForEach(supportingReasons, id: \.self) { reason in
                                                Text(reason)
                                                    .font(.title3.weight(.semibold))
                                                    .foregroundStyle(Color.ink)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding(.horizontal, 16)
                                                    .padding(.vertical, 14)
                                                    .background(Color.surfaceMuted)
                                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .softEntrance(delay: 0.1, distance: 12)

                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                phase = .success
                            }
                        } label: {
                            Text("Keep going")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    } else {
                        rescueSuccessCard(
                            eyebrow: "Back With Yourself",
                            symbol: "heart.fill",
                            title: "Your reason is still here.",
                            subtitle: "This urge is temporary. What matters to you is still bigger."
                        )
                        .softEntrance(delay: 0.04, distance: 10, animation: MicroAnimation.success, initialScale: 0.985)

                        Button {
                            dismiss()
                        } label: {
                            Text("Back to rescue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .softEntrance(delay: 0.1, distance: 10)
                    }
                }
                .animation(MicroAnimation.success, value: phase)
                .padding(.horizontal, 20)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ChangeMomentView: View {
    private enum Phase {
        case choosing
        case selected
        case success
    }

    @Environment(\.dismiss) private var dismiss
    @State private var phase: Phase = .choosing
    @State private var selectedAction: String?

    private let actions = [
        "Drink a glass of water",
        "Leave the room",
        "Walk for 2 minutes",
        "Chew gum",
        "Brush your teeth"
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 22) {
                    ScreenHeader(
                        eyebrow: "Shift The Moment",
                        title: "Break the pattern.",
                        subtitle: "Choose one small action that changes what happens next."
                    )
                    .softEntrance(delay: 0.02, distance: 10)

                    if phase == .success {
                        rescueSuccessCard(
                            eyebrow: "Pattern Shifted",
                            symbol: "bolt.circle.fill",
                            title: "You changed the moment.",
                            subtitle: "One small action gave this urge less room."
                        )
                        .softEntrance(delay: 0.06, distance: 10, animation: MicroAnimation.success, initialScale: 0.985)

                        Button {
                            dismiss()
                        } label: {
                            Text("Back to rescue")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .softEntrance(delay: 0.12, distance: 10)
                    } else if phase == .selected, let selectedAction {
                        CardSection(fill: AnyShapeStyle(Color.surfaceElevated)) {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Your next step")
                                    .font(.footnote.weight(.semibold))
                                    .foregroundStyle(Color.heroAccent)
                                    .textCase(.uppercase)
                                    .tracking(1.2)

                                Text(selectedAction)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.ink)

                                Text(selectionSupportText)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)
                            }
                        }
                        .softEntrance(delay: 0.06, distance: 12)

                        Button {
                            withAnimation(.spring(response: 0.32, dampingFraction: 0.86)) {
                                phase = .success
                            }
                        } label: {
                                Text("I did it")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                        .softEntrance(delay: 0.12, distance: 10)
                    } else {
                        CardSection {
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(actions, id: \.self) { action in
                                    Button {
                                        withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                            selectedAction = action
                                            phase = .selected
                                        }
                                    } label: {
                                        HStack(spacing: 12) {
                                            Image(systemName: symbol(for: action))
                                                .font(.headline)
                                                .foregroundStyle(Color.heroAccent)
                                                .frame(width: 34, height: 34)
                                                .background(Color.accentWash)
                                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                                            Text(action)
                                                .font(.headline.weight(.semibold))
                                                .foregroundStyle(Color.ink)
                                                .multilineTextAlignment(.leading)

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.caption.weight(.bold))
                                                .foregroundStyle(Color.secondaryText)
                                        }
                                        .padding(16)
                                        .frame(maxWidth: .infinity)
                                        .glassPanel(cornerRadius: 20, tint: Color.cardBackground, tintOpacity: 0.15, shadowOpacity: 0.04)
                                    }
                                    .buttonStyle(CardPressButtonStyle())
                                }
                            }
                        }
                        .softEntrance(delay: 0.08, distance: 12)

                        Text("Pick the easiest move that helps this moment go a different way.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 16)
                            .softEntrance(delay: 0.16, distance: 10, animation: MicroAnimation.supportiveReveal)
                    }
                }
                .animation(MicroAnimation.success, value: phase)
                .padding(.horizontal, 20)
                .padding(.vertical, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    private var selectionSupportText: String {
        let messages = [
            "Good. You do not need a big fix, just a different next step.",
            "Small actions can soften strong urges.",
            "This moment does not have to follow the old pattern."
        ]

        guard let selectedAction else { return messages[0] }
        let index = abs(selectedAction.hashValue) % messages.count
        return messages[index]
    }

    private func symbol(for action: String) -> String {
        switch action {
        case "Drink a glass of water":
            return "drop.fill"
        case "Leave the room":
            return "door.left.hand.open"
        case "Walk for 2 minutes":
            return "figure.walk"
        case "Chew gum":
            return "mouth"
        case "Brush your teeth":
            return "sparkles"
        default:
            return "bolt"
        }
    }
}

func rescueSuccessCard(eyebrow: String, symbol: String, title: String, subtitle: String) -> some View {
    CardSection(fill: AnyShapeStyle(
        LinearGradient(
            colors: [Color.cardBackground.opacity(0.98), Color.heroTop.opacity(0.74)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    )) {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: symbol)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.heroAccent)
                    .frame(width: 42, height: 42)
                    .background(Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Spacer()
            }

            Text(eyebrow)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.heroAccent)
                .textCase(.uppercase)
                .tracking(1.2)

            ConversationalRevealText(
                text: title,
                startDelay: 0.12,
                chunkDelay: 0.9,
                chunking: .phrases,
                style: .init(
                    font: .system(size: 30, weight: .bold, design: .rounded),
                    finalColor: Color.ink,
                    mutedColor: Color.secondaryText,
                    lineSpacing: 4,
                    initialOpacity: 0.1,
                    animation: .easeOut(duration: 0.5)
                )
            )
            .softEntrance(delay: 0.02, distance: 10, animation: MicroAnimation.success, initialScale: 0.99)

            ConversationalRevealText(
                text: subtitle,
                startDelay: 0.72,
                chunkDelay: 1.0,
                chunking: .sentences,
                style: .init(
                    font: .body,
                    finalColor: Color.secondaryText,
                    mutedColor: Color.secondaryText,
                    lineSpacing: 4,
                    initialOpacity: 0.12,
                    animation: .easeOut(duration: 0.48)
                )
            )
            .softEntrance(delay: 0.08, distance: 10, animation: MicroAnimation.supportiveReveal)
        }
    }
    .transition(.calmSuccess)
}

#Preview {
    NavigationStack {
        ChangeMomentView()
    }
}
