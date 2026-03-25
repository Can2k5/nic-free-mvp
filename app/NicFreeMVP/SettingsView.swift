import SwiftUI

struct SettingsView: View {
    private enum Metrics {
        static let screenHorizontalPadding = AppSpacing.lg
        static let screenTopPadding = AppSpacing.xl
        static let screenBottomPadding = AppSpacing.xxl
        static let headerTopPadding = AppSpacing.sm
        static let headerBottomPadding = AppSpacing.xl
        static let sectionSpacing = AppSpacing.section
        static let heroSpacing = AppSpacing.xl
        static let groupedContentSpacing = AppSpacing.md
        static let subsectionSpacing = AppSpacing.lg
        static let rowSpacing = AppSpacing.sm
        static let compactSpacing = AppSpacing.xs
        static let controlPadding = AppSpacing.sm
        static let controlCornerRadius: CGFloat = 20
        static let rowCornerRadius: CGFloat = 18
        static let groupCornerRadius: CGFloat = 28
        static let heroCornerRadius: CGFloat = 30
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var authManager: AuthManager

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.lg) {
                        settingsHeader
                            .softEntrance(delay: 0.02, distance: 10)

                        navigationOverviewSection
                            .softEntrance(delay: 0.06, distance: 12)
                    }
                    .padding(.horizontal, Metrics.screenHorizontalPadding)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, AppSpacing.lg)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .frame(maxWidth: .infinity)
                .clipped()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var settingsHeader: some View {
        CardSection(
            fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.cardBackground.opacity(0.98), Color.heroTop.opacity(0.72)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        ) {
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                HStack(alignment: .top, spacing: AppSpacing.md) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Settings")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.heroSecondaryText)
                            .textCase(.uppercase)
                            .tracking(1.1)

                        Text(heroTitle)
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .lineSpacing(2)

                        Text(heroSubtitle)
                            .font(.subheadline)
                            .foregroundStyle(Color.heroSecondaryText)
                            .lineLimit(2)
                    }

                    Spacer(minLength: 0)

                    Text(heroAccentLabel)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(Color.heroAccent)
                        .padding(.horizontal, AppSpacing.sm)
                        .padding(.vertical, AppSpacing.xs)
                        .background(Color.cardBackground.opacity(0.6))
                        .clipShape(Capsule())
                }

                Text(heroSupportingLine)
                    .font(.subheadline)
                    .foregroundStyle(Color.heroSecondaryText)
                    .lineLimit(2)

                HStack(spacing: AppSpacing.md) {
                    ForEach(heroMetrics) { metric in
                        SettingsHeaderMetric(metric: metric)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var heroTitle: String {
        if appState.nicotineFreeDays > 0 {
            return "\(displayName), your progress is taking shape."
        }
        return "Set up the support you want around you."
    }

    private var heroSubtitle: String {
        if appState.nicotineFreeDays > 0 {
            return "You are \(appState.nicotineFreeDays) \(appState.nicotineFreeDays == 1 ? "day" : "days") nicotine-free. Keep your setup and reasons close."
        }
        return "Keep your setup and reasons ready so support feels easy to reach."
    }

    private var heroSupportingLine: String {
        if let highlightedQuitReason = appState.highlightedQuitReason {
            return "\"\(highlightedQuitReason)\" is ready when you need grounding."
        }

        if !appState.dynamicMotivation.isEmpty {
            return appState.dynamicMotivation
        }

        return "A thoughtful setup can make hard moments feel a little lighter."
    }

    private var heroAccentLabel: String {
        "Quit since \(startDateText)"
    }

    private var heroMetrics: [SettingsHeroMetric] {
        [
            SettingsHeroMetric(
                value: "\(max(appState.nicotineFreeDays, 0))",
                label: appState.nicotineFreeDays == 1 ? "day nicotine-free" : "days nicotine-free",
                symbol: "sparkles"
            ),
            SettingsHeroMetric(
                value: appState.moneySaved.formatted(.currency(code: currencyCode)),
                label: "saved so far",
                symbol: "eurosign.circle.fill"
            )
        ]
    }

    private var displayName: String {
        let trimmed = appState.profileName.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "You" : trimmed
    }

    private var accountSummaryText: String {
        if let user = authManager.signedInUser {
            if let email = user.email?.trimmingCharacters(in: .whitespacesAndNewlines), !email.isEmpty {
                return "\(user.provider.title) account connected"
            }
            return "Signed in with \(user.provider.title)"
        }

        return "Optional sign-in with Apple or Google"
    }

    private var startDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: appState.quitDate)
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var navigationOverviewSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Choose what to update")
                .font(.title3.weight(.semibold))
                .foregroundStyle(Color.ink)

            NavigationLink {
                AccountDestinationView()
                    .environmentObject(appState)
                    .environmentObject(authManager)
            } label: {
                ActionCard(
                    title: "Account",
                    subtitle: accountSummaryText,
                    icon: "person.crop.circle.badge.checkmark"
                )
            }
            .buttonStyle(CardPressButtonStyle())

            NavigationLink {
                ProgressSettingsView()
            } label: {
                ActionCard(
                    title: "Your Progress",
                    subtitle: "Quit date and daily spend",
                    icon: "chart.bar.fill"
                )
            }
            .buttonStyle(CardPressButtonStyle())

            NavigationLink {
                MotivationSettingsView()
            } label: {
                ActionCard(
                    title: "Your Motivation",
                    subtitle: "Your personal reasons",
                    icon: "heart"
                )
            }
            .buttonStyle(CardPressButtonStyle())

            NavigationLink {
                AppSettingsView()
            } label: {
                ActionCard(
                    title: "App Settings",
                    subtitle: "Appearance and preferences",
                    icon: "gear"
                )
            }
            .buttonStyle(CardPressButtonStyle())

            NavigationLink {
                ResetOptionsView()
                    .environmentObject(appState)
                    .environmentObject(onboardingManager)
            } label: {
                ActionCard(
                    title: "Reset Options",
                    subtitle: "Progress, craving history, and onboarding",
                    icon: "arrow.counterclockwise"
                )
            }
            .buttonStyle(CardPressButtonStyle())

            NavigationLink {
                AppInformationView()
            } label: {
                ActionCard(
                    title: "App Information",
                    subtitle: "Version, privacy, and terms",
                    icon: "info.circle"
                )
            }
            .buttonStyle(CardPressButtonStyle())
        }
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }
}

