import SwiftUI
import RevenueCat

struct OnboardingView: View {
    private enum NavigationDirection {
        case forward
        case backward
    }

    private enum Field {
        case name
        case weeklySpending
        case motivation
    }

    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var onboardingManager: OnboardingManager
    @EnvironmentObject private var subscriptionManager: SubscriptionManager
    @FocusState private var focusedField: Field?
    @State private var navigationDirection: NavigationDirection = .forward
    @State private var feedbackMessage: String?
    @State private var feedbackStep: OnboardingStep?
    @State private var feedbackTask: Task<Void, Never>?
    @State private var animatedYearlySpend: Double = 0
    @State private var yearlySpendTask: Task<Void, Never>?
    @State private var planGenerationProgress: Int = 0
    @State private var planGenerationTask: Task<Void, Never>?
    @State private var animatedPlanSavings: Double = 0
    @State private var animatedAvoidedPurchases: Double = 0
    @State private var planRevealAnimationTask: Task<Void, Never>?
    @State private var planRevealMetricsVisible = false
    @State private var animatedSavingsReminder: Double = 0
    @State private var savingsReminderTask: Task<Void, Never>?
    @State private var planGenerationPulse = false
    @State private var planRevealVisibleSections = 0
    @State private var onboardingPaywallSelectedPackageID: String?
    @State private var onboardingPaywallLoaded = false

    private let goalOptions = [
        ("Protect my health", "Feel physically better and stop carrying the cost.", "heart.fill"),
        ("Get my freedom back", "Reduce autopilot cravings and feel more in control.", "bird.fill"),
        ("Save real money", "Turn this habit into visible savings each week.", "dollarsign.circle.fill"),
        ("Prove I can do this", "Build trust in myself again.", "sparkles")
    ]

    private let paceOptions = [
        ("Steady reset", "A calm structure with consistent support.", "figure.walk"),
        ("Gentle ramp-down", "Less pressure, more flexibility, still moving forward.", "wind"),
        ("Fast intervention", "A stronger plan for urgent change.", "bolt.fill")
    ]

    private let concernOptions = [
        (title: "Stress at work", shortTitle: "Stress", icon: "briefcase.fill"),
        (title: "Coffee and routines", shortTitle: "Coffee", icon: "cup.and.saucer.fill"),
        (title: "Social situations", shortTitle: "Social", icon: "person.2.fill"),
        (title: "Evening cravings", shortTitle: "Evening", icon: "moon.stars.fill"),
        (title: "Fear of failing again", shortTitle: "Failure", icon: "exclamationmark.shield.fill"),
        (title: "Irritability", shortTitle: "Mood", icon: "flame.fill"),
        (title: "Low energy", shortTitle: "Energy", icon: "battery.25"),
        (title: "Doing it alone", shortTitle: "Alone", icon: "figure.stand")
    ]

    var body: some View {
        ZStack {
            AppBackground()

            currentStepScreen
                .id(onboardingManager.currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(OnboardingPageTransition.transition(forward: navigationDirection == .forward))
        }
        .animation(OnboardingPageTransition.animation, value: onboardingManager.currentStep)
        .onChange(of: onboardingManager.currentStep) { step in
            debugPrint("[Onboarding] current step changed -> \(stepLabelForDebug(step))")
            feedbackTask?.cancel()
            feedbackMessage = nil
            feedbackStep = nil

            if step != .planGeneration {
                planGenerationTask?.cancel()
                planGenerationPulse = false
            }

            if step != .consumption {
                yearlySpendTask?.cancel()
            }

            if step != .planReveal {
                planRevealAnimationTask?.cancel()
                planRevealVisibleSections = 0
            }

            if step != .savingsReminder {
                savingsReminderTask?.cancel()
            }

            if step == .paywall {
                syncOnboardingPaywallSelection()
                if !onboardingPaywallLoaded {
                    onboardingPaywallLoaded = true
                    Task {
                        await subscriptionManager.loadOfferings()
                        syncOnboardingPaywallSelection()
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var currentStepScreen: some View {
        switch onboardingManager.currentStep {
        case .welcome:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Welcome",
                title: "A calmer way to stop nicotine.",
                subtitle: "",
                primaryButtonTitle: "Start",
                primaryButtonEnabled: true,
                showsBackButton: false,
                onContinue: continueForward
            ) {
                welcomeContent
            }

        case .name:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Name",
                title: "What should we call you?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                nameContent
            }

        case .consumption:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Consumption",
                title: trimmedName.isEmpty ? "How much do you spend in a typical week?" : "How much do you spend in a typical week, \(trimmedName)?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                consumptionContent
            }

        case .goal:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Goal",
                title: trimmedName.isEmpty ? "What matters most right now?" : "What matters most for you, \(trimmedName)?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                selectionList(goalOptions, selection: onboardingManager.state.goal) { selected in
                    onboardingManager.state.goal = selected
                }
            }

        case .pace:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Pace",
                title: "What kind of pace feels right?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                selectionList(paceOptions, selection: onboardingManager.state.pace) { selected in
                    onboardingManager.state.pace = selected
                }
            }

        case .motivation:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Motivation",
                title: "What do you want to protect or get back?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                motivationContent
            }

