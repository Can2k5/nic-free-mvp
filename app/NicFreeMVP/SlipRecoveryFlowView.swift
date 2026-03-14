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
                                step = .trigger
                            }

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
                                step = .recovery
                            }

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

                        case .support:
                            supportStep
                        }
                    }
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
                                    .fill(isSelected ? Color.buttonBottom : Color.white.opacity(0.7))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var supportStep: some View {
        VStack(spacing: 18) {
            ScreenHeader(
                eyebrow: "Keep Going",
                title: "You did not lose everything.",
                subtitle: supportiveMessage
            )

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.96), Color(red: 0.95, green: 0.97, blue: 0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("One hard moment does not erase your progress.")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text("What matters now is the next caring choice you make for yourself.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(4)
                }
            }

            Button {
                dismiss()
            } label: {
                Text("Back to Home")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
            }
            .buttonStyle(PrimaryButtonStyle())
        }
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

        step = .support
    }
}

#Preview {
    SlipRecoveryFlowView()
        .environmentObject(AppState())
}