private struct ProgressSettingsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                SettingsDetailContainer {
                    SettingsSection(
                        title: "Your progress",
                        subtitle: "Update the details that shape your progress and savings."
                    ) {
                        SettingsGroupCard {
                            VStack(alignment: .leading, spacing: AppSpacing.xl) {
                                VStack(alignment: .leading, spacing: 14) {
                                    SettingsTitleText("Quit date")
                                    SettingsSupportingText("Changes apply to your nicotine-free days and progress right away.")

                                    DatePicker(
                                        "Quit date",
                                        selection: $appState.quitDate,
                                        displayedComponents: .date
                                    )
                                    .datePickerStyle(.graphical)
                                    .labelsHidden()
                                    .tint(Color.buttonBottom)
                                    .padding(.horizontal, 8)
                                    .padding(.top, 10)
                                    .padding(.bottom, 20)
                                    .frame(maxWidth: .infinity, minHeight: 420, alignment: .top)
                                    .frame(maxWidth: .infinity)
                                    .background(Color.inputBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                                            .stroke(Color.border, lineWidth: 1)
                                    )
                                }

                                SettingsDivider()
                                    .padding(.top, 2)

                                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                                    SettingsTitleText("Daily nicotine spend")

                                    HStack(alignment: .firstTextBaseline, spacing: AppSpacing.sm) {
                                        Text(appState.dailySpend.formatted(.currency(code: "USD")))
                                            .font(.system(size: 30, weight: .bold, design: .rounded))
                                            .foregroundStyle(Color.ink)

                                        Text("per day")
                                            .font(.caption)
                                            .foregroundStyle(Color.textMuted)

                                        Spacer()
                                    }

                                    Stepper(value: $appState.dailySpend, in: 0...100, step: 0.5) {
                                        SettingsSupportingText("Adjust your average daily spend.")
                                    }
                                    .tint(Color.buttonBottom)
                                    .controlSize(.large)
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.surfaceElevated, Color.inputBackground.opacity(0.94)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.borderStrong.opacity(0.34), lineWidth: 1)
                                    )
                                    .shadow(color: Color.shadowColor.opacity(0.06), radius: 10, x: 0, y: 6)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .navigationTitle("Your Progress")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

private struct ResetOptionsView: View {
    private enum DataAction: String, Identifiable {
        case resetProgress
        case clearCravingHistory

        var id: String { rawValue }
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @State private var pendingAction: DataAction?

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                SettingsDetailContainer {
                    SettingsSection(
                        title: "Reset options",
                        subtitle: "These actions change what the app remembers on this device."
                    ) {
                        SettingsGroupCard {
                            VStack(spacing: AppSpacing.md) {
                                Button {
                                    pendingAction = .resetProgress
                                } label: {
                                    ActionCard(
                                        title: "Reset progress",
                                        subtitle: "Start your count again and clear logged moments.",
                                        icon: "arrow.counterclockwise",
                                        showsChevron: false
                                    )
                                }
                                .buttonStyle(CardPressButtonStyle())

                                Button {
                                    pendingAction = .clearCravingHistory
                                } label: {
                                    ActionCard(
                                        title: "Clear craving history",
                                        subtitle: "Clear logged cravings while keeping your setup.",
                                        icon: "clock.arrow.trianglehead.counterclockwise.rotate.90",
                                        showsChevron: false
                                    )
                                }
                                .buttonStyle(CardPressButtonStyle())

                                Button {
                                    appState.resetOnboardingForDebug()
                                    onboardingManager.reset()
                                } label: {
                                    ActionCard(
                                        title: "Reset onboarding",
                                        subtitle: "Go through the welcome flow again from the start.",
                                        icon: "sparkles",
                                        showsChevron: false
                                    )
                                }
                                .buttonStyle(CardPressButtonStyle())
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .navigationTitle("Reset Options")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
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

    private var dialogTitle: String {
        switch pendingAction {
        case .resetProgress:
            return "Start progress again?"
        case .clearCravingHistory:
            return "Clear craving history?"
        case .none:
            return ""
        }
    }

    private var dialogMessage: String {
        switch pendingAction {
        case .resetProgress:
            return "This starts your count again and clears saved history. Your reasons stay in place."
        case .clearCravingHistory:
            return "This removes saved craving events but keeps your quit date, reasons, and settings."
        case .none:
            return ""
        }
    }
}

private struct AppInformationView: View {
    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                SettingsDetailContainer {
                    SettingsSection(
                        title: "App information",
                        subtitle: "A few practical details for the app."
                    ) {
                        SettingsGroupCard {
                            VStack(alignment: .leading, spacing: AppSpacing.md) {
                                detailRow(title: "App", value: appNameText)
                                detailRow(title: "Version", value: appVersionText)
                                ActionCard(title: "Privacy Policy", icon: "hand.raised", showsChevron: true)
                                ActionCard(title: "Terms", icon: "doc.text", showsChevron: true)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .navigationTitle("App Information")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }

    private var appVersionText: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "1"
        return "\(version) (\(build))"
    }

    private var appNameText: String {
        let displayName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
        return displayName ?? bundleName ?? "Ayo"
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.secondaryText)
            Spacer()
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
    }
}

private struct MotivationSettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var newReason = ""

    private var addReasonDisabled: Bool {
        newReason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || appState.quitReasons.count >= 3
    }

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                SettingsDetailContainer {
                    SettingsSection(
                        title: "Your motivation",
                        subtitle: "Keep up to three personal reasons close for cravings and rescue moments."
                    ) {
                        SettingsGroupCard {
                            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                                SettingsMotivationHeader(reasonCount: appState.quitReasons.count)

                                HStack(alignment: .center, spacing: AppSpacing.sm) {
                                    HStack(spacing: AppSpacing.sm) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(addReasonDisabled ? Color.textMuted : Color.buttonBottom)

                                        TextField("My health", text: $newReason)
                                            .textFieldStyle(.plain)
                                            .font(.system(size: 16, weight: .medium, design: .rounded))
                                            .foregroundStyle(Color.ink)
                                    }
                                    .padding(.horizontal, AppSpacing.md)
                                    .padding(.vertical, 15)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .fill(
                                                LinearGradient(
                                                    colors: [Color.inputBackground, Color.surfaceElevated.opacity(0.92)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.border.opacity(0.7), lineWidth: 1)
                                    )

                                    Button {
                                        withAnimation(.easeInOut(duration: 0.22)) {
                                            appState.addQuitReason(newReason)
                                            newReason = ""
                                        }
                                    } label: {
                                        Text(appState.quitReasons.count >= 3 ? "Full" : "Add")
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(addReasonDisabled ? Color.secondaryText : Color.white)
                                            .frame(minWidth: 64)
                                            .padding(.horizontal, 14)
                                            .padding(.vertical, 15)
                                            .background(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .fill(
                                                        addReasonDisabled
                                                            ? AnyShapeStyle(
                                                                LinearGradient(
                                                                    colors: [Color.surfaceMuted, Color.surface.opacity(0.85)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                            : AnyShapeStyle(
                                                                LinearGradient(
                                                                    colors: [Color.buttonTop.opacity(0.96), Color.buttonBottom.opacity(0.92)],
                                                                    startPoint: .topLeading,
                                                                    endPoint: .bottomTrailing
                                                                )
                                                            )
                                                    )
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                                    .stroke(
                                                        addReasonDisabled ? Color.border.opacity(0.45) : Color.buttonBottom.opacity(0.18),
                                                        lineWidth: 1
                                                    )
                                            )
                                            .shadow(color: addReasonDisabled ? Color.clear : Color.buttonBottom.opacity(0.12), radius: 12, x: 0, y: 7)
                                    }
                                    .disabled(addReasonDisabled)
                                    .buttonStyle(.plain)
                                }

                                if appState.quitReasons.isEmpty {
                                    MotivationEmptyStateCard()
                                } else {
                                    VStack(spacing: AppSpacing.sm) {
                                        ForEach(appState.quitReasons, id: \.self) { reason in
                                            MotivationReasonCard(reason: reason) {
                                                withAnimation(.easeInOut(duration: 0.22)) {
                                                    appState.removeQuitReason(reason)
                                                }
                                            }
                                            .transition(.asymmetric(
                                                insertion: .opacity.combined(with: .move(edge: .top)),
                                                removal: .opacity.combined(with: .scale(scale: 0.98))
                                            ))
                                        }
                                    }
                                    .animation(.easeInOut(duration: 0.22), value: appState.quitReasons)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .navigationTitle("Your Motivation")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
    }
}

private struct AppSettingsView: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @EnvironmentObject private var notificationManager: LocalNotificationManager
    @State private var showingPaywall = false

    var body: some View {
        ZStack {
            AppBackground()

            ScrollView(.vertical, showsIndicators: false) {
                SettingsDetailContainer {
                    SettingsSection(
                        title: "App settings",
                        subtitle: "Choose how Nic Free should look across the app."
                    ) {
                        VStack(alignment: .leading, spacing: AppSpacing.lg) {
                            SettingsGroupCard {
                                VStack(spacing: 0) {
                                    ForEach(Array(ThemeMode.allCases.enumerated()), id: \.element) { index, mode in
                                        SettingsAppearanceOptionRow(
                                            mode: mode,
                                            isSelected: themeManager.mode == mode,
                                            isLocked: mode == .dark && subscriptionManager.isFree
                                        ) {
                                            if mode == .dark && subscriptionManager.isFree {
                                                showingPaywall = true
                                            } else {
                                                withAnimation(MicroAnimation.selection) {
                                                    themeManager.mode = mode
                                                }
                                            }
                                        }

                                        if index < ThemeMode.allCases.count - 1 {
                                            SettingsDivider()
                                        }
                                    }
                                }
                            }

                            SettingsGroupCard {
                                VStack(spacing: 0) {
                                    SettingsToggleRow(
                                        title: "Notifications",
                                        subtitle: "Allow calm reminders from ayo.",
                                        leadingIcon: "bell.badge",
                                        isOn: Binding(
                                            get: { notificationManager.notificationsEnabled },
                                            set: { newValue in
                                                Task {
                                                    await notificationManager.setNotificationsEnabled(newValue)
                                                }
                                            }
                                        )
                                    )

                                    SettingsDivider()

                                    SettingsToggleRow(
                                        title: "Daily reminder",
                                        subtitle: "Repeat the daily smoke-free check-in reminder.",
                                        leadingIcon: "calendar.badge.clock",
                                        isOn: Binding(
                                            get: { notificationManager.notificationsEnabled && notificationManager.dailyReminderEnabled },
                                            set: { newValue in
                                                Task {
                                                    await notificationManager.setDailyReminderEnabled(newValue)
                                                }
                                            }
                                        )
                                    )
                                    .disabled(!notificationManager.notificationsEnabled)
                                    .opacity(notificationManager.notificationsEnabled ? 1 : 0.6)
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .clipped()
        }
        .navigationTitle("App Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.visible, for: .navigationBar)
        .fullScreenCover(isPresented: $showingPaywall) {
            PaywallView(onClose: { showingPaywall = false })
                .presentationBackground(.clear)
        }
    }
}

private struct SettingsToggleRow: View {
    let title: String
    let subtitle: String
    let leadingIcon: String
    @Binding var isOn: Bool

    var body: some View {
        SettingsRow(
            title: title,
            subtitle: subtitle,
            leadingIcon: leadingIcon
        ) {
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color.buttonBottom)
        }
    }
}

private struct SettingsHeaderMetric: View {
    let metric: SettingsHeroMetric

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: metric.symbol)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.heroAccent)
                .frame(width: 28, height: 28)
                .background(Color.cardBackground.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 2) {
                Text(metric.value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.ink)
                    .lineLimit(1)

                Text(metric.label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.heroSecondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, 10)
        .background(Color.cardBackground.opacity(0.52))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

private struct SettingsDetailContainer<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.section) {
            content
        }
        .padding(.horizontal, AppSpacing.lg)
        .padding(.top, AppSpacing.xl)
        .padding(.bottom, AppSpacing.xxl)
    }
}

private struct SettingsNavigationRow: View {
    let title: String
    let subtitle: String?
    let icon: String?

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.accentInk)
                    .frame(width: 28, height: 28)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color.accentWash.opacity(0.88), Color.surfaceElevated.opacity(0.76)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .stroke(Color.border.opacity(0.38), lineWidth: 0.85)
                    )
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ink)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(Color.secondaryText)
                .frame(width: 12, alignment: .trailing)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}

private struct SettingsTitleText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.system(size: 19, weight: .semibold, design: .rounded))
            .foregroundStyle(Color.ink)
            .multilineTextAlignment(.leading)
    }
}

private struct SettingsSupportingText: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(Color.secondaryText)
            .lineSpacing(3)
            .multilineTextAlignment(.leading)
            .fixedSize(horizontal: false, vertical: true)
    }
}

private struct SettingsMotivationHeader: View {
    let reasonCount: Int

    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            ZStack {
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentWash, Color.surfaceElevated.opacity(0.92)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Image(systemName: "heart.text.square")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.accentInk)
            }
            .frame(width: 42, height: 42)
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.border.opacity(0.62), lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Reasons that matter to you")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text("These appear again in rescue moments, so a few short reasons are enough.")
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)

            Text("\(reasonCount)/3")
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.buttonBottom)
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.18), Color.accentWash.opacity(0.86)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(Color.borderStrong.opacity(0.45), lineWidth: 1)
                )
        }
    }
}

