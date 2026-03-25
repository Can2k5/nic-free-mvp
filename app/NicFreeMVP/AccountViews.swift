import AuthenticationServices
import SwiftUI

/// This helper pulls account-facing data from the right place:
/// Firebase Auth provides identity details like name, email, and sign-in method.
/// Local onboarding/profile data provides personal fields that should stay on device.
@MainActor
struct AccountProfileSnapshot {
    let name: String
    let email: String
    let provider: String
    let birthday: String
    let age: String
    let gender: String

    static func make(appState: AppState, authManager: AuthManager) -> AccountProfileSnapshot {
        let localName = appState.profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let authUser = authManager.signedInUser

        return AccountProfileSnapshot(
            name: authUser?.displayName?.nonEmpty ?? localName.nonEmpty ?? "Not set",
            email: authUser?.email?.nonEmpty ?? "Not set",
            provider: authUser?.provider.title ?? "Not set",
            birthday: Self.birthdayText(from: appState.birthday),
            age: Self.ageText(from: appState.ageBucketLabel),
            gender: Self.genderText(from: appState.gender)
        )
    }

    private static func birthdayText(from birthday: Date?) -> String {
        guard let birthday else { return "Not set" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthday)
    }

    private static func ageText(from ageBucket: String?) -> String {
        guard let ageBucket else {
            return "Not set"
        }
        return ageBucket
    }

    private static func genderText(from gender: String?) -> String {
        gender?.nonEmpty ?? "Not set"
    }
}

private extension String {
    var nonEmpty: String? {
        let cleaned = trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? nil : cleaned
    }
}

struct AccountEntryButton: View {
    @EnvironmentObject private var authManager: AuthManager
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.cardBackground.opacity(0.94), Color.heroTop.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 46, height: 46)

                Circle()
                    .stroke(Color.white.opacity(0.48), lineWidth: 1)
                    .frame(width: 46, height: 46)

                Image(systemName: authManager.signedInUser == nil ? "person.crop.circle.badge.plus" : "person.crop.circle.fill")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.ink)
            }
            .shadow(color: Color.shadowColor.opacity(0.14), radius: 10, x: 0, y: 6)
        }
        .accessibilityLabel(authManager.signedInUser == nil ? "Open account sign in" : "Open account")
    }
}

struct AccountDestinationView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        NavigationStack {
            Group {
                if authManager.signedInUser == nil {
                    AccountAuthView()
                } else {
                    AccountInfoView()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
        }
    }
}

