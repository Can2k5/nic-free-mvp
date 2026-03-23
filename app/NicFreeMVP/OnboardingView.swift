import SwiftUI
import RevenueCat

struct OnboardingView: View {
    private enum OnboardingLayout {
        static let horizontalPadding: CGFloat = 24
        static let maxContentWidth: CGFloat = 520
    }

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
    @State private var loadingDidAutoAdvance = false
    @State private var onboardingPaywallSelectedPackageID: String?
    @State private var onboardingPaywallLoaded = false
    @State private var breakLoopHoldProgress: CGFloat = 0
    @State private var breakLoopIsHolding = false
    @State private var breakLoopHoldCompleted = false
    @State private var breakLoopHoldTask: Task<Void, Never>?
    @State private var costSliderShowsKeypad = false
    @State private var profileQuestionPage = 0
    @State private var profileSelectedAge = 25
    @State private var profileSelectedQuitAttempt = "Never"

    private let recognitionOptions = [
        "I keep saying “last time”",
        "I lose control in the moment",
        "I regret it right after",
        "I’ve tried to quit before",
        "I feel like I’m not in control"
    ]

    private let systemOptions = [
        ("Stress and routines drive it", "My day has a few predictable weak spots.", "wind"),
        ("My environment keeps pulling me back", "People, places, or patterns make it easier to slip.", "door.left.hand.open"),
        ("I need structure, not more guilt", "I want support that feels calm and usable.", "square.grid.2x2"),
        ("I want daily support that feels human", "Encouragement works better than pressure.", "heart.text.square")
    ]

    private let startPointOptions = [
        ("I still smoke most days", "I am near the beginning of this reset.", "calendar"),
        ("I am trying to cut down", "I have started changing the habit already.", "dial.low"),
        ("I quit recently but feel shaky", "Momentum is there, but it does not feel stable yet.", "leaf"),
        ("I keep slipping after a few good days", "The first stretch goes okay, then the loop returns.", "arrow.uturn.backward")
    ]

    private let startTimingOptions = [
        ("Right now", "onboarding_badge_gold"),
        ("Tomorrow", "onboarding_badge_silver"),
        ("This week", "onboarding_badge_bronze")
    ]

    private let triggerOptions = [
        ("Stress", "Pressure is usually the first crack in the day.", "briefcase.fill"),
        ("Coffee", "Routines and nicotine still feel linked.", "cup.and.saucer.fill"),
        ("Social", "Other people or shared moments make it harder.", "person.2.fill"),
        ("Evening", "The later hours are the hardest to hold.", "moon.stars.fill"),
        ("Boredom", "Empty space quickly turns into an urge.", "hourglass"),
        ("Driving", "The car still carries a strong habit cue.", "car.fill")
    ]

    private let triggerVisualOptions: [(title: String, imageName: String?, imageOnLeading: Bool)] = [
        ("At night", "onboarding_trigger_night", false),
        ("When I’m stressed", "onboarding_trigger_stress", true),
        ("When I’m bored", "onboarding_trigger_bored", false),
        ("After eating", "onboarding_trigger_food", true),
        ("When I’m alone", "onboarding_trigger_lonely", false)
    ]

    private let futureIdentityOptions = [
        ("Clear mind", "No constant cravings"),
        ("More energy", "You don’t feel drained anymore"),
        ("In control", "You decide, not the habit")
    ]

    private let profileQuestionOptions = [
        ("I need fast rescue tools", "bolt.fill"),
        ("I want more accountability", "checkmark.shield.fill"),
        ("Savings motivate me", "eurosign.circle.fill"),
        ("Health matters most", "heart.fill")
    ]

    private let profileQuestionSections: [(key: String, title: String, options: [String])] = [
        ("age", "How old are you?", ["Under 18", "18–25", "25+"]),
        ("quit", "Have you tried to quit before?", ["No", "A few times", "Many times"]),
        ("gender", "Which best describes you?", ["Male", "Female", "Other"])
    ]

    private let profileAgeValues = Array(16...70)

    private let profileGenderOptions = [
        OnboardingPillOption(title: "Male", value: "Male"),
        OnboardingPillOption(title: "Female", value: "Female"),
        OnboardingPillOption(title: "Non-binary", value: "Other"),
        OnboardingPillOption(title: "Prefer not to say", value: "Other")
    ]

    private let quitAttemptDisplayOptions = [
        "Never",
        "1-2 times",
        "3-5 times",
        "Many times"
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

    private func onboardingContentWidth(_ proxy: GeometryProxy, maxWidth: CGFloat = OnboardingLayout.maxContentWidth) -> CGFloat {
        min(proxy.size.width - (OnboardingLayout.horizontalPadding * 2), maxWidth)
    }

    private func onboardingHeaderTop(_ safeTop: CGFloat) -> CGFloat {
        safeTop + OnboardingHeaderMetrics.topSafeAreaOffset
    }

    private func onboardingBottomBar(
        width: CGFloat,
        showsBackButton: Bool = true,
        showsPrimaryButton: Bool = true,
        primaryButtonEnabled: Bool = true,
        onBack: (() -> Void)? = nil,
        onContinue: (() -> Void)? = nil
    ) -> some View {
        let normalizedWidth = max(
            width,
            min(
                UIScreen.main.bounds.width - (OnboardingLayout.horizontalPadding * 2),
                OnboardingLayout.maxContentWidth
            )
        )

        return OnboardingActionRow(
            showsBackButton: showsBackButton,
            showsPrimaryButton: showsPrimaryButton,
            backTitle: "back",
            continueTitle: "continue",
            primaryButtonEnabled: primaryButtonEnabled,
            width: normalizedWidth,
            horizontalPadding: 0,
            bottomPadding: 0,
            spacing: OnboardingActionBarMetrics.spacing,
            onBack: onBack,
            onContinue: onContinue
        )
        .padding(.top, OnboardingActionBarMetrics.topInset)
    }
    var body: some View {
        ZStack {
            OnboardingBackgroundView()

            currentStepScreen
                .id(onboardingManager.currentStep)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .transition(OnboardingPageTransition.transition(forward: navigationDirection == .forward))
        }
        .animation(OnboardingPageTransition.animation, value: onboardingManager.currentStep)
        .onChange(of: onboardingManager.currentStep) { _, step in
            debugPrint("[Onboarding] current step changed -> \(stepLabelForDebug(step))")
            feedbackTask?.cancel()
            feedbackMessage = nil
            feedbackStep = nil

            if step != .loading {
                planGenerationTask?.cancel()
                planGenerationPulse = false
                loadingDidAutoAdvance = false
            }

            yearlySpendTask?.cancel()

            if step != .profileQuestions {
                profileQuestionPage = 0
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
        case .hook:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Start",
                primaryButtonEnabled: true,
                showsProgressIndicator: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                contentIgnoresSafeArea: true,
                showsPrimaryButton: false,
                showsBackButton: false,
                onContinue: continueForward
            ) {
                hookContent
            }

        case .recognition:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                recognitionContent
            }

        case .system:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: true,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                systemContent
            }

        case .breakLoopHold:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: false,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                breakLoopHoldContent
            }