private struct MotivationReasonCard: View {
    let reason: String
    let onRemove: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Saved for later")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.0)

                Text(reason)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()

            Button(action: onRemove) {
                Label("Remove", systemImage: "xmark")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .labelStyle(.iconOnly)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.surfaceElevated, Color.inputBackground.opacity(0.9)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        Circle()
                            .stroke(Color.border.opacity(0.75), lineWidth: 1)
                    )
            }
            .accessibilityLabel("Remove reason")
            .buttonStyle(SecondaryButtonStyle())
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 15)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.cardSecondary.opacity(0.96), Color.surfaceElevated.opacity(0.74)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.border.opacity(0.7), Color.borderStrong.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: Color.shadowColor.opacity(0.04), radius: 8, x: 0, y: 4)
    }
}

private struct SettingsAppearanceOptionRow: View {
    let mode: ThemeMode
    let isSelected: Bool
    let isLocked: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.md) {
                VStack(alignment: .leading, spacing: AppSpacing.xs) {
                    Text(mode.title)
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .foregroundStyle(isSelected ? Color.buttonBottom : Color.ink)

                    Text(isLocked ? "Premium feature" : mode.subtitle)
                        .font(.caption)
                        .foregroundStyle(isSelected ? Color.accentInk : Color.secondaryText)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                ZStack {
                    if isLocked {
                        Image(systemName: "lock.fill")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.secondaryText)
                            .frame(width: 28, height: 28)
                            .background(Color.surfaceMuted)
                            .clipShape(Circle())
                    } else {
                        Circle()
                            .fill(isSelected ? Color.buttonBottom : Color.surfaceMuted)
                            .frame(width: 28, height: 28)
                            .overlay(
                                Circle()
                                    .stroke(isSelected ? Color.buttonBottom.opacity(0.18) : Color.border.opacity(0.65), lineWidth: isSelected ? 6 : 1)
                            )

                        if isSelected {
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.white)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        isSelected
                            ? AnyShapeStyle(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.22),
                                        Color.buttonBottom.opacity(0.16),
                                        Color.accentWash.opacity(0.72)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            : AnyShapeStyle(Color.clear)
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(
                        isSelected ? Color.borderStrong.opacity(0.72) : Color.clear,
                        lineWidth: 1
                    )
            )
            .shadow(color: isSelected ? Color.buttonBottom.opacity(0.1) : Color.clear, radius: 10, x: 0, y: 7)
            .shadow(color: isSelected ? Color.white.opacity(0.12) : Color.clear, radius: 1, x: 0, y: 1)
            .contentShape(Rectangle())
            .animation(.easeInOut(duration: 0.2), value: isSelected)
        }
        .buttonStyle(SettingsSelectionButtonStyle(isSelected: isSelected))
    }
}