struct AccountAuthView: View {
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    heroCard
                    providerButtons
                }
                .padding(.horizontal, 20)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Close") {
                    dismiss()
                }
                .foregroundStyle(Color.ink)
            }
        }
    }

    private var heroCard: some View {
        CardSection(
            fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.98), Color.heroTop.opacity(0.76)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Account")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.heroSecondaryText)
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text("Add an account if you want it.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .lineSpacing(2)

                Text("Sign in is optional. It helps Ayo recognize you, while your cravings, streaks, check-ins, and personal progress still stay on this device.")
                    .font(.subheadline)
                    .foregroundStyle(Color.heroSecondaryText)
            }
        }
    }

    private var providerButtons: some View {
        InsightCard(
            title: "Continue with",
            subtitle: "Use Apple or Google if you want a simple account connection.",
            icon: "person.crop.circle.badge.checkmark"
        ) {
            VStack(spacing: AppSpacing.md) {
                SignInWithAppleButton(.continue) { request in
                    authManager.prepareAppleSignInRequest(request)
                } onCompletion: { result in
                    authManager.handleAppleSignInCompletion(result)
                }
                .signInWithAppleButtonStyle(.black)
                .frame(height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .disabled(authManager.isLoading)
                .opacity(authManager.isLoading ? 0.75 : 1)

                providerButton(
                    title: "Continue with Google",
                    subtitle: "Use your Google account",
                    symbol: "g.circle",
                    isEnabled: !authManager.isLoading,
                    action: {
                        Task {
                            await authManager.signInWithGoogle()
                        }
                    }
                )

                if authManager.isLoading {
                    HStack(spacing: AppSpacing.sm) {
                        ProgressView()
                        Text(loadingMessage)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }
                }

                if let message = authManager.authErrorMessage, !message.isEmpty {
                    HStack(alignment: .top, spacing: 10) {
                        Image(systemName: "exclamationmark.circle.fill")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.72, green: 0.28, blue: 0.26))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Couldn't sign you in")
                                .font(.footnote.weight(.semibold))
                                .foregroundStyle(Color.ink)

                            Text(message)
                                .font(.footnote)
                                .foregroundStyle(Color.secondaryText)
                                .lineSpacing(2)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 12)
                    .background(Color.surfaceElevated)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.border, lineWidth: 1)
                    )
                }
            }
        }
    }

    private var loadingMessage: String {
        switch authManager.activeSignInProvider {
        case .google:
            return "Signing in with Google..."
        case .apple:
            return "Signing in with Apple..."
        case .email:
            return "Preparing your email sign-in link..."
        default:
            return "Signing you in..."
        }
    }

    private func providerButton(
        title: String,
        subtitle: String,
        symbol: String,
        isEnabled: Bool,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                Image(systemName: symbol)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isEnabled ? Color.ink : Color.secondaryText)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(isEnabled ? Color.ink : Color.secondaryText)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.textMuted)
                }

                Spacer()
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.inputBackground.opacity(isEnabled ? 1 : 0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(Color.border, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(!isEnabled)
    }
}

struct AccountInfoView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var authManager: AuthManager

    private var snapshot: AccountProfileSnapshot {
        AccountProfileSnapshot.make(appState: appState, authManager: authManager)
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    accountHero
                    accountDetails
                }
                .padding(.horizontal, 20)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .navigationTitle("Account")
        .toolbar(.visible, for: .navigationBar)
    }

    private var accountHero: some View {
        HeroCard(
            eyebrow: "Signed in",
            title: snapshot.name,
            subtitle: snapshot.provider,
            icon: "person.crop.circle.fill",
            alignment: .center
        ) {
            VStack(spacing: AppSpacing.sm) {
                Text(snapshot.email)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.heroSecondaryText)
                    .multilineTextAlignment(.center)

                Button {
                    authManager.signOut()
                } label: {
                    Text("Sign out")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(Color.ink)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 10)
                        .background(Color.cardBackground.opacity(0.82))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
            .frame(maxWidth: .infinity)
        }
    }

    private var accountDetails: some View {
        InsightCard(
            title: "Account details",
            subtitle: "Your sign-in comes from Apple or Google. Personal profile details stay on this device.",
            icon: "person.text.rectangle"
        ) {
            VStack(spacing: AppSpacing.md) {
                if let message = authManager.authErrorMessage, !message.isEmpty {
                    authMessageCard(
                        title: "Couldn't update your account",
                        message: message
                    )
                }

                detailRow(title: "Name", value: snapshot.name)
                detailRow(title: "Email", value: snapshot.email)
                detailRow(title: "Login way", value: snapshot.provider)
                NavigationLink {
                    EditBirthdayView()
                } label: {
                    editableDetailRow(title: "Birthday", value: snapshot.birthday)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    EditAgeView()
                } label: {
                    editableDetailRow(title: "Age", value: snapshot.age)
                }
                .buttonStyle(.plain)

                NavigationLink {
                    EditGenderView()
                } label: {
                    editableDetailRow(title: "Gender", value: snapshot.gender)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private func authMessageCard(title: String, message: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "exclamationmark.circle.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color(red: 0.72, green: 0.28, blue: 0.26))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.ink)

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.surfaceElevated)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.border, lineWidth: 1)
        )
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.trailing)
        }
    }

    private func editableDetailRow(title: String, value: String) -> some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.trailing)

            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.textMuted)
        }
        .contentShape(Rectangle())
    }
}

