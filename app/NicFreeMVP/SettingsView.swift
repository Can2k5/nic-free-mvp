import SwiftUI

struct SettingsView: View {
    private enum DataAction: String, Identifiable {
        case resetProgress
        case clearCravingHistory

        var id: String { rawValue }
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var newReason = ""
    @State private var pendingAction: DataAction?

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ScreenHeader(
                            eyebrow: "Settings",
                            title: "Personalize your quit.",
                            subtitle: "Update your quit setup, keep your reasons close, and manage your data carefully."
                        )
                        .softEntrance(delay: 0.02, distance: 10)

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                sectionLabel("Appearance")

                                Text("Choose how the app should look across all screens.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                VStack(spacing: 10) {
                                    ForEach(ThemeMode.allCases) { mode in
                                        appearanceOptionRow(mode)
                                    }
                                }
                            }
                        }
                        .softEntrance(delay: 0.06, distance: 12)

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                sectionLabel("Quit setup")

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Quit date")
                                        .font(.headline)
                                        .foregroundStyle(Color.ink)

                                    Text("This updates your nicotine-free days and progress immediately.")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondaryText)

                                    DatePicker(
                                        "Quit date",
                                        selection: $appState.quitDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .tint(Color.buttonBottom)
                                    .padding(12)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.inputBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.border, lineWidth: 1)
                                    )
                                }

                                Divider()
                                    .overlay(Color.divider)

                                VStack(alignment: .leading, spacing: 12) {
                                    Text("Daily nicotine spend")
                                        .font(.headline)
                                        .foregroundStyle(Color.ink)

                                    HStack(alignment: .firstTextBaseline) {
                                        Text(appState.dailySpend.formatted(.currency(code: "USD")))
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.ink)

                                        Spacer()

                                        Text("per day")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondaryText)
                                    }

                                    Stepper(value: $appState.dailySpend, in: 0...100, step: 0.5) {
                                        Text("Adjust your average daily spend")
                                            .font(.subheadline)
                                            .foregroundStyle(Color.secondaryText)
                                    }
                                }
                            }
                        }
                        .softEntrance(delay: 0.08, distance: 12)

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                sectionLabel("Motivation")

                                Text("Keep up to three personal reasons close so the app can bring them back when cravings hit.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                HStack(spacing: 10) {
                                    TextField("My health", text: $newReason)
                                        .textFieldStyle(.plain)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.inputBackground)
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    Button("Add") {
                                        appState.addQuitReason(newReason)
                                        newReason = ""
                                    }
                                    .disabled(addReasonDisabled)
                                    .buttonStyle(PrimaryButtonStyle(isEnabled: !addReasonDisabled))
                                }

                                if appState.quitReasons.isEmpty {
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("No reasons added yet")
                                            .font(.headline)
                                            .foregroundStyle(Color.ink)

                                        Text("Add up to three short reasons like your health, your future, or your family to make motivation and rescue moments more personal.")
                                            .font(.footnote)
                                            .foregroundStyle(Color.secondaryText)
                                            .lineSpacing(3)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.surfaceMuted)
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                } else {
                                    ForEach(appState.quitReasons, id: \.self) { reason in
                                        HStack(spacing: 12) {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(reason)
                                                    .font(.headline)
                                                    .foregroundStyle(Color.ink)

                                                Text("Used in motivation and rescue moments.")
                                                    .font(.footnote)
                                                    .foregroundStyle(Color.secondaryText)
                                            }

                                            Spacer()

                                            Button("Remove") {
                                                appState.removeQuitReason(reason)
                                            }
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.secondaryText)
                                            .buttonStyle(SecondaryButtonStyle())
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 14)
                                        .background(Color.surfaceMuted)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    }
                                }
                            }
                        }
                        .softEntrance(delay: 0.14, distance: 12)

                        CardSection {
                            VStack(alignment: .leading, spacing: 18) {
                                sectionLabel("Data and reset")

                                Text("Use these carefully. They affect stored progress and history.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                subtleActionRow(
                                    title: "Reset progress",
                                    subtitle: "Reset streak, cravings, slips, and daily check-ins."
                                ) {
                                    pendingAction = .resetProgress
                                }

                                subtleActionRow(
                                    title: "Clear craving history",
                                    subtitle: "Remove logged craving events while keeping your quit setup."
                                ) {
                                    pendingAction = .clearCravingHistory
                                }

                                subtleActionRow(
                                    title: "Reset onboarding",
                                    subtitle: "Start the onboarding flow again from the beginning."
                                ) {
                                    appState.resetOnboardingForDebug()
                                    onboardingManager.reset()
                                }
                            }
                        }
                        .softEntrance(delay: 0.2, distance: 12)

                        CardSection(fill: AnyShapeStyle(
                            LinearGradient(
                                colors: [Color.cardBackground.opacity(0.96), Color.mist.opacity(0.32)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )) {
                            VStack(alignment: .leading, spacing: 16) {
                                sectionLabel("App information")

                                infoRow(title: "App", value: "Nic Free MVP")
                                infoRow(title: "Version", value: appVersionText)

                                Text("A lightweight quit companion focused on craving support, progress, and personal motivation.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                                    .lineSpacing(4)

                                infoLinkRow("Privacy Policy")
                                infoLinkRow("Terms")
                            }
                        }
                        .softEntrance(delay: 0.26, distance: 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
        .confirmationDialog(
            dialogTitle,
            isPresented: Binding(
                get: { pendingAction != nil },
                set: { if !$0 { pendingAction = nil } }
            ),
            titleVisibility: .visible
        ) {
            switch pendingAction {
            case .resetProgress:
                Button("Reset progress", role: .destructive) {
                    appState.resetProgress()
                }
            case .clearCravingHistory:
                Button("Clear craving history", role: .destructive) {
                    appState.clearCravingHistory()
                }
            case .none:
                EmptyView()
            }

            Button("Cancel", role: .cancel) {}
        } message: {
            Text(dialogMessage)
        }
    }

    private var addReasonDisabled: Bool {
        newReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.quitReasons.count >= 3
    }

    private func appearanceOptionRow(_ mode: ThemeMode) -> some View {
        Button {
            withAnimation(MicroAnimation.selection) {
                themeManager.mode = mode
            }
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(mode.title)
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    Text(mode.subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                ZStack {
                    Circle()
                        .fill(themeManager.mode == mode ? Color.buttonBottom : Color.surfaceMuted)
                        .frame(width: 26, height: 26)

                    if themeManager.mode == mode {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.white)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(themeManager.mode == mode ? Color.buttonBottom.opacity(0.08) : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(themeManager.mode == mode ? Color.buttonBottom.opacity(0.22) : Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var dialogTitle: String {
        switch pendingAction {
        case .resetProgress:
            return "Reset progress?"
        case .clearCravingHistory:
            return "Clear craving history?"
        case .none:
            return ""
        }
    }

    private var dialogMessage: String {
        switch pendingAction {
        case .resetProgress:
            return "This resets your streak and clears saved progress history. Your quit reasons stay in place."
        case .clearCravingHistory:
            return "This removes saved craving events but keeps your quit date, reasons, and other settings."
        case .none:
            return ""
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(.footnote.weight(.semibold))
            .foregroundStyle(Color.secondaryText)
            .textCase(.uppercase)
            .tracking(1.1)
    }

    private func subtleActionRow(title: String, subtitle: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.secondaryText)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.surfaceMuted)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.secondaryText)

            Spacer()

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
    }

    private func infoLinkRow(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(Color.ink)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.secondaryText)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(OnboardingManager())
        .environmentObject(ThemeManager())
}