private struct MotivationEmptyStateCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text("Nothing saved yet")
                .font(.system(size: 17, weight: .semibold, design: .rounded))
                .foregroundStyle(Color.ink)

            Text("Add a few short reasons like your health, your future, or the people you want to show up for.")
                .font(.footnote)
                .foregroundStyle(Color.secondaryText)
                .lineSpacing(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 15)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.surfaceMuted.opacity(0.95), Color.accentWash.opacity(0.54)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .stroke(Color.border.opacity(0.58), lineWidth: 1)
        )
    }
}

private struct SettingsSection<Content: View>: View {
    let title: String
    var subtitle: String?
    @ViewBuilder let content: Content

    init(title: String, subtitle: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(title)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.3)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(2)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct SettingsGroupCard<Content: View>: View {
    private let cornerRadius: CGFloat
    private let fill: AnyShapeStyle
    private let verticalPadding: CGFloat
    private let topHighlightOpacity: Double
    private let shadowOpacity: Double
    @ViewBuilder let content: Content

    init(
        fill: AnyShapeStyle = AnyShapeStyle(Color.cardBackground),
        cornerRadius: CGFloat = 28,
        verticalPadding: CGFloat = 8,
        topHighlightOpacity: Double = 0.16,
        shadowOpacity: Double = 0.07,
        @ViewBuilder content: () -> Content
    ) {
        self.fill = fill
        self.cornerRadius = cornerRadius
        self.verticalPadding = verticalPadding
        self.topHighlightOpacity = topHighlightOpacity
        self.shadowOpacity = shadowOpacity
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, verticalPadding)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(fill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [Color.borderStrong.opacity(0.56), Color.border.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 0.85
                    )
            )
            .overlay(alignment: .top) {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(topHighlightOpacity), Color.clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .frame(height: 16)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .inset(by: 1)
                    .stroke(Color.white.opacity(0.035), lineWidth: 0.75)
            }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: Color.shadowColor.opacity(shadowOpacity), radius: 9, x: 0, y: 4)
            .shadow(color: Color.onboardingShadow.opacity(shadowOpacity * 0.38), radius: 14, x: 0, y: 6)
    }
}