struct EditBirthdayView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedBirthday = Date()
    @State private var hasBirthday = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    InsightCard(
                        title: "Birthday",
                        subtitle: "This stays on your device and helps complete your local account profile.",
                        icon: "calendar"
                    ) {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            DatePicker(
                                "Birthday",
                                selection: $selectedBirthday,
                                in: ...Date(),
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .labelsHidden()
                            .tint(Color.buttonBottom)
                            .padding(.horizontal, 8)
                            .padding(.top, 8)
                            .padding(.bottom, 12)
                            .frame(maxWidth: .infinity)
                            .background(Color.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(Color.border, lineWidth: 1)
                            )

                            if hasBirthday {
                                Button("Clear birthday") {
                                    appState.birthday = nil
                                    dismiss()
                                }
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.buttonBottom)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .navigationTitle("Edit Birthday")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Save") {
                    appState.birthday = selectedBirthday
                    dismiss()
                }
                .foregroundStyle(Color.ink)
            }
        }
        .onAppear {
            if let birthday = appState.birthday {
                selectedBirthday = birthday
                hasBirthday = true
            } else {
                hasBirthday = false
            }
        }
    }
}

struct EditAgeView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var selectedAge = 25

    private let ageValues = Array(13...100)

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    if appState.hasBirthday {
                        InsightCard(
                            title: "Age",
                            subtitle: "Age now comes from your birthday, so it stays consistent automatically.",
                            icon: "calendar.badge.clock"
                        ) {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                infoRow(title: "Birthday", value: birthdayText)
                                infoRow(title: "Derived age group", value: appState.ageBucketLabel ?? "Not set")

                                Text("If you want to change this, update your birthday instead.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    } else {
                        InsightCard(
                            title: "Age",
                            subtitle: "This is a local fallback until a birthday is set.",
                            icon: "person"
                        ) {
                            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                                OnboardingWheelValuePicker(
                                    title: "Current age",
                                    valueText: "\(selectedAge)",
                                    selection: $selectedAge,
                                    values: ageValues,
                                    valueFontSize: 28,
                                    wheelHeight: 90,
                                    verticalPadding: 4
                                )

                                Text("The app will show your age using the same onboarding groups: Under 18, 18–25, or 25+.")
                                    .font(.subheadline)
                                    .foregroundStyle(Color.secondaryText)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .navigationTitle("Edit Age")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !appState.hasBirthday {
                    Button("Save") {
                        appState.age = selectedAge
                        dismiss()
                    }
                    .foregroundStyle(Color.ink)
                }
            }
        }
        .onAppear {
            selectedAge = appState.effectiveAge ?? 25
        }
    }

    private func infoRow(title: String, value: String) -> some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Spacer(minLength: 12)

            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.trailing)
        }
    }

    private var birthdayText: String {
        guard let birthday = appState.birthday else { return "Not set" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: birthday)
    }
}

struct EditGenderView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    private let options = [
        OnboardingPillOption(title: "Male", value: "Male"),
        OnboardingPillOption(title: "Female", value: "Female"),
        OnboardingPillOption(title: "Non-binary", value: "Other"),
        OnboardingPillOption(title: "Prefer not to say", value: "Other")
    ]

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: AppSpacing.section) {
                    InsightCard(
                        title: "Gender",
                        subtitle: "This stays local in the app and can be updated any time.",
                        icon: "figure.stand"
                    ) {
                        VStack(alignment: .leading, spacing: AppSpacing.md) {
                            OnboardingPillSelector(
                                options: options,
                                selectedValue: appState.gender,
                                minItemWidth: 132,
                                itemHeight: 42
                            ) { value in
                                appState.gender = value
                            }

                            Button("Clear gender") {
                                appState.gender = nil
                            }
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, AppSpacing.lg)
                .padding(.bottom, AppSpacing.lg)
            }
        }
        .navigationTitle("Edit Gender")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
                .foregroundStyle(Color.ink)
            }
        }
    }
}