        case .costSlider:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                costSliderContent
            }

        case .future:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                futureContent
            }

        case .nameInput:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                nameContent
            }

        case .startPoint:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                startPointContent
            }

        case .triggerQuestion:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                triggerQuestionContent
            }

        case .profileQuestions:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                profileQuestionsContent
            }

        case .loading:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "",
                title: "",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: canContinue,
                showsProgressIndicator: false,
                showsProgressStepLabel: false,
                showsHeader: false,
                contentUsesFullWidth: true,
                usesScrollView: false,
                showsPrimaryButton: false,
                showsBackButton: false,
                onBack: goBack,
                onContinue: continueForward
            ) {
                loadingContent
            }

        case .planReady:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
                stepLabel: stepLabel,
                eyebrow: "14 Plan Ready",
                title: "Your first plan is ready.",
                subtitle: "",
                primaryButtonTitle: "Continue",
                primaryButtonEnabled: true,
                onBack: goBack,
                onContinue: continueForward
            ) {
                planReadyContent
            }

        case .paywall:
            OnboardingScreenLayout(
                currentStep: onboardingManager.currentStep.position,
                totalSteps: OnboardingStep.progressTotal,
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
                totalSteps: OnboardingStep.progressTotal,
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

    private var hookContent: some View {
        GeometryReader { proxy in
            let purple = Color.buttonBottom
            let width = proxy.size.width
            let height = proxy.size.height
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let logoTop = safeTop + max(30, height * 0.09)
            let imageTop = max(28, height * 0.038)
            let imageWidth = min(width * 0.72, 362)
            let cardWidth = width - 32
            let cardBottomPadding = max(16, safeBottom + 8)

            ZStack {
                LinearGradient(
                    colors: [
                        Color.appBackgroundTop,
                        Color(red: 0.985, green: 0.972, blue: 1.0),
                        Color(red: 0.95, green: 0.90, blue: 1.0),
                        Color.appBackgroundBottom
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                Circle()
                    .fill(Color.white.opacity(0.52))
                    .frame(width: width * 0.94, height: width * 0.94)
                    .blur(radius: 42)
                    .offset(y: -height * 0.22)

                Circle()
                    .fill(Color.buttonHighlight.opacity(0.16))
                    .frame(width: width * 0.84, height: width * 0.84)
                    .blur(radius: 52)
                    .offset(x: -width * 0.22, y: height * 0.14)

                VStack(spacing: 0) {
                    Text("AYO")
                        .font(.system(size: 48, weight: .black, design: .rounded))
                        .tracking(0.8)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.buttonTop,
                                    purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                                )
                        )
                        .rotationEffect(.degrees(-8))
                        .shadow(color: Color.onboardingShadow.opacity(0.3), radius: 10, x: 0, y: 8)
                        .padding(.top, logoTop)

                    Image("onboarding_ashtray")
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageWidth)
                        .shadow(color: Color.onboardingShadow.opacity(0.22), radius: 28, x: 0, y: 20)
                        .padding(.top, imageTop)

                    Spacer(minLength: 28)

                    VStack(spacing: 0) {
                        Text("It stops now.")
                            .font(.system(size: 34, weight: .black, design: .rounded))
                            .foregroundStyle(purple)
                            .multilineTextAlignment(.center)
                            .tracking(-0.8)

                        Text("You don’t need another attempt.\nYou need a system.")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundStyle(Color.secondaryText)
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .padding(.top, 14)

                        Button(action: continueForward) {
                            Text("I’m done")
                                .font(.system(size: 20, weight: .heavy, design: .rounded))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 64)
                                .background(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.buttonTop,
                                                    purple
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                                )
                                        )
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                                        .stroke(Color.white.opacity(0.16), lineWidth: 1)
                                )
                                .shadow(color: Color.onboardingShadow.opacity(0.28), radius: 18, x: 0, y: 10)
                        }
                        .buttonStyle(CardPressButtonStyle())
                        .padding(.top, 34)
                        .padding(.horizontal, 84)
                    }
                    .padding(.top, 38)
                    .padding(.bottom, 34)
                    .frame(width: cardWidth)
                    .frame(minHeight: min(max(height * 0.35, 304), 362))
                    .background(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .fill(Color.onboardingSurfaceElevated.opacity(0.98))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 36, style: .continuous)
                            .stroke(Color.borderStrong.opacity(0.72), lineWidth: 1)
                    )
                    .shadow(color: Color.onboardingShadow.opacity(0.18), radius: 24, x: 0, y: 12)
                    .padding(.bottom, cardBottomPadding)
                }
            }
            .frame(width: width, height: height)
        }
        .frame(minHeight: 852)
    }

    private var breakLoopHoldContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)
            let purple = Color(red: 0.36, green: 0.12, blue: 0.64)
            let holdDiameter = min(proxy.size.width * 0.40, 232)
            let outerDiameter = holdDiameter + 28

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 4,
                    totalSteps: 13,
                    title: "Break the loop.",
                    subtitle: "Don’t do anything for a moment."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                Spacer(minLength: 24)

                ZStack {
                    Circle()
                        .fill(purple.opacity(0.10 + (breakLoopHoldProgress * 0.10)))
                        .frame(width: outerDiameter, height: outerDiameter)
                        .scaleEffect(0.95 + (breakLoopHoldProgress * 0.08))

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    purple.opacity(0.18),
                                    purple.opacity(0.42)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 9
                        )
                        .frame(width: outerDiameter, height: outerDiameter)
                        .opacity(0.18 + (breakLoopHoldProgress * 0.55))

                    Circle()
                        .trim(from: 0, to: max(0.01, breakLoopHoldProgress))
                        .stroke(
                            purple.opacity(0.92),
                            style: StrokeStyle(lineWidth: 9, lineCap: .round, lineJoin: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .frame(width: outerDiameter, height: outerDiameter)
                        .opacity(breakLoopIsHolding || breakLoopHoldCompleted ? 1 : 0.001)

                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.43, green: 0.16, blue: 0.75),
                                    purple
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: holdDiameter, height: holdDiameter)
                        .shadow(color: purple.opacity(0.16), radius: 22, x: 0, y: 12)
                        .scaleEffect(breakLoopIsHolding ? 0.975 : 1)

                    Text("Hold to break")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }
                .frame(width: outerDiameter, height: outerDiameter)
                .contentShape(Circle())
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { _ in
                            startBreakLoopHold()
                        }
                        .onEnded { _ in
                            cancelBreakLoopHoldIfNeeded()
                        }
                )

                Spacer(minLength: 24)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    showsPrimaryButton: false,
                    onBack: goBack
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            breakLoopHoldTask?.cancel()
            breakLoopHoldProgress = 0
            breakLoopIsHolding = false
            breakLoopHoldCompleted = false
        }
        .onDisappear {
            breakLoopHoldTask?.cancel()
            breakLoopHoldTask = nil
            breakLoopIsHolding = false
        }
    }

    private var systemContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy, maxWidth: 542)
            let cardsTopSpacing: CGFloat = 38
            let cardsSpacing: CGFloat = 18
            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 3,
                    totalSteps: 13,
                    title: "You’re not the only one.",
                    subtitle: ""
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                VStack(spacing: cardsSpacing) {
                    systemMessageCard(
                        text: "Most people try to quit with willpower.\nThat’s why it doesn’t work.",
                        imageName: "onboarding_person_1",
                        imageWidth: 184,
                        imageTopPadding: -22,
                        imageTrailingPadding: 18
                    )

                    systemMessageCard(
                        text: "You don’t need more discipline.\nYou need a system.",
                        imageName: "onboarding_person_2",
                        imageWidth: 192,
                        imageTopPadding: -24,
                        imageTrailingPadding: 20
                    )
                }
                .padding(.top, cardsTopSpacing)

                Spacer(minLength: 14)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: true,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            if onboardingManager.state.systemResponse == nil {
                onboardingManager.state.systemResponse = "system"
            }
        }
    }

    private var recognitionContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)
            let topInset = onboardingHeaderTop(safeTop)

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 2,
                    totalSteps: 13,
                    title: "This sounds familiar, right?",
                    subtitle: "No one sees this but you."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, topInset)

                VStack(spacing: 10) {
                    ForEach(recognitionOptions, id: \.self) { option in
                        recognitionOptionCard(title: option)
                            .frame(width: contentWidth)
                    }
                }
                .padding(.top, 20)

                Spacer(minLength: 12)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func systemMessageCard(
        text: String,
        imageName: String,
        imageWidth: CGFloat,
        imageTopPadding: CGFloat,
        imageTrailingPadding: CGFloat
    ) -> some View {
        ZStack(alignment: .topTrailing) {
            RoundedRectangle(cornerRadius: 33, style: .continuous)
                .fill(Color.onboardingSurfaceElevated.opacity(0.98))
                .overlay(
                    RoundedRectangle(cornerRadius: 33, style: .continuous)
                        .stroke(Color.borderStrong.opacity(0.68), lineWidth: 1)
                )
                .shadow(color: Color.onboardingShadow.opacity(0.12), radius: 18, x: 0, y: 10)

            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageWidth)
                .padding(.top, imageTopPadding)
                .padding(.trailing, imageTrailingPadding)

            VStack(alignment: .leading, spacing: 0) {
                Spacer()

                Text(text)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(3)
                    .padding(.leading, 30)
                    .padding(.trailing, 30)
                    .padding(.bottom, 26)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 214)
    }

    private var breakLoopSuccessContent: some View {
        onboardingMessageCard(
            title: "A new pattern starts small.",
            body: "The new journey will eventually show a stronger emotional sequence here. For now, this step is structurally ready and safely connected."
        )
    }

    private var nameContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)
            let fieldHeight: CGFloat = 86

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 7,
                    totalSteps: 13,
                    title: "What should we call you?",
                    subtitle: ""
                )
                .frame(width: contentWidth)
                .padding(.top, onboardingHeaderTop(safeTop))

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 18) {
                        Text("We’ll use your name in the plan and support prompts.")
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.helperText)

                        Button {
                            focusedField = .name
                        } label: {
                            HStack(spacing: 0) {
                                TextField("", text: nameBinding, prompt: Text("Enter your name").foregroundStyle(Color.secondaryText.opacity(0.72)))
                                    .font(.system(size: 28, weight: .semibold, design: .rounded))
                                    .foregroundStyle(Color.ink)
                                    .focused($focusedField, equals: .name)
                                    .textInputAutocapitalization(.words)
                                    .autocorrectionDisabled()
                                    .submitLabel(.done)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding(.horizontal, 28)
                            .frame(width: contentWidth, height: fieldHeight)
                            .background(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .fill(Color.onboardingSurfaceElevated)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 30, style: .continuous)
                                    .stroke(
                                        focusedField == .name ? Color.buttonBottom.opacity(0.88) : Color.borderStrong.opacity(0.68),
                                        lineWidth: focusedField == .name ? 2.2 : 1
                                    )
                            )
                            .shadow(color: Color.onboardingShadow.opacity(focusedField == .name ? 0.18 : 0.1), radius: focusedField == .name ? 18 : 14, x: 0, y: 8)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(width: contentWidth, alignment: .leading)
                    .padding(.top, 92)

                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
    }

    private var startPointContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy, maxWidth: 512)
            let cardsTopSpacing: CGFloat = 42
            let cardsSpacing: CGFloat = 14
            let cardHeight: CGFloat = 110

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 8,
                    totalSteps: 13,
                    title: "When do you start?",
                    subtitle: "Small steps. Big change."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                VStack(spacing: cardsSpacing) {
                    ForEach(startTimingOptions, id: \.0) { option in
                        startPointOptionCard(
                            title: option.0,
                            badgeAssetName: option.1,
                            isSelected: onboardingManager.state.startPoint == option.0
                        ) {
                            onboardingManager.state.startPoint = option.0
                        }
                        .frame(height: cardHeight)
                        .frame(width: contentWidth)
                    }
                }
                .padding(.top, cardsTopSpacing)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var triggerQuestionContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let safeBottom = proxy.safeAreaInsets.bottom
            let contentWidth = onboardingContentWidth(proxy, maxWidth: 512)
            let cardsTopSpacing: CGFloat = 18
            let cardsSpacing: CGFloat = 10
            let cardHeight = max(66, min(74, (proxy.size.height - safeTop - safeBottom - 294) / 5))

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: onboardingManager.currentStep.position,
                    totalSteps: OnboardingStep.progressTotal,
                    title: "When do you feel it most?",
                    subtitle: "We’ll use this to tailor your support."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                VStack(spacing: cardsSpacing) {
                    ForEach(triggerVisualOptions, id: \.title) { option in
                        triggerQuestionOptionCard(
                            title: option.title,
                            imageName: option.imageName,
                            imageOnLeading: option.imageOnLeading,
                            isSelected: onboardingManager.state.triggerQuestion == option.title
                        ) {
                            onboardingManager.state.triggerQuestion = option.title
                        }
                        .frame(height: cardHeight)
                        .frame(width: contentWidth)
                    }
                }
                .padding(.top, cardsTopSpacing)

                Spacer(minLength: 4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var costSliderContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let purple = Color.buttonBottom
            let contentWidth = onboardingContentWidth(proxy)
            let displayCardWidth = min(contentWidth * 0.56, 272)
            let weeklyValue = max(Int(onboardingManager.state.weeklySpending.rounded()), 0)
            let monthlyValue = weeklyValue * 4
            let yearlyValue = weeklyValue * 48

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 5,
                    totalSteps: 13,
                    title: "Be honest…",
                    subtitle: "how much is it costing you?"
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                Spacer()
                    .frame(height: 62)

                Button(action: {
                    withAnimation(.easeOut(duration: 0.18)) {
                        costSliderShowsKeypad = true
                    }
                }) {
                    VStack(spacing: 0) {
                        Text("\(weeklyValue) / week")
                            .font(.system(size: 27, weight: .bold, design: .rounded))
                            .foregroundStyle(purple)
                            .monospacedDigit()

                        Text("\(monthlyValue) / month")
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                            .foregroundStyle(purple.opacity(0.82))
                            .monospacedDigit()
                            .padding(.top, 4)

                        Text("\(yearlyValue) / year")
                            .font(.system(size: 23, weight: .bold, design: .rounded))
                            .foregroundStyle(purple.opacity(0.58))
                            .monospacedDigit()
                            .padding(.top, 5)
                    }
                    .frame(width: displayCardWidth, height: 148)
                    .background(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(Color.onboardingSurfaceElevated)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .stroke(Color.borderStrong.opacity(0.9), lineWidth: 1.5)
                    )
                    .overlay(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: 34, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: 40)
                            .clipShape(RoundedRectangle(cornerRadius: 34, style: .continuous))
                    }
                    .overlay(alignment: .topTrailing) {
                        Text(costSliderShowsKeypad ? "editing" : "edit")
                            .font(.system(size: 12, weight: .bold, design: .rounded))
                            .foregroundStyle(purple.opacity(0.76))
                            .padding(.top, 14)
                            .padding(.trailing, 16)
                    }
                }
                .shadow(color: Color.onboardingShadow.opacity(0.14), radius: 18, x: 0, y: 10)
                .buttonStyle(PlainButtonStyle())
                .padding(.horizontal, 22)

                costSliderTrack(purple: purple, width: contentWidth)
                    .padding(.top, 38)

                costSliderMessagePill(purple: purple, width: contentWidth)
                    .padding(.top, 18)

                if costSliderShowsKeypad {
                    costSliderKeypad(width: contentWidth)
                        .padding(.top, 12)
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                }

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .onAppear {
                costSliderShowsKeypad = false
            }
            .safeAreaInset(edge: .bottom, spacing: 0) {
                if costSliderShowsKeypad {
                    EmptyView()
                } else {
                    onboardingBottomBar(
                        width: contentWidth,
                        primaryButtonEnabled: canContinue,
                        onBack: goBack,
                        onContinue: continueForward
                    )
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func costSliderTrack(purple: Color, width: CGFloat) -> some View {
        GeometryReader { sliderProxy in
            let horizontalPadding: CGFloat = 40
            let trackWidth = sliderProxy.size.width - (horizontalPadding * 2)
            let progress = CGFloat(max(min(onboardingManager.state.weeklySpending / 70, 1), 0))
            let thumbSize: CGFloat = 58
            let thumbOffset = max(0, min(trackWidth - thumbSize, (trackWidth - thumbSize) * progress))

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color.onboardingSurfaceElevated)
                    .shadow(color: Color.onboardingShadow.opacity(0.1), radius: 14, x: 0, y: 8)

                Rectangle()
                    .fill(purple)
                    .frame(width: max(0, thumbOffset + (thumbSize / 2)), height: 5)
                    .offset(x: horizontalPadding)

                Rectangle()
                    .fill(purple.opacity(0.18))
                    .frame(width: trackWidth, height: 5)
                    .offset(x: horizontalPadding)

                Circle()
                    .fill(purple)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: horizontalPadding + thumbOffset)
                    .shadow(color: purple.opacity(0.18), radius: 10, x: 0, y: 5)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        if costSliderShowsKeypad {
                            withAnimation(.easeOut(duration: 0.18)) {
                                costSliderShowsKeypad = false
                            }
                        }
                        let location = min(max(value.location.x - horizontalPadding, 0), trackWidth)
                        let progress = trackWidth > 0 ? location / trackWidth : 0
                        let steppedValue = (Double(progress) * 70 / 5).rounded() * 5
                        onboardingManager.state.weeklySpending = max(0, min(70, steppedValue))
                    }
            )
        }
        .frame(width: width, height: 80)
    }

    private func costSliderMessagePill(purple: Color, width: CGFloat) -> some View {
        HStack(spacing: 0) {
            Text("This adds up fast.")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(purple)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: width, height: 58)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.onboardingSurfaceElevated)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(Color.borderStrong.opacity(0.62), lineWidth: 1)
        )
        .shadow(color: Color.onboardingShadow.opacity(0.08), radius: 10, x: 0, y: 6)
    }

    private func costSliderKeypad(width: CGFloat) -> some View {
        let keys: [[String]] = [
            ["1", "2", "3"],
            ["4", "5", "6"],
            ["7", "8", "9"],
            ["spacer", "0", "delete"]
        ]

        return VStack(spacing: 10) {
            ForEach(keys, id: \.self) { row in
                HStack(spacing: 10) {
                    ForEach(row, id: \.self) { key in
                        if key == "spacer" {
                            Color.clear
                                .frame(maxWidth: .infinity)
                                .frame(height: 70)
                        } else if key == "delete" {
                            Button(action: deleteWeeklyDigit) {
                                Image(systemName: "delete.left")
                                    .font(.system(size: 25, weight: .medium))
                                    .foregroundStyle(Color(red: 0.36, green: 0.12, blue: 0.64))
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                            }
                            .buttonStyle(PlainButtonStyle())
                        } else {
                            Button(action: {
                                appendWeeklyDigit(key)
                            }) {
                                Text(key)
                                    .font(.system(size: 27, weight: .regular, design: .rounded))
                                    .foregroundStyle(Color.black)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .fill(Color.onboardingSurfaceElevated)
                                    )
                            }
                            .buttonStyle(CardPressButtonStyle())
                        }
                    }
                }
            }
        }
    }

    private func appendWeeklyDigit(_ digit: String) {
        let currentValue = max(Int(onboardingManager.state.weeklySpending.rounded()), 0)
        let currentText = currentValue == 0 ? "" : String(currentValue)
        let updatedText = String((currentText + digit).prefix(3))
        let updatedValue = min(Int(updatedText) ?? 0, 70)
        onboardingManager.state.weeklySpending = Double(updatedValue)
    }

    private func deleteWeeklyDigit() {
        let currentValue = max(Int(onboardingManager.state.weeklySpending.rounded()), 0)
        let updatedText = String(String(currentValue).dropLast())
        onboardingManager.state.weeklySpending = Double(Int(updatedText) ?? 0)
    }

    private var costImpactContent: some View {
        CardSection(fill: AnyShapeStyle(
            LinearGradient(
                colors: [Color.white.opacity(0.98), Color(red: 0.95, green: 0.94, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Yearly impact")
                    .font(.footnote.weight(.semibold))
                    .foregroundStyle(Color(red: 0.49, green: 0.33, blue: 0.89))
                    .textCase(.uppercase)
                    .tracking(1.1)

                Text("You currently spend about")
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)

                Text(animatedYearlySpend.formatted(.currency(code: currencyCode)))
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(Color.ink)
                    .contentTransition(.numericText(value: animatedYearlySpend))
                    .monospacedDigit()

                Text("per year on nicotine.")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)
            }
        }
        .onAppear {
            startYearlySpendReveal()
        }
        .onChange(of: onboardingManager.state.weeklySpending) { _, _ in
            startYearlySpendReveal()
        }
    }

    private var futureContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: onboardingManager.currentStep.position,
                    totalSteps: OnboardingStep.progressTotal,
                    title: "This is you in 30 days",
                    subtitle: "Clear mind. Full control."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                VStack(alignment: .leading, spacing: 0) {
                    Text("Which one do you want most?")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.36, green: 0.12, blue: 0.64))
                        .padding(.bottom, 18)

                    VStack(spacing: 14) {
                        ForEach(futureIdentityOptions, id: \.0) { option in
                            SelectionCard(
                                title: option.0,
                                subtitle: option.1,
                                isSelected: onboardingManager.state.futureVision == option.0
                            ) {
                                onboardingManager.state.futureVision = option.0
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, 22)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
    }

    private func startPointOptionCard(
        title: String,
        badgeAssetName: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        FloatingIllustrationOptionCard(
            title: title,
            isSelected: isSelected,
            height: 110,
            cornerRadius: 31,
            titleFont: .system(size: 24, weight: .medium, design: .rounded),
            selectedTitleFont: .system(size: 24, weight: .bold, design: .rounded),
            titleAlignment: .leading,
            titleLeadingPadding: 36,
            titleTrailingPadding: 136,
            illustrationAlignment: .topTrailing,
            illustrationOffset: CGSize(width: -10, height: -18),
            action: action
        ) {
            VStack(spacing: 4) {
                Image(badgeAssetName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 118, height: 118)

                Ellipse()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.10),
                                Color.black.opacity(0.03)
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 68, height: 10)
                    .blur(radius: 1.2)
                    .offset(y: -10)
            }
        }
    }

    private func triggerQuestionOptionCard(
        title: String,
        imageName: String?,
        imageOnLeading: Bool,
        isSelected: Bool,
        action: @escaping () -> Void
    ) -> some View {
        let titleAlignment: Alignment = imageOnLeading ? .trailing : .leading
        let leadingPadding: CGFloat = imageOnLeading ? 116 : 22
        let trailingPadding: CGFloat = imageOnLeading ? 18 : 104

        return FloatingIllustrationOptionCard(
            title: title,
            isSelected: isSelected,
            height: 74,
            cornerRadius: 24,
            titleFont: .system(size: 18, weight: .medium, design: .rounded),
            selectedTitleFont: .system(size: 18, weight: .bold, design: .rounded),
            titleAlignment: titleAlignment,
            titleLeadingPadding: leadingPadding,
            titleTrailingPadding: trailingPadding,
            illustrationAlignment: triggerIllustrationAlignment(imageOnLeading: imageOnLeading),
            illustrationOffset: triggerIllustrationOffset(imageName: imageName, imageOnLeading: imageOnLeading),
            action: action
        ) {
            if let imageName {
                triggerCardIllustration(imageName: imageName)
            } else {
                EmptyView()
            }
        }
    }

    private func triggerCardIllustration(imageName: String) -> some View {
        let width: CGFloat
        switch imageName {
        case "onboarding_trigger_night":
            width = 86
        case "onboarding_trigger_stress":
            width = 92
        case "onboarding_trigger_bored":
            width = 84
        case "onboarding_trigger_food":
            width = 112
        case "onboarding_trigger_lonely":
            width = 94
        default:
            width = 88
        }

        return Image(imageName)
            .resizable()
            .scaledToFit()
            .frame(width: width)
    }

    private func triggerIllustrationAlignment(imageOnLeading: Bool) -> Alignment {
        imageOnLeading ? .bottomLeading : .bottomTrailing
    }

    private func triggerIllustrationOffset(imageName: String?, imageOnLeading: Bool) -> CGSize {
        guard let imageName else { return .zero }

        switch imageName {
        case "onboarding_trigger_night":
            return CGSize(width: 0, height: 6)
        case "onboarding_trigger_stress":
            return CGSize(width: imageOnLeading ? -6 : 0, height: 8)
        case "onboarding_trigger_bored":
            return CGSize(width: imageOnLeading ? 0 : -6, height: 2)
        case "onboarding_trigger_food":
            return CGSize(width: imageOnLeading ? -4 : 0, height: 8)
        case "onboarding_trigger_lonely":
            return CGSize(width: imageOnLeading ? 0 : -2, height: 6)
        default:
            return CGSize(width: 0, height: 4)
        }
    }

    private var profileQuestionsContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)
            let isBasicProfilePage = profileQuestionPage == 0

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 10,
                    totalSteps: 13,
                    title: isBasicProfilePage ? "Let’s personalize your journey" : "How many times have you tried to quit?",
                    subtitle: isBasicProfilePage
                        ? "This helps us tailor your experience"
                        : "This helps us understand how much support you may need."
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                Group {
                    if isBasicProfilePage {
                        basicProfileContent(width: contentWidth)
                    } else {
                        quitAttemptsContent(width: contentWidth)
                    }
                }
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, 14)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    primaryButtonEnabled: canContinue,
                    onBack: goBack,
                    onContinue: continueForward
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            syncProfileQuestionPage()
            profileSelectedAge = profileAge(for: profileQuestionAnswer(for: "age")) ?? 25
            profileSelectedQuitAttempt = displayQuitAttemptValue(for: profileQuestionAnswer(for: "quit")) ?? "Never"

            if profileQuestionAnswer(for: "age") == nil {
                setProfileQuestionAnswer(storedAgeBucket(for: profileSelectedAge), for: "age")
            }
        }
    }

    private var loadingContent: some View {
        GeometryReader { proxy in
            let safeTop = proxy.safeAreaInsets.top
            let contentWidth = onboardingContentWidth(proxy)
            let progress = max(0, min(CGFloat(planGenerationProgress) / 100, 1))
            let purple = Color(red: 0.36, green: 0.12, blue: 0.64)
            let lightPurple = Color(red: 0.79, green: 0.66, blue: 0.98)
            let ringSize = min(contentWidth * 0.76, 368)
            let ringLineWidth: CGFloat = 25
            let isComplete = planGenerationProgress >= 100

            VStack(spacing: 0) {
                OnboardingHeaderView(
                    currentStep: 11,
                    totalSteps: 13,
                    title: isComplete ? "Your plan is ready!" : "Preparing your Program...",
                    subtitle: ""
                )
                .frame(width: contentWidth, alignment: .leading)
                .padding(.top, onboardingHeaderTop(safeTop))

                ZStack {
                    Circle()
                        .stroke(lightPurple.opacity(0.86), lineWidth: ringLineWidth)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            AngularGradient(
                                gradient: Gradient(colors: [purple, Color(red: 0.49, green: 0.22, blue: 0.82), purple]),
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: ringLineWidth, lineCap: .butt, lineJoin: .round)
                        )
                        .rotationEffect(.degrees(-90))

                    Text("\(planGenerationProgress)%")
                        .font(.system(size: 42, weight: .regular, design: .rounded))
                        .foregroundStyle(purple)
                        .contentTransition(.numericText(value: Double(planGenerationProgress)))
                        .monospacedDigit()
                }
                .frame(width: ringSize, height: ringSize)
                .padding(.top, 118)

                Spacer(minLength: 0)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .padding(.horizontal, OnboardingLayout.horizontalPadding)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                onboardingBottomBar(
                    width: contentWidth,
                    showsBackButton: false,
                    showsPrimaryButton: true,
                    primaryButtonEnabled: isComplete,
                    onContinue: continueForward
                )
                .opacity(isComplete ? 1 : 0.001)
                .allowsHitTesting(isComplete)
                .animation(.easeOut(duration: 0.22), value: isComplete)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            loadingDidAutoAdvance = false
            startPlanGeneration()
            planGenerationPulse = true
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
            .onChange(of: onboardingManager.state.weeklySpending) { _, _ in
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
                CardSection(fill: AnyShapeStyle(Color.onboardingSurfaceElevated.opacity(0.94))) {
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
        VStack(spacing: 20) {
            PaywallGlowOrb()
                .padding(.top, 10)

            CardSection(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.onboardingSurfaceElevated, Color(red: 0.95, green: 0.93, blue: 1.0)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Stay with your plan")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundStyle(Color.ink)

                        Text("Unlock the full support system and keep the momentum you just created.")
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                            .foregroundStyle(Color.secondaryText)
                            .lineSpacing(3)
                    }

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
                    .foregroundStyle(Color.helperText)
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

    private func recognitionOptionCard(title: String) -> some View {
        let isSelected = onboardingManager.state.recognitionResponses.contains(title)
        let purple = Color(red: 0.36, green: 0.12, blue: 0.64)

        return Button {
            toggleRecognition(title)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "play.fill")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(isSelected ? purple : Color.helperText.opacity(0.85))
                    .frame(width: 22, height: 22)

                Text(title)
                    .font(.system(size: 16, weight: isSelected ? .bold : .medium, design: .rounded))
                    .foregroundStyle(isSelected ? Color.ink : Color.secondaryText)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 2)
            .frame(maxWidth: .infinity, minHeight: 70)
            .background(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(isSelected ? Color.onboardingSurfaceInteractive : Color.onboardingSurfaceElevated)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        isSelected ? purple.opacity(0.86) : Color.borderStrong.opacity(0.62),
                        lineWidth: isSelected ? 1.8 : 1
                    )
            )
            .shadow(
                color: Color.onboardingShadow.opacity(isSelected ? 0.16 : 0.08),
                radius: isSelected ? 14 : 10,
                x: 0,
                y: isSelected ? 8 : 6
            )
        }
        .buttonStyle(.plain)
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
        .overlay(
            Capsule()
                .stroke(Color.borderStrong.opacity(0.64), lineWidth: 1)
        )
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

    private func onboardingMessageCard(title: String, body: String) -> some View {
        CardSection(fill: AnyShapeStyle(Color.white.opacity(0.8))) {
            VStack(alignment: .leading, spacing: 12) {
                Text(title)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.ink)

                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(Color.secondaryText)
                    .lineSpacing(4)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var canContinue: Bool {
        switch onboardingManager.currentStep {
        case .hook, .breakLoopHold, .planReady, .paywall, .exitOffer:
            return true
        case .loading:
            return planGenerationProgress >= 100
        case .recognition:
            return !onboardingManager.state.recognitionResponses.isEmpty
        case .system:
            return onboardingManager.state.systemResponse != nil
        case .costSlider:
            return onboardingManager.state.weeklySpending > 0
        case .future:
            return !trimmedFutureVision.isEmpty
        case .nameInput:
            return !trimmedName.isEmpty
        case .startPoint:
            return onboardingManager.state.startPoint != nil
        case .triggerQuestion:
            return onboardingManager.state.triggerQuestion != nil
        case .profileQuestions:
            if profileQuestionPage == 0 {
                return profileQuestionAnswer(for: "age") != nil
                    && profileQuestionAnswer(for: "gender") != nil
            }
            return profileQuestionAnswer(for: "quit") != nil
        }
    }

    private var stepLabel: String {
        switch onboardingManager.currentStep {
        case .hook: return "Hook"
        case .recognition: return "Recognition"
        case .system: return "System"
        case .breakLoopHold: return "Break Loop"
        case .costSlider: return "Cost"
        case .future: return "Future"
        case .nameInput: return "Name"
        case .startPoint: return "Start"
        case .triggerQuestion: return "Trigger"
        case .profileQuestions: return "Profile"
        case .loading: return "Loading"
        case .planReady: return "Ready"
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

    private var trimmedFutureVision: String {
        onboardingManager.state.futureVision.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func toggleRecognition(_ title: String) {
        if onboardingManager.state.recognitionResponses.contains(title) {
            onboardingManager.state.recognitionResponses.removeAll { $0 == title }
        } else {
            onboardingManager.state.recognitionResponses.append(title)
            OnboardingHaptics.soft()
        }

        onboardingManager.state.recognitionResponse = onboardingManager.state.recognitionResponses.first
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

    private var futureVisionBinding: Binding<String> {
        Binding(
            get: { onboardingManager.state.futureVision },
            set: { newValue in
                if newValue.contains("\n") {
                    onboardingManager.state.futureVision = newValue.replacingOccurrences(of: "\n", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                    focusedField = nil
                } else {
                    onboardingManager.state.futureVision = newValue
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

    private func toggleProfileQuestion(_ question: String) {
        if onboardingManager.state.profileQuestions.contains(question) {
            onboardingManager.state.profileQuestions.removeAll { $0 == question }
        } else {
            onboardingManager.state.profileQuestions.append(question)
        }
    }

    private func profileQuestionAnswer(for key: String) -> String? {
        onboardingManager.state.profileQuestions.first { $0.hasPrefix("\(key):") }
            .map { String($0.dropFirst(key.count + 1)) }
    }

    private func setProfileQuestionAnswer(_ answer: String, for key: String) {
        onboardingManager.state.profileQuestions.removeAll { $0.hasPrefix("\(key):") }
        onboardingManager.state.profileQuestions.append("\(key):\(answer)")
    }

    private func clearProfileQuestionAnswer(for key: String) {
        onboardingManager.state.profileQuestions.removeAll { $0.hasPrefix("\(key):") }
    }

    private func syncProfileQuestionPage() {
        let hasBasicProfile = profileQuestionAnswer(for: "age") != nil
            && profileQuestionAnswer(for: "gender") != nil
        let hasQuitAttempts = profileQuestionAnswer(for: "quit") != nil

        if !hasBasicProfile {
            profileQuestionPage = 0
        } else if !hasQuitAttempts {
            profileQuestionPage = 1
        } else {
            profileQuestionPage = 0
        }
    }

    private func advanceProfileQuestionPage() {
        if profileQuestionPage < 1 {
            withAnimation(OnboardingPageTransition.animation) {
                profileQuestionPage += 1
            }
        } else {
            navigationDirection = .forward
            withAnimation(OnboardingPageTransition.animation) {
                onboardingManager.nextStep()
            }
        }
    }

    private func profileQuestionDisplayText(for option: String) -> String {
        switch option {
        case "Under 18":
            return "<18"
        case "18–25":
            return "18–25"
        case "25+":
            return ">25"
        case "No":
            return "0"
        case "A few times":
            return "1–2"
        case "Many times":
            return ">2"
        case "Male":
            return "male"
        case "Female":
            return "female"
        case "Other":
            return "other"
        default:
            return option
        }
    }

    private var selectedProfileAge: Int {
        profileAge(for: profileQuestionAnswer(for: "age")) ?? 25
    }

    private var profileAgeBinding: Binding<Int> {
        Binding(
            get: { profileSelectedAge },
            set: { newValue in
                profileSelectedAge = newValue
                setProfileQuestionAnswer(storedAgeBucket(for: newValue), for: "age")
            }
        )
    }

    private var selectedQuitAttemptDisplay: String {
        profileSelectedQuitAttempt
    }

    private func basicProfileContent(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            OnboardingSectionCard(
                title: "Age",
                subtitle: "",
                headerSpacing: 0,
                contentSpacing: 8
            ) {
                OnboardingWheelValuePicker(
                    title: "Current age",
                    valueText: "\(profileSelectedAge)",
                    selection: profileAgeBinding,
                    values: profileAgeValues,
                    valueFontSize: 28,
                    wheelHeight: 82,
                    verticalPadding: 2
                )
            }

            OnboardingSectionCard(
                title: "Gender",
                subtitle: "",
                headerSpacing: 0,
                contentSpacing: 8
            ) {
                OnboardingPillSelector(
                    options: profileGenderOptions,
                    selectedValue: profileQuestionAnswer(for: "gender"),
                    minItemWidth: 132,
                    itemHeight: 38
                ) { value in
                    setProfileQuestionAnswer(value, for: "gender")
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }

    private func quitAttemptsContent(width: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            OnboardingSectionCard(
                title: "Quit attempts",
                subtitle: "",
                headerSpacing: 4,
                contentSpacing: 8
            ) {
                OnboardingSteppedSlider(
                    options: quitAttemptDisplayOptions,
                    title: { $0 },
                    detail: quitAttemptDetail(for:),
                    selection: profileSelectedQuitAttempt,
                    titleFontSize: 22,
                    labelFontSize: 11,
                    verticalPadding: 2
                ) { value in
                    profileSelectedQuitAttempt = value
                    setProfileQuestionAnswer(storedQuitAttemptValue(for: value), for: "quit")
                }
            }
        }
        .frame(width: width, alignment: .leading)
    }

    private func storedAgeBucket(for age: Int) -> String {
        if age < 18 {
            return "Under 18"
        }
        if age <= 25 {
            return "18–25"
        }
        return "25+"
    }

    private func profileAge(for storedValue: String?) -> Int? {
        switch storedValue {
        case "Under 18":
            return 17
        case "18–25":
            return 22
        case "25+":
            return 30
        default:
            return nil
        }
    }

    private func storedQuitAttemptValue(for displayValue: String) -> String {
        switch displayValue {
        case "Never":
            return "No"
        case "1-2 times":
            return "A few times"
        case "3-5 times":
            return "3-5 times"
        case "Many times":
            return "Many times"
        default:
            return "No"
        }
    }

    private func displayQuitAttemptValue(for storedValue: String?) -> String? {
        switch storedValue {
        case "No":
            return "Never"
        case "A few times":
            return "1-2 times"
        case "3-5 times":
            return "3-5 times"
        case "Many times":
            return "Many times"
        default:
            return nil
        }
    }

    private func quitAttemptDetail(for displayValue: String) -> String {
        switch displayValue {
        case "Never":
            return "You are approaching this for the first time."
        case "1-2 times":
            return "You already know some of your friction points."
        case "3-5 times":
            return "We should lean more on structure and relapse prevention."
        case "Many times":
            return "Consistency and calm support will matter most."
        default:
            return ""
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
            let checkpoints: [(Int, UInt64)] = [
                (10, 42),
                (22, 48),
                (34, 38),
                (48, 46),
                (64, 44),
                (78, 48),
                (90, 42),
                (96, 55),
                (100, 75)
            ]

            var currentValue = 0
            for checkpoint in checkpoints {
                guard !Task.isCancelled else { return }
                let target = checkpoint.0
                let sleepMs = checkpoint.1

                for value in stride(from: currentValue, through: target, by: 2) {
                    guard !Task.isCancelled else { return }
                    await MainActor.run {
                        planGenerationProgress = value
                    }
                    try? await Task.sleep(for: .milliseconds(Int(sleepMs)))
                }

                currentValue = target
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

        if onboardingManager.currentStep == .profileQuestions, profileQuestionPage > 0 {
            navigationDirection = .backward
            withAnimation(OnboardingPageTransition.animation) {
                profileQuestionPage -= 1
            }
            return
        }

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

        if onboardingManager.currentStep == .profileQuestions, profileQuestionPage < 1 {
            navigationDirection = .forward
            withAnimation(OnboardingPageTransition.animation) {
                profileQuestionPage += 1
            }
            return
        }

        navigationDirection = .forward
        debugPrint("[Onboarding] progressing to next step from \(stepLabelForDebug(onboardingManager.currentStep))")
        withAnimation(OnboardingPageTransition.animation) {
            onboardingManager.nextStep()
        }
    }

    private func startBreakLoopHold() {
        guard onboardingManager.currentStep == .breakLoopHold else { return }
        guard !breakLoopHoldCompleted else { return }
        guard !breakLoopIsHolding else { return }

        breakLoopHoldTask?.cancel()
        breakLoopIsHolding = true

        breakLoopHoldTask = Task {
            let duration: Double = 1.15
            let steps = 30

            for step in 1...steps {
                guard !Task.isCancelled else { return }

                let progress = CGFloat(step) / CGFloat(steps)
                await MainActor.run {
                    withAnimation(.linear(duration: duration / Double(steps))) {
                        breakLoopHoldProgress = progress
                    }
                }

                try? await Task.sleep(for: .seconds(duration / Double(steps)))
            }

            guard !Task.isCancelled else { return }

            await MainActor.run {
                breakLoopHoldCompleted = true
                breakLoopIsHolding = false
                onboardingManager.state.breakLoopCommitment = "hold_completed"
                debugPrint("[Onboarding] break loop hold success")
                navigationDirection = .forward
                withAnimation(OnboardingPageTransition.animation) {
                    onboardingManager.nextStep()
                }
            }
        }
    }

    private func cancelBreakLoopHoldIfNeeded() {
        guard !breakLoopHoldCompleted else { return }

        breakLoopHoldTask?.cancel()
        breakLoopHoldTask = nil
        breakLoopIsHolding = false

        withAnimation(.easeOut(duration: 0.18)) {
            breakLoopHoldProgress = 0
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
                    title: "You are all set.",
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
                    title: "You are all set.",
                    message: "Your subscription is active on this device."
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
        case .hook: return "hook"
        case .recognition: return "recognition"
        case .system: return "system"
        case .breakLoopHold: return "break_loop_hold"
        case .costSlider: return "cost_slider"
        case .future: return "future"
        case .nameInput: return "name_input"
        case .startPoint: return "start_point"
        case .triggerQuestion: return "trigger_question"
        case .profileQuestions: return "profile_questions"
        case .loading: return "loading"
        case .planReady: return "plan_ready"
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