private enum SettingsRowRole {
    case normal
    case destructive
}

private enum SettingsRowDensity {
    case regular
    case compact
}

private struct SettingsRow<Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    var leadingIcon: String? = nil
    var role: SettingsRowRole = .normal
    var density: SettingsRowDensity = .regular
    var showsChevron: Bool = false
    var action: (() -> Void)? = nil
    @ViewBuilder var trailing: () -> Trailing

    init(
        title: String,
        subtitle: String? = nil,
        leadingIcon: String? = nil,
        role: SettingsRowRole = .normal,
        density: SettingsRowDensity = .regular,
        showsChevron: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder trailing: @escaping () -> Trailing = { EmptyView() }
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leadingIcon = leadingIcon
        self.role = role
        self.density = density
        self.showsChevron = showsChevron
        self.action = action
        self.trailing = trailing
    }

    var body: some View {
        Group {
            if let action {
                Button(action: action) {
                    rowBody
                }
                .buttonStyle(SettingsRowPressButtonStyle(role: role))
            } else {
                rowBody
            }
        }
    }

    private var rowBody: some View {
        HStack(alignment: subtitle == nil ? .center : .top, spacing: AppSpacing.md) {
            if let leadingIcon {
                Image(systemName: leadingIcon)
                    .font(.system(size: density == .compact ? 13 : 14, weight: .semibold))
                    .foregroundStyle(role == .destructive ? Color.buttonBottom.opacity(0.9) : Color.accentInk)
                    .frame(width: density == .compact ? 28 : 30, height: density == .compact ? 28 : 30)
                    .background(
                        RoundedRectangle(cornerRadius: density == .compact ? 9 : 10, style: .continuous)
                            .fill(
                                role == .destructive
                                    ? AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.buttonBottom.opacity(0.08), Color.heroTop.opacity(0.32)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    : AnyShapeStyle(
                                        LinearGradient(
                                            colors: [Color.accentWash.opacity(0.88), Color.surfaceElevated.opacity(0.76)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: density == .compact ? 9 : 10, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: density == .compact ? 9 : 10, style: .continuous)
                            .stroke(
                                role == .destructive ? Color.buttonBottom.opacity(0.12) : Color.border.opacity(0.38),
                                lineWidth: 0.85
                            )
                    )
            }

            VStack(alignment: .leading, spacing: density == .compact ? 4 : AppSpacing.xs) {
                Text(title)
                    .font(.system(size: density == .compact ? 15.5 : 17, weight: density == .compact && subtitle == nil ? .medium : .semibold, design: .rounded))
                    .foregroundStyle(role == .destructive ? Color.buttonBottom : Color.ink)

                if let subtitle, !subtitle.isEmpty {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(role == .destructive ? Color.buttonBottom.opacity(0.72) : Color.secondaryText)
                        .lineSpacing(1)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Spacer(minLength: 0)

            trailing()

            if showsChevron {
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(role == .destructive ? Color.buttonBottom.opacity(0.78) : Color.secondaryText)
                    .frame(width: 12, alignment: .trailing)
            }
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, density == .compact ? 11 : 14)
        .contentShape(Rectangle())
    }
}

private struct SettingsInfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color.textMuted)
                .textCase(.uppercase)
                .tracking(0.8)

            Spacer(minLength: 0)

            Text(value)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.ink)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, 10)
    }
}

