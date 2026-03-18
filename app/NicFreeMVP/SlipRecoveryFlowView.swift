import SwiftUI

struct SlipRecoveryFlowView: View {
    private enum Step {
        case happened
        case trigger
        case recovery
        case support
    }

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var step: Step = .happened
    @State private var selectedType: SlipType?
    @State private var selectedTrigger: SlipTrigger?
    @State private var selectedRecoveryMode: SlipRecoveryMode?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 18) {
                        switch step {
                        case .happened:
                            selectionStep(
                                eyebrow: "Slip Support",
                                title: "What happened?",
                                subtitle: "A hard moment does not cancel your progress. Let's just understand it.",
                                options: SlipType.allCases,
                                selection: selectedType,
                                titleForOption: \.title
                            ) { value in
                                selectedType = value
                                withAnimation(MicroAnimation.flow) {
                                    step = .trigger
                                }
                            }
                            .transition(.calmFlow)
                            .zIndex(1)

                        case .trigger:
                            selectionStep(
                                eyebrow: "Slip Support",
                                title: "What led to it?",
                                subtitle: "Naming the moment can help you recover more gently next time.",
                                options: SlipTrigger.allCases,
                                selection: selectedTrigger,
                                titleForOption: \.title
                            ) { value in
                                selectedTrigger = value
                                withAnimation(MicroAnimation.flow) {
                                    step = .recovery
                                }
                            }
                            .transition(.calmFlow)
                            .zIndex(1)

                        case .recovery:
                            selectionStep(
                                eyebrow: "Recovery",
                                title: "How do you want to continue?",
                                subtitle: "You can keep moving forward from here, or choose a fresh start for your streak.",
                                options: SlipRecoveryMode.allCases,
                                selection: selectedRecoveryMode,
                                titleForOption: \.title
                            ) { value in
                                selectedRecoveryMode = value
                                saveSlipAndContinue()
                            }
                            .transition(.calmFlow)
                            .zIndex(1)

                        case .support:
                            supportStep
                                .transition(.calmSuccess)
                                .zIndex(2)
                        }
                    }
                    .animation(MicroAnimation.flow, value: step)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 28)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundStyle(Color.secondaryText)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private func selectionStep<Option: Identifiable & Hashable>(
        eyebrow: String,
        title: String,
        subtitle: String,
        options: [Option],
        selection: Option?,
        titleForOption: KeyPath<Option, String>,
        onSelect: @escaping (Option) -> Void
    ) -> some View {
        VStack(spacing: 18) {
            ScreenHeader(
                eyebrow: eyebrow,
                title: title,
                subtitle: subtitle
            )
            .softEntrance(delay: 0.02, distance: 10)

            CardSection {
                VStack(spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        let isSelected = selection == option

                        Button {
                            onSelect(option)
                        } label: {
                            HStack {
                                Text(option[keyPath: titleForOption])
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(isSelected ? Color.white : Color.ink)
                                Spacer()
                                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(isSelected ? Color.white : Color.secondaryText.opacity(0.7))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(isSelected ? Color.buttonBottom : Color.surfaceElevated)
                            )
                        }
                        .buttonStyle(SelectableButtonStyle(isSelected: isSelected))
                    }
                }
            }
            .softEntrance(delay: 0.1, distance: 12)
        }
        .transition(.calmSuccess)
    }

    private var supportStep: some View {
        VStack(spacing: 18) {
            VStack(alignment: .leading, spacing: 10) {
                Text("Keep Going")
                    .font(.caption.weight(.semibold))
                    .tracking(1.1)
                    .textCase(.uppercase)
                    .foregroundStyle(Color.secondaryText)

                ConversationalRevealText(
                    text: "You did not lose everything.",
                    startDelay: 0.08,
                    chunkDelay: 0.5,
                    chunking: .phrases,
                    style: .headline
                )

                ConversationalRevealText(
                    text: supportiveMessage,
                    startDelay: 0.42,
                    chunkDelay: 0.72,
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
            .softEntrance(delay: 0.04, distance: 10)

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.98), Color.cardSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 12) {
                    ConversationalRevealText(
                        text: "One hard moment does not erase your progress.",
                        startDelay: 0.9,
                        chunkDelay: 0.6,
                        chunking: .phrases,
                        style: .init(
                            font: .title3.weight(.semibold),
                            finalColor: Color.ink,
                            mutedColor: Color.secondaryText,
                            lineSpacing: 4,
                            initialOpacity: 0.1,
                            animation: .easeOut(duration: 0.48)
                        )
                    )

                    Text("What matters now is the next caring choice you make for yourself.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(4)
                }
            }
            .softEntrance(delay: 0.08, distance: 16, animation: MicroAnimation.success, initialScale: 0.97)

            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(PrimaryButtonStyle())
            .softEntrance(delay: 0.14, distance: 12, animation: MicroAnimation.success, initialScale: 0.985)
        }
        .transition(.calmSuccess)
    }

    private var supportiveMessage: String {
        switch selectedRecoveryMode {
        case .keepGoing:
            return "You can keep going from here. One difficult decision does not define the whole quit."
        case .resetStreak:
            return "Starting again is still progress. A reset can be gentle, honest, and full of self-respect."
        case .none:
            return "You are still here, and that matters."
        }
    }

    private func saveSlipAndContinue() {
        guard
            let selectedType,
            let selectedTrigger,
            let selectedRecoveryMode
        else {
            return
        }

        appState.recordSlip(
            type: selectedType,
            trigger: selectedTrigger,
            recoveryMode: selectedRecoveryMode
        )

        withAnimation(MicroAnimation.success) {
            step = .support
        }
    }
}

#Preview {
    SlipRecoveryFlowView()
        .environmentObject(AppState())
}
