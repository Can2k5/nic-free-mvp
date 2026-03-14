import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var newReason = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 22) {
                        ScreenHeader(
                            eyebrow: "Settings",
                            title: "Your quit setup.",
                            subtitle: "Keep your quit date, spending baseline, and personal motivations up to date."
                        )

                        CardSection {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quit date")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                DatePicker(
                                    "Quit date",
                                    selection: $appState.quitDate,
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.graphical)
                                .labelsHidden()
                            }
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Daily spend")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text(appState.dailySpend.formatted(.currency(code: "USD")))
                                    .font(.system(size: 30, weight: .bold, design: .rounded))
                                    .foregroundStyle(Color.ink)

                                Stepper(value: $appState.dailySpend, in: 0...100, step: 0.5) {
                                    Text("Adjust your average daily spend")
                                        .font(.subheadline)
                                        .foregroundStyle(Color.secondaryText)
                                }
                            }
                        }

                        CardSection {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Quit reasons")
                                    .font(.title3.weight(.semibold))
                                    .foregroundStyle(Color.ink)

                                Text("Add up to three short reasons you want to come back to.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)

                                HStack(spacing: 10) {
                                    TextField("My health", text: $newReason)
                                        .textFieldStyle(.plain)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 14)
                                        .background(Color.white.opacity(0.72))
                                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                                    Button("Add") {
                                        appState.addQuitReason(newReason)
                                        newReason = ""
                                    }
                                    .disabled(newReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.quitReasons.count >= 3)
                                    .buttonStyle(PrimaryButtonStyle(isEnabled: !newReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && appState.quitReasons.count < 3))
                                }

                                if appState.quitReasons.isEmpty {
                                    Text("No reasons added yet.")
                                        .font(.footnote)
                                        .foregroundStyle(Color.secondaryText)
                                } else {
                                    ForEach(appState.quitReasons, id: \.self) { reason in
                                        HStack {
                                            Text(reason)
                                                .font(.subheadline.weight(.medium))
                                                .foregroundStyle(Color.ink)

                                            Spacer()

                                            Button("Remove") {
                                                appState.removeQuitReason(reason)
                                            }
                                            .font(.footnote.weight(.semibold))
                                            .foregroundStyle(Color.secondaryText)
                                        }
                                        .padding(.vertical, 4)
                                    }
                                }
                            }
                        }

                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                    .padding(.bottom, 32)
                }
            }
            .toolbar(.hidden, for: .navigationBar)
        }
#if DEBUG
        .safeAreaInset(edge: .bottom) {
            VStack(spacing: 0) {
                CardSection(fill: AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), Color(red: 0.95, green: 0.95, blue: 0.93)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Debug")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("Reset onboarding to test the first-run flow again. Your cravings, slips, and check-ins stay untouched.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                            .lineSpacing(4)

                        Button {
                            appState.resetOnboardingForDebug()
                        } label: {
                            Text("Reset onboarding")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                        .buttonStyle(PrimaryButtonStyle())
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                .background(Color.appBackgroundBottom.opacity(0.94))
            }
        }
#endif
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
}