private struct SettingsHeroMetric: Identifiable {
    let id = UUID()
    let value: String
    let label: String
    let symbol: String
}

private struct SettingsHeroCard: View {
    private let cornerRadius: CGFloat = 30
    let title: String
    let subtitle: String
    let supportingLine: String
    let accentLabel: String
    let metrics: [SettingsHeroMetric]

    var body: some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.cardBackground.opacity(0.99),
                            Color.heroTop.opacity(0.78),
                            Color.heroBottom.opacity(0.48)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.06), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(1.25)

            Circle()
                .fill(Color.buttonBottom.opacity(0.08))
                .frame(width: 120, height: 120)
                .blur(radius: 18)
                .offset(x: 32, y: -24)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.08), lineWidth: 0.8)
                .padding(1)

            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                HStack(alignment: .top, spacing: AppSpacing.lg) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(accentLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom.opacity(0.9))
                            .textCase(.uppercase)
                            .tracking(1.1)

                        Text(title)
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .lineSpacing(1)
                            .multilineTextAlignment(.leading)

                        Text(subtitle)
                            .font(.footnote)
                            .foregroundStyle(Color.heroSecondaryText.opacity(0.94))
                            .lineSpacing(2)
                            .lineLimit(3)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    SettingsHeroAccent()
                }

                HStack(spacing: AppSpacing.sm) {
                    ForEach(metrics) { metric in
                        SettingsHeroMetricCard(metric: metric)
                    }
                }

                Text(supportingLine)
                    .font(.footnote)
                    .foregroundStyle(Color.helperText.opacity(0.92))
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.vertical, 24)
        }
        .overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(
                    LinearGradient(
                        colors: [Color.borderStrong.opacity(0.7), Color.border.opacity(0.22)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 0.95
                )
        )
        .overlay(alignment: .top) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.18), Color.clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: 28)
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .overlay(alignment: .bottom) {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.clear, Color.ink.opacity(0.03)],
                        startPoint: .center,
                        endPoint: .bottom
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .shadow(color: Color.shadowColor.opacity(0.07), radius: 18, x: 0, y: 10)
        .shadow(color: Color.buttonBottom.opacity(0.04), radius: 22, x: 0, y: 10)
    }
}