        case .concerns:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Concerns",
                title: "What feels most likely to make this hard?",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                concernsContent
            }

        case .planGeneration:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Plan",
                title: trimmedName.isEmpty ? "We have enough to shape your first plan." : "We have enough to shape your plan, \(trimmedName).",
                subtitle: "",
                primaryButtonTitle: planGenerationProgress < 100 ? "Creating..." : "Reveal plan",
                primaryButtonEnabled: canContinue,
                onBack: goBack,
                onContinue: continueForward
            ) {
                planGenerationContent
            }

        case .planReveal:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Plan Reveal",
                title: trimmedName.isEmpty ? "Your first plan" : "\(trimmedName), your first plan.",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                planRevealContent
            }

        case .planReady:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Plan Ready",
                title: "Your personal plan is ready.",
                subtitle: "",
                primaryButtonTitle: "Start my plan",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                planReadyContent
            }

        case .value:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Value",
                title: "What you unlock",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                valueContent
            }

        case .savingsReminder:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Savings",
                title: trimmedName.isEmpty ? "Here is what this could mean financially." : "\(trimmedName), here is what this could mean financially.",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                savingsReminderContent
            }

        case .paywall:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Membership",
                title: trimmedName.isEmpty ? "Begin the full journey." : "Begin the full journey, \(trimmedName).",
                subtitle: "",
                primaryButtonTitle: "Start free trial",
                primaryButtonEnabled: true,
                showsPrimaryButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                paywallContent
            }

        case .exitOffer:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.allCases.count,
                stepLabel: stepLabel,
                eyebrow: "Before You Go",
                title: "Before you go...",
                subtitle: "",
                primaryButtonTitle: "Claim limited offer",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                exitOfferContent
            }
        }
    }

    private var welcomeContent: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.56))
                    .frame(width: 136, height: 136)
                    .shadow(color: Color.shadowColor.opacity(0.08), radius: 24, x: 0, y: 18)

                Image(systemName: "wind")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(Color(red: 0.47, green: 0.29, blue: 0.90))
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 10)

            CardSection(fill: AnyShapeStyle(Color.white.opacity(0.78))) {
                VStack(alignment: .leading, spacing: 12) {
                    onboardingPoint("Short setup", "Takes about two minutes.")
                    onboardingPoint("Resumable", "Your place is saved automatically.")
                    onboardingPoint("Personalized", "Support adapts to your pace and pressure points.")
                }
            }
            .softEntrance(delay: 0.04, distance: 16)
        }
    }

    private var nameContent: some View {
        VStack(spacing: 16) {
            CardSection {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Your name")
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    OnboardingInputField(
                        placeholder: "Enter your name",
                        text: nameBinding,
                        isFocused: focusedField == .name,
                        textAlignment: .leading
                    )
                    .focused($focusedField, equals: .name)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()

                    Text("You can change this later.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                }
            }

            if !trimmedName.isEmpty {
                CardSection(fill: AnyShapeStyle(Color.white.opacity(0.72))) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nice to meet you, \(trimmedName).")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("We are going to make this feel more like a guided reset than a cold checklist.")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                            .lineSpacing(3)
                    }
                }
                .softEntrance(delay: 0.02, distance: 12)
            }
        }
    }

    private var consumptionContent: some View {
        VStack(spacing: 18) {
            CardSection {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Weekly spending")
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    OnboardingInputField(
                        placeholder: "35",
                        text: weeklySpendingText,
                        isFocused: focusedField == .weeklySpending,
                        keyboardType: .decimalPad
                    )
                    .focused($focusedField, equals: .weeklySpending)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("About \(estimatedMonthlySpendText) per month")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))

                        Text("About \(estimatedYearlySpendText) per year")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }
            .onAppear {
                startYearlySpendReveal()
            }
            .onChange(of: onboardingManager.state.weeklySpending) { _ in
                startYearlySpendReveal()
            }

            CardSection(fill: AnyShapeStyle(Color.white.opacity(0.7))) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick adjust")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)

                    Slider(value: weeklySpendingBinding, in: 0...280, step: 5)
                        .tint(Color(red: 0.47, green: 0.29, blue: 0.90))
                }
            }

            if onboardingManager.state.weeklySpending > 0 {
                CardSection(fill: AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), Color(red: 0.95, green: 0.93, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(trimmedName.isEmpty ? "This adds up fast." : "\(trimmedName), this adds up fast.")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                            .textCase(.uppercase)
                            .tracking(1.1)

                        Text("You currently spend about")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)

                        Text(animatedYearlySpend.formatted(.currency(code: currencyCode)))
                            .font(.system(size: 40, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)
                            .contentTransition(.numericText(value: animatedYearlySpend))
                            .monospacedDigit()

                        Text("per year on nicotine.")
                            .font(.title3.weight(.semibold))
                            .foregroundStyle(Color.ink)

                        Text("Seeing the yearly number makes the plan feel real. We will use this to frame savings and momentum throughout the app.")
                            .font(.footnote)
                            .foregroundStyle(Color.secondaryText)
                            .lineSpacing(3)
                    }
                }
                .softEntrance(delay: 0.04, distance: 12, animation: MicroAnimation.supportiveReveal)
            }
        }
    }

    private var motivationContent: some View {
        VStack(spacing: 16) {
            CardSection {
                VStack(alignment: .leading, spacing: 14) {
                    Text("Your reason")
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    OnboardingInputField(
                        placeholder: "Enter your reason",
                        text: motivationBinding,
                        isFocused: focusedField == .motivation,
                        axis: .vertical,
                        textAlignment: .leading
                    )
                    .focused($focusedField, equals: .motivation)

                    Text("Example: I want to stop feeling controlled by cravings when I am stressed.")
                        .font(.footnote)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(3)
                }
            }

            if !trimmedMotivation.isEmpty {
                confirmationBadge(text: "Saved as part of your plan.")
            }
        }
    }

    private var concernsContent: some View {
        VStack(spacing: 12) {
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 10), count: 4),
                spacing: 10
            ) {
                ForEach(concernOptions, id: \.title) { concern in
                    ConcernOptionTile(
                        title: concern.shortTitle,
                        icon: concern.icon,
                        isSelected: onboardingManager.state.concerns.contains(concern.title)
                    ) {
                        toggleConcern(concern.title)
                        showFeedback("Saved")
                    }
                }
            }

            if let feedback = currentFeedbackMessage {
                confirmationBadge(text: feedback)
            }
        }
    }

    private var planGenerationContent: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.white.opacity(0.98), Color(red: 0.93, green: 0.91, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 18) {
                HStack(spacing: 10) {
                    Circle()
                        .fill(Color(red: 0.46, green: 0.25, blue: 0.90))
                        .frame(width: 10, height: 10)
                        .scaleEffect(planGenerationPulse ? 1.28 : 0.92)
                        .opacity(planGenerationPulse ? 1 : 0.55)
                        .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: planGenerationPulse)

                    Text("Creating your personal plan...")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)
                }

                Text("We are balancing your goal, likely trigger moments, weekly spend, and the pace that feels sustainable.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(3)

                HStack(alignment: .lastTextBaseline, spacing: 8) {
                    Text("\(planGenerationProgress)%")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                        .contentTransition(.numericText(value: Double(planGenerationProgress)))
                        .monospacedDigit()

                    Text("complete")
                        .font(.headline)
                        .foregroundStyle(Color.secondaryText)
                }

                GeometryReader { proxy in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.56))

                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.62, green: 0.45, blue: 0.99), Color(red: 0.46, green: 0.25, blue: 0.90)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: proxy.size.width * (Double(planGenerationProgress) / 100))
                    }
                }
                .frame(height: 12)

                VStack(alignment: .leading, spacing: 10) {
                    generationLine("Reading your motivation", isActive: planGenerationProgress >= 18)
                    generationLine("Estimating yearly nicotine cost", isActive: planGenerationProgress >= 46)
                    generationLine("Tuning rescue support to your concerns", isActive: planGenerationProgress >= 72)
                    generationLine("Finalizing your first path", isActive: planGenerationProgress >= 100)
                }
            }
        }
        .onAppear {
            startPlanGeneration()
            planGenerationPulse = true
        }
    }

    private var planRevealContent: some View {
        VStack(spacing: 12) {
            if planRevealVisibleSections >= 1 {
                CardSection(fill: AnyShapeStyle(
                    LinearGradient(
                        colors: [Color.white.opacity(0.98), Color(red: 0.95, green: 0.94, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )) {
                    VStack(alignment: .leading, spacing: 12) {
                        ConversationalRevealText(
                            text: planRevealHeadline,
                            startDelay: 0.1,
                            chunkDelay: 0.8,
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

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(planRevealBullets, id: \.self) { bullet in
                                compactPlanBullet(bullet)
                            }
                        }
                    }
                }
                .transition(.opacity.combined(with: .offset(y: 14)))
            }

            if planRevealVisibleSections >= 2 {
                CardSection(fill: AnyShapeStyle(Color.white.opacity(0.82))) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("First-year estimate")
                            .font(.headline)
                            .foregroundStyle(Color.ink)

                        if planRevealVisibleSections >= 3 {
                            HStack(spacing: 14) {
                                planRevealStatCard(
                                    title: "Estimated savings",
                                    value: animatedPlanSavings.formatted(.currency(code: currencyCode))
                                )

                                planRevealStatCard(
                                    title: "Avoided purchases",
                                    value: "\(Int(animatedAvoidedPurchases))"
                                )
                            }
                            .transition(.opacity.combined(with: .offset(y: 12)))
                        }
                    }
                }
                .transition(.opacity.combined(with: .offset(y: 16)))
            }
        }
        .onAppear {
            startPlanRevealAnimation()
        }
    }

    private var planReadyContent: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.white.opacity(0.98), Color(red: 0.94, green: 0.94, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Your personal plan is ready.")
                    .font(.system(size: 30, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)

                Text(trimmedName.isEmpty
                    ? "From here, the app will guide you through cravings, progress, and the hard moments that usually derail momentum."
                    : "From here, the app will guide you through cravings, progress, and the hard moments that usually derail momentum for you.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(4)

                onboardingPoint("Guided support", "The app keeps translating your answers into daily support.")
                onboardingPoint("Rescue when it matters", "You get practical help exactly when the urge peaks.")
                onboardingPoint("Progress that feels real", "Savings, streaks, and recovery stay visible.")
            }
        }
    }

    private var valueContent: some View {
        LazyVGrid(
            columns: [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)],
            spacing: 12
        ) {
            valueTile(title: "Rescue", subtitle: "Fast help", symbol: "cross.case.fill")
            valueTile(title: "Progress", subtitle: "See momentum", symbol: "chart.line.uptrend.xyaxis")
            valueTile(title: "Plan", subtitle: "Made for you", symbol: "person.crop.circle.badge.checkmark")
            valueTile(title: "Support", subtitle: "Stay motivated", symbol: "sparkles.rectangle.stack.fill")
        }
    }

    private var savingsReminderContent: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.white.opacity(0.99), Color(red: 0.92, green: 0.96, blue: 0.94)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 16) {
                Text("You could save")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)

                Text(animatedSavingsReminder.formatted(.currency(code: currencyCode)))
                    .font(.system(size: 54, weight: .bold, design: .rounded))
                    .foregroundStyle(Color(red: 0.82, green: 0.20, blue: 0.24))
                    .contentTransition(.numericText(value: animatedSavingsReminder))
                    .monospacedDigit()
                    .minimumScaleFactor(0.9)
                    .lineLimit(1)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .multilineTextAlignment(.center)

                Text("this year.")
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(Color.ink)
                    .frame(maxWidth: .infinity, alignment: .center)

                Text("That number is not abstract. It is money that could stay with you instead of feeding the loop you are trying to leave behind.")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(4)
            }
        }
        .onAppear {
            startSavingsReminderAnimation()
        }
    }

    private var paywallContent: some View {
        VStack(spacing: 18) {
            PaywallGlowOrb()
                .padding(.top, 4)

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.97), Color(red: 0.95, green: 0.93, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 20) {
                    PaywallBenefitsList(
                        benefits: [
                            PaywallBenefit(icon: "chart.line.uptrend.xyaxis", title: "Track your real progress"),
                            PaywallBenefit(icon: "rosette", title: "Unlock all achievements"),
                            PaywallBenefit(icon: "checkmark.shield", title: "Stay accountable every day"),
                            PaywallBenefit(icon: "sparkles", title: "Build a habit that lasts")
                        ]
                    )

                    onboardingPaywallPackagesSection

                    if let selectedPackage = selectedOnboardingPaywallPackage {
                        PaywallPriceCard(
                            priceText: onboardingPaywallPriceText(for: selectedPackage),
                            supportingText: onboardingPaywallSupportingText(for: selectedPackage)
                        )
                    } else if subscriptionManager.isLoadingOfferings {
                        PaywallPriceCard(priceText: "Loading...", supportingText: "Checking plans")
                            .redacted(reason: .placeholder)
                    }

                    OnboardingPrimaryButton(
                        title: subscriptionManager.purchasingPackageID == selectedOnboardingPaywallPackage?.storeProduct.productIdentifier
                            ? "Starting..."
                            : "Start free trial",
                        isEnabled: selectedOnboardingPaywallPackage != nil && !onboardingPaywallIsBusy,
                        action: startOnboardingPaywallPurchase
                    )

                    Button {
                        restoreOnboardingPaywallPurchases()
                    } label: {
                        Text(subscriptionManager.isRestoringPurchases ? "Restoring..." : "Restore purchases")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.secondaryText)
                    }
                    .disabled(onboardingPaywallIsBusy)
                    .buttonStyle(SecondaryButtonStyle(isEnabled: !onboardingPaywallIsBusy))

                    if let errorMessage = subscriptionManager.errorMessage {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(Color.secondaryText)
                                .lineSpacing(3)

                            Button("Try again") {
                                Task {
                                    await subscriptionManager.loadOfferings()
                                    syncOnboardingPaywallSelection()
                                }
                            }
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(Color.buttonBottom)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 14)
                        .background(Color.surfaceElevated)
                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18, style: .continuous)
                                .stroke(Color.border, lineWidth: 1)
                        )
                    }

                    VStack(spacing: 6) {
                        Text("Cancel anytime")
                        Text("No commitment")
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(Color.secondaryText)
                    .frame(maxWidth: .infinity)
                }
            }

            Button {
                navigationDirection = .forward
                debugPrint("[Onboarding] Paywall skipped via Not now -> exit offer")
                withAnimation(OnboardingPageTransition.animation) {
                    onboardingManager.goToStep(.exitOffer)
                }
            } label: {
                Text("Not now")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private var selectedOnboardingPaywallPackage: Package? {
        if let onboardingPaywallSelectedPackageID {
            return subscriptionManager.availablePackages.first(where: { $0.storeProduct.productIdentifier == onboardingPaywallSelectedPackageID })
        }
        return subscriptionManager.monthlyPackage ?? subscriptionManager.annualPackage ?? subscriptionManager.availablePackages.first
    }

    private var onboardingPaywallIsBusy: Bool {
        subscriptionManager.isLoadingOfferings || subscriptionManager.isRestoringPurchases || subscriptionManager.purchasingPackageID != nil
    }

    @ViewBuilder
    private var onboardingPaywallPackagesSection: some View {
        if !subscriptionManager.availablePackages.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Text("Choose your plan")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
                    .textCase(.uppercase)
                    .tracking(1.1)

                VStack(spacing: 10) {
                    ForEach(subscriptionManager.availablePackages, id: \.storeProduct.productIdentifier) { package in
                        onboardingPaywallPackageRow(package)
                    }
                }
            }
        }
    }

    private func onboardingPaywallPackageRow(_ package: Package) -> some View {
        let isSelected = selectedOnboardingPaywallPackage?.storeProduct.productIdentifier == package.storeProduct.productIdentifier

        return Button {
            onboardingPaywallSelectedPackageID = package.storeProduct.productIdentifier
            subscriptionManager.clearError()
            debugPrint("[Onboarding Paywall] selected package id: \(package.storeProduct.productIdentifier)")
        } label: {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(onboardingPaywallTitle(for: package))
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text(package.storeProduct.localizedPriceString)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                }

                Spacer()

                if package.packageType == .annual {
                    Text("Best value")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(Color.buttonBottom)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.buttonBottom.opacity(0.12))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.buttonBottom.opacity(0.08) : Color.surface)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.buttonBottom.opacity(0.34) : Color.border, lineWidth: isSelected ? 1.3 : 1)
            )
        }
        .buttonStyle(CardPressButtonStyle())
    }

    private var exitOfferContent: some View {
        VStack(spacing: 16) {
            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.98), Color(red: 0.99, green: 0.94, blue: 0.90)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("A softer way to begin")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(Color.ink)

                    Text("Start today with 50% off your first month after the free trial. That gives your plan more time to become a real habit, not just a good intention.")
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(4)

                    HStack(spacing: 12) {
                        statPill(title: "Free trial", value: "7 days")
                        statPill(title: "Then", value: "$2.49")
                    }
                }
            }

            Button {
                completeOnboarding()
            } label: {
                Text("Continue without trial")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)
            }
            .buttonStyle(SecondaryButtonStyle())
        }
    }

    private func selectionList(
        _ options: [(String, String, String)],
        selection: String?,
        onSelect: @escaping (String) -> Void
    ) -> some View {
        VStack(spacing: 10) {
            ForEach(options, id: \.0) { option in
                SelectionCard(
                    title: option.0,
                    subtitle: option.1,
                    icon: option.2,
                    isSelected: selection == option.0
                ) {
                    onSelect(option.0)
                    showFeedback("Good choice")
                }
            }

            if let feedback = currentFeedbackMessage {
                confirmationBadge(text: feedback)
            }
        }
    }

    private func onboardingPoint(_ title: String, _ subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func planRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                .textCase(.uppercase)
                .tracking(1.1)

            Text(value)
                .font(.headline)
                .foregroundStyle(Color.ink)
        }
    }

    private func generationLine(_ text: String, isActive: Bool) -> some View {
        HStack(spacing: 10) {
            Image(systemName: isActive ? "checkmark.circle.fill" : "circle.dashed")
                .foregroundStyle(isActive ? Color(red: 0.47, green: 0.29, blue: 0.90) : Color.secondaryText.opacity(0.7))

            Text(text)
                .font(.subheadline)
                .foregroundStyle(isActive ? Color.ink : Color.secondaryText)
        }
        .animation(OnboardingPageTransition.animation, value: isActive)
    }

    private func confirmationBadge(text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color(red: 0.47, green: 0.29, blue: 0.90))

            Text(text)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.72))
        .clipShape(Capsule())
        .transition(.opacity.combined(with: .offset(y: 8)))
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 14)
        .padding(.vertical, 14)
        .background(Color.white.opacity(0.74))
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private func planRevealStatCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(Color.secondaryText)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(Color.ink)
                .monospacedDigit()
                .lineLimit(2)
                .minimumScaleFactor(0.82)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.72))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func valueCard(title: String, subtitle: String, symbol: String) -> some View {
        CardSection(fill: AnyShapeStyle(Color.white.opacity(0.8))) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: symbol)
                    .font(.headline.weight(.semibold))
                    .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                    .frame(width: 42, height: 42)
                    .background(Color(red: 0.58, green: 0.46, blue: 0.98).opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.ink)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(Color.secondaryText)
                        .lineSpacing(3)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func valueTile(title: String, subtitle: String, symbol: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: symbol)
                .font(.headline.weight(.semibold))
                .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                .frame(width: 42, height: 42)
                .background(Color(red: 0.58, green: 0.46, blue: 0.98).opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

            Spacer(minLength: 0)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(Color.ink)

                Text(subtitle)
                    .font(.footnote)
                    .foregroundStyle(Color.secondaryText)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, minHeight: 136, alignment: .topLeading)
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(Color.white.opacity(0.42), lineWidth: 1)
        )
    }

    private func planMetricBar(title: String, value: CGFloat, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color.secondaryText)

                Spacer()

                Text("\(Int(value * 100))%")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(tint)
                    .monospacedDigit()
            }

            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.5))

                    Capsule()
                        .fill(tint.opacity(0.9))
                        .frame(width: proxy.size.width * value)
                }
                .animation(.easeInOut(duration: 0.55), value: value)
            }
            .frame(height: 10)
        }
    }

    private func compactPlanBullet(_ text: String) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "sparkles")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                .frame(width: 16, height: 16)

            Text(text)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(Color.ink)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var canContinue: Bool {
        switch onboardingManager.currentStep {
        case .welcome, .planReveal, .planReady, .value, .savingsReminder, .paywall, .exitOffer:
            return true
        case .planGeneration:
            return planGenerationProgress >= 100
        case .name:
            return !trimmedName.isEmpty
        case .consumption:
            return onboardingManager.state.weeklySpending > 0
        case .goal:
            return onboardingManager.state.goal != nil
        case .pace:
            return onboardingManager.state.pace != nil
        case .motivation:
            return !trimmedMotivation.isEmpty
        case .concerns:
            return !onboardingManager.state.concerns.isEmpty
        }
    }

    private var stepLabel: String {
        switch onboardingManager.currentStep {
        case .welcome: return "Welcome"
        case .name: return "Name"
        case .consumption: return "Spend"
        case .goal: return "Goal"
        case .pace: return "Pace"
        case .motivation: return "Reason"
        case .concerns: return "Concerns"
        case .planGeneration: return "Plan"
        case .planReveal: return "Reveal"
        case .planReady: return "Ready"
        case .value: return "Value"
        case .savingsReminder: return "Savings"
        case .paywall: return "Paywall"
        case .exitOffer: return "Offer"
        }
    }

    private var planRevealHeadline: String {
        trimmedName.isEmpty
            ? "This starts simple and supportive."
            : "\(trimmedName), this starts simple and supportive."
    }

    private var planRevealBullets: [String] {
        [
            "Focus: \(onboardingManager.state.goal ?? "A clearer quit reason")",
            "Pace: \(onboardingManager.state.pace ?? "Steady support")",
            "Watch: \(concernSummary)"
        ]
    }

    private var concernSummary: String {
        let selected = onboardingManager.state.concerns
        switch selected.count {
        case 0:
            return "general craving moments"
        case 1:
            return selected[0]
        case 2:
            return "\(selected[0]) and \(selected[1])"
        default:
            return "\(selected[0]), \(selected[1]), and similar high-pressure moments"
        }
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var estimatedMonthlySpendText: String {
        (onboardingManager.state.weeklySpending * 4.33).formatted(.currency(code: currencyCode))
    }

    private var estimatedYearlySpendText: String {
        (onboardingManager.state.weeklySpending * 52).formatted(.currency(code: currencyCode))
    }

    private var estimatedYearlySpendValue: Double {
        onboardingManager.state.weeklySpending * 52
    }

    private var estimatedFirstYearSavingsValue: Double {
        estimatedYearlySpendValue * 0.82
    }

    private var estimatedAvoidedPurchasesValue: Double {
        max((estimatedYearlySpendValue / 8).rounded(), 0)
    }

    private var trimmedName: String {
        onboardingManager.state.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedMotivation: String {
        onboardingManager.state.motivation.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var nameBinding: Binding<String> {
        Binding(
            get: { onboardingManager.state.name },
            set: { onboardingManager.state.name = $0 }
        )
    }

    private var motivationBinding: Binding<String> {
        Binding(
            get: { onboardingManager.state.motivation },
            set: { newValue in
                if newValue.contains("\n") {
                    onboardingManager.state.motivation = newValue.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    focusedField = nil
                } else {
                    onboardingManager.state.motivation = newValue
                }
            }
        )
    }

    private var weeklySpendingBinding: Binding<Double> {
        Binding(
            get: { onboardingManager.state.weeklySpending },
            set: { onboardingManager.state.weeklySpending = $0 }
        )
    }

    private var weeklySpendingText: Binding<String> {
        Binding(
            get: {
                let value = onboardingManager.state.weeklySpending
                if value.rounded() == value {
                    return String(Int(value))
                }
                return String(format: "%.1f", value)
            },
            set: { newValue in
                let filtered = newValue
                    .replacingOccurrences(of: ",", with: ".")
                    .filter { $0.isNumber || $0 == "." }

                if let value = Double(filtered) {
                    onboardingManager.state.weeklySpending = min(max(value, 0), 280)
                } else if filtered.isEmpty {
                    onboardingManager.state.weeklySpending = 0
                }
            }
        )
    }

    private func toggleConcern(_ concern: String) {
        if onboardingManager.state.concerns.contains(concern) {
            onboardingManager.state.concerns.removeAll { $0 == concern }
        } else {
            onboardingManager.state.concerns.append(concern)
        }
    }

    private var currentFeedbackMessage: String? {
        feedbackStep == onboardingManager.currentStep ? feedbackMessage : nil
    }

    private func showFeedback(_ message: String) {
        feedbackTask?.cancel()
        feedbackMessage = message
        feedbackStep = onboardingManager.currentStep

        feedbackTask = Task {
            try? await Task.sleep(for: .seconds(1.2))
            guard !Task.isCancelled else { return }
            await MainActor.run {
                withAnimation(OnboardingPageTransition.animation) {
                    feedbackMessage = nil
                    feedbackStep = nil
                }
            }
        }
    }

    private func startYearlySpendReveal() {
        yearlySpendTask?.cancel()
        let target = estimatedYearlySpendValue

        yearlySpendTask = Task {
            let steps = 24
            for step in 0...steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                let value = target * progress
                await MainActor.run {
                    animatedYearlySpend = value
                }
                try? await Task.sleep(for: .milliseconds(24))
            }
        }
    }

    private func startPlanGeneration() {
        planGenerationTask?.cancel()
        planGenerationProgress = 0

        planGenerationTask = Task {
            for value in stride(from: 0, through: 100, by: 4) {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    planGenerationProgress = value
                }
                try? await Task.sleep(for: .milliseconds(85))
            }
            guard !Task.isCancelled else { return }
            await MainActor.run {
                OnboardingHaptics.success()
            }
        }
    }

    private func startPlanRevealAnimation() {
        planRevealAnimationTask?.cancel()
        animatedPlanSavings = 0
        animatedAvoidedPurchases = 0
        planRevealMetricsVisible = false
        planRevealVisibleSections = 0

        let targetSavings = estimatedFirstYearSavingsValue
        let targetPurchases = estimatedAvoidedPurchasesValue

        planRevealAnimationTask = Task {
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.32)) {
                    planRevealVisibleSections = 1
                }
            }
            try? await Task.sleep(for: .milliseconds(140))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.32)) {
                    planRevealVisibleSections = 2
                }
            }
            try? await Task.sleep(for: .milliseconds(120))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.32)) {
                    planRevealVisibleSections = 3
                }
            }
            try? await Task.sleep(for: .milliseconds(80))
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.55)) {
                    planRevealMetricsVisible = true
                }
            }

            let steps = 26
            for step in 0...steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                await MainActor.run {
                    animatedPlanSavings = targetSavings * progress
                    animatedAvoidedPurchases = targetPurchases * progress
                }
                try? await Task.sleep(for: .milliseconds(24))
            }
        }
    }

    private func startSavingsReminderAnimation() {
        savingsReminderTask?.cancel()
        animatedSavingsReminder = 0
        let target = estimatedFirstYearSavingsValue

        savingsReminderTask = Task {
            let steps = 24
            for step in 0...steps {
                guard !Task.isCancelled else { return }
                let progress = Double(step) / Double(steps)
                await MainActor.run {
                    animatedSavingsReminder = target * progress
                }
                try? await Task.sleep(for: .milliseconds(26))
            }
        }
    }

    private func completeOnboarding() {
        debugPrint("[Onboarding] completeOnboarding() -> home screen navigation trigger")
        appState.applyOnboarding(onboardingManager.state)
    }

    private func goBack() {
        focusedField = nil
        navigationDirection = .backward
        withAnimation(OnboardingPageTransition.animation) {
            onboardingManager.previousStep()
        }
    }

    private func continueForward() {
        guard canContinue else { return }
        focusedField = nil
        debugPrint("[Onboarding] continue tapped on step \(stepLabelForDebug(onboardingManager.currentStep))")

        if onboardingManager.currentStep == .paywall {
            debugPrint("[Onboarding] continue ignored on paywall step; purchase CTA owns navigation")
            return
        }

        if onboardingManager.currentStep == .exitOffer {
            completeOnboarding()
            return
        }

        navigationDirection = .forward
        debugPrint("[Onboarding] progressing to next step from \(stepLabelForDebug(onboardingManager.currentStep))")
        withAnimation(OnboardingPageTransition.animation) {
            onboardingManager.nextStep()
        }
    }

    private func startOnboardingPaywallPurchase() {
        guard let selectedOnboardingPaywallPackage else { return }
        debugPrint("[Onboarding Paywall] CTA tapped")

        Task {
            switch await subscriptionManager.purchase(selectedOnboardingPaywallPackage) {
            case .success:
                debugPrint("[Onboarding Paywall] purchase success")
                appState.showRewardToast(
                    title: "Ayo Pro unlocked.",
                    message: "Your subscription is active now."
                )
                completeOnboarding()
            case .cancelled:
                debugPrint("[Onboarding Paywall] purchase cancelled")
            case .failed(let message):
                debugPrint("[Onboarding Paywall] purchase failed: \(message)")
            }
        }
    }

    private func restoreOnboardingPaywallPurchases() {
        debugPrint("[Onboarding Paywall] restore started")

        Task {
            switch await subscriptionManager.restorePurchases() {
            case .restored:
                debugPrint("[Onboarding Paywall] restore success")
                appState.showRewardToast(
                    title: "Purchases restored.",
                    message: "Ayo Pro is active on this device."
                )
                completeOnboarding()
            case .noActiveSubscription:
                debugPrint("[Onboarding Paywall] restore found no active subscription")
            case .failed(let message):
                debugPrint("[Onboarding Paywall] restore failed: \(message)")
            }
        }
    }

    private func syncOnboardingPaywallSelection() {
        let preferredPackage = selectedOnboardingPaywallPackage
            ?? subscriptionManager.monthlyPackage
            ?? subscriptionManager.annualPackage
            ?? subscriptionManager.availablePackages.first
        onboardingPaywallSelectedPackageID = preferredPackage?.storeProduct.productIdentifier
        if let onboardingPaywallSelectedPackageID {
            debugPrint("[Onboarding Paywall] active package id: \(onboardingPaywallSelectedPackageID)")
        }
    }

    private func onboardingPaywallTitle(for package: Package) -> String {
        switch package.packageType {
        case .monthly:
            return "Monthly"
        case .annual:
            return "Annual"
        default:
            return package.storeProduct.localizedTitle
        }
    }

    private func onboardingPaywallPriceText(for package: Package) -> String {
        switch package.packageType {
        case .annual:
            return "\(package.storeProduct.localizedPriceString) / year"
        case .monthly:
            return "\(package.storeProduct.localizedPriceString) / month"
        default:
            return package.storeProduct.localizedPriceString
        }
    }

    private func onboardingPaywallSupportingText(for package: Package) -> String {
        package.storeProduct.introductoryDiscount == nil ? "Current plan" : "Free trial available"
    }

    private func stepLabelForDebug(_ step: OnboardingStep) -> String {
        switch step {
        case .welcome: return "welcome"
        case .name: return "name"
        case .consumption: return "consumption"
        case .goal: return "goal"
        case .pace: return "pace"
        case .motivation: return "motivation"
        case .concerns: return "concerns"
        case .planGeneration: return "planGeneration"
        case .planReveal: return "planReveal"
        case .planReady: return "planReady"
        case .value: return "value"
        case .savingsReminder: return "savingsReminder"
        case .paywall: return "paywall"
        case .exitOffer: return "exitOffer"
        }
    }
}

private struct ConcernOptionTile: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            OnboardingHaptics.light()
            action()
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(
                            isSelected
                                ? AnyShapeStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.60, green: 0.44, blue: 0.99),
                                            Color(red: 0.45, green: 0.24, blue: 0.90)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                : AnyShapeStyle(Color.white.opacity(0.7))
                        )

                    Image(systemName: icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(isSelected ? Color.white : Color(red: 0.46, green: 0.25, blue: 0.90))
                }
                .frame(height: 76)
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(
                            isSelected
                                ? Color(red: 0.53, green: 0.38, blue: 0.97)
                                : Color.white.opacity(0.34),
                            lineWidth: isSelected ? 1.4 : 1
                        )
                )

                Text(title)
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(isSelected ? Color(red: 0.45, green: 0.24, blue: 0.90) : Color.ink)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            .scaleEffect(isSelected ? 1.03 : 1)
            .animation(.easeInOut(duration: 0.15), value: isSelected)
        }
        .buttonStyle(CardPressButtonStyle())
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
        .environmentObject(OnboardingManager())
}