private struct SettingsHeroAccent: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.buttonTop.opacity(0.94), Color.buttonBottom.opacity(0.88)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            Image(systemName: "slider.horizontal.3")
                .font(.headline.weight(.bold))
                .foregroundStyle(Color.white.opacity(0.97))
        }
        .frame(width: 48, height: 48)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(Color.white.opacity(0.16), lineWidth: 1)
        )
        .shadow(color: Color.buttonBottom.opacity(0.12), radius: 10, x: 0, y: 6)
    }
}

private struct SettingsHeroMetricCard: View {
    let metric: SettingsHeroMetric

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .center, spacing: 6) {
                Image(systemName: metric.symbol)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.buttonBottom.opacity(0.9))

                Text(metric.label)
                    .font(.caption)
                    .foregroundStyle(Color.secondaryText)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            Text(metric.value)
                .font(.system(size: 19, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color.white.opacity(0.26), Color.surfaceElevated.opacity(0.42)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.border.opacity(0.62), lineWidth: 0.9)
        )
    }
}

private struct SettingsDivider: View {
    var leadingInset: CGFloat = AppSpacing.md

    var body: some View {
        Divider()
            .overlay(Color.divider.opacity(0.74))
            .padding(.leading, leadingInset)
    }
}

private struct SettingsSelectionButtonStyle: ButtonStyle {
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.982 : 1)
            .opacity(configuration.isPressed ? 0.94 : 1)
            .brightness(configuration.isPressed ? -0.02 : (isSelected ? 0.012 : 0))
            .shadow(
                color: isSelected ? Color.buttonBottom.opacity(configuration.isPressed ? 0.08 : 0.14) : Color.clear,
                radius: configuration.isPressed ? 8 : 12,
                x: 0,
                y: configuration.isPressed ? 4 : 8
            )
            .animation(.easeInOut(duration: 0.16), value: configuration.isPressed)
            .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

private struct SettingsRowPressButtonStyle: ButtonStyle {
    let role: SettingsRowRole

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(
                        configuration.isPressed
                            ? (role == .destructive ? Color.buttonBottom.opacity(0.08) : Color.surfaceElevated.opacity(0.68))
                            : Color.clear
                    )
            )
            .scaleEffect(configuration.isPressed ? 0.986 : 1)
            .brightness(configuration.isPressed ? -0.015 : 0)
            .animation(.easeInOut(duration: 0.14), value: configuration.isPressed)
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppState())
        .environmentObject(AuthManager())
        .environmentObject(OnboardingManager())
        .environmentObject(ThemeManager())
}
