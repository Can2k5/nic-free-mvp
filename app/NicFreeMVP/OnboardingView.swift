import SwiftUI

struct OnboardingView: View {
    private enum Step: Int, CaseIterable {
        case welcome
        case goals
        case triggers
        case dailySpend
        case lastUse
        case value
    }

    private enum LastUseSelection: String, CaseIterable, Identifiable {
        case today
        case yesterday
        case thisWeek
        case earlier

        var id: String { rawValue }

        var title: String {
            switch self {
            case .today: return "Today"
            case .yesterday: return "Yesterday"
            case .thisWeek: return "This week"
            case .earlier: return "Earlier"
            }
        }
    }

    @EnvironmentObject private var appState: AppState

    @State private var step: Step = .welcome
    @State private var draftGoals: [String] = []
    @State private var draftTriggers: [String] = []
    @State private var draftDailySpend: Double = 8.5
    @State private var lastUseSelection: LastUseSelection = .today
    @State private var earlierDate: Date = .now

    private let goalOptions = [
        "Better health", "More control", "More energy", "Better sleep", "Less anxiety",
        "Save money", "Better focus", "Freedom", "Fitness", "Confidence"
    ]

    private let triggerOptions = [
        "Stress", "Boredom", "Coffee", "After meals", "Alcohol",
        "Social situations", "Driving", "Nighttime", "Loneliness", "Habit / autopilot"
    ]

    var body: some View {
        ZStack {
            AppBackground()

            VStack(spacing: 0) {
                ProgressDots(currentIndex: step.rawValue, total: Step.allCases.count)
                    .padding(.top, 24)

                Spacer(minLength: 18)

                ZStack {
                    stepView
                        .id(step.rawValue)
                        .transition(
                            .asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            )
                        )
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipped()
                .animation(.spring(response: 0.42, dampingFraction: 0.92), value: step)

                Spacer(minLength: 18)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 28)
        }
        .onAppear {
            draftGoals = appState.onboardingGoals
            draftTriggers = appState.onboardingTriggers
            draftDailySpend = appState.dailySpend
            earlierDate = appState.quitDate
        }
    }

    @ViewBuilder
    private var stepView: some View {
        switch step {
        case .welcome:
            welcomeStep
        case .goals:
            goalsStep
        case .triggers:
            triggersStep
        case .dailySpend:
            dailySpendStep
        case .lastUse:
            lastUseStep
        case .value:
            valueStep
        }
    }

    private var welcomeStep: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.56))
                        .frame(width: 140, height: 140)
                        .shadow(color: Color.shadowColor.opacity(0.08), radius: 26, x: 0, y: 18)

                    Image(systemName: "wind")
                        .font(.system(size: 42, weight: .medium))
                        .foregroundStyle(Color.heroAccent)
                }

                VStack(spacing: 16) {
                    Text("Break free from nicotine.")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)
                        .multilineTextAlignment(.center)

                    Text("You do not need perfect willpower.\nYou need a system that helps you through cravings, setbacks, and progress.")
                        .font(.title3)
                        .foregroundStyle(Color.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(5)
                }
            }

            Spacer()

            primaryButton(title: "Start") {
                advance()
            }
        }
    }

    private var goalsStep: some View {
        VStack(spacing: 22) {
            ScreenHeader(
                eyebrow: "Step 1",
                title: "What do you want to get back?",
                subtitle: "Choose the outcomes that matter most. This gives your quit some emotional weight."
            )

            OnboardingCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose up to 3")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)

                    SelectionChipGrid(
                        items: goalOptions,
                        selection: draftGoals,
                        selectionLimit: 3,
                        iconForItem: chipSymbol(for:),
                        action: toggleGoal
                    )
                }
            }

            Spacer()

            primaryButton(title: "Continue", isEnabled: !draftGoals.isEmpty) {
                advance()
            }
        }
    }

    private var triggersStep: some View {
        VStack(spacing: 22) {
            ScreenHeader(
                eyebrow: "Step 2",
                title: "What usually pulls you back in?",
                subtitle: "We will use this to make your support feel more relevant when cravings show up."
            )

            OnboardingCard {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Choose up to 3")
                        .font(.footnote.weight(.semibold))
                        .foregroundStyle(Color.secondaryText)

                    SelectionChipGrid(
                        items: triggerOptions,
                        selection: draftTriggers,
                        selectionLimit: 3,
                        iconForItem: chipSymbol(for:),
                        action: toggleTrigger
                    )
                }
            }

            Spacer()

            primaryButton(title: "Continue", isEnabled: !draftTriggers.isEmpty) {
                advance()
            }
        }
    }

    private var dailySpendStep: some View {
        VStack(spacing: 22) {
            ScreenHeader(
                eyebrow: "Step 3",
                title: "How much do you spend per day?",
                subtitle: "This is one of the first places your progress becomes tangible."
            )

            OnboardingCard {
                VStack(alignment: .leading, spacing: 20) {
                    Text(draftDailySpend.formatted(.currency(code: "EUR")))
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.ink)

                    Slider(value: $draftDailySpend, in: 0...50, step: 0.5)
                        .tint(Color.buttonBottom)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("That is about \(monthlySpendText) per month")
                            .font(.headline.weight(.semibold))
                            .foregroundStyle(Color.heroAccent)

                        Text("That is about \(yearlySpendText) per year")
                            .font(.subheadline)
                            .foregroundStyle(Color.secondaryText)
                    }
                }
            }

            Spacer()

            primaryButton(title: "Continue") {
                advance()
            }
        }
    }

    private var lastUseStep: some View {
        VStack(spacing: 22) {
            ScreenHeader(
                eyebrow: "Step 4",
                title: "When did you last use nicotine?",
                subtitle: "A quick estimate is enough. We will turn it into your starting point."
            )

            OnboardingCard {
                VStack(alignment: .leading, spacing: 14) {
                    ForEach(LastUseSelection.allCases) { option in
                        Button {
                            lastUseSelection = option
                        } label: {
                            HStack {
                                Text(option.title)
                                    .font(.headline.weight(.semibold))
                                    .foregroundStyle(lastUseSelection == option ? Color.white : Color.ink)
                                Spacer()
                                Image(systemName: lastUseSelection == option ? "checkmark.circle.fill" : "circle")
                                    .foregroundStyle(lastUseSelection == option ? Color.white : Color.secondaryText.opacity(0.7))
                            }
                            .padding(.horizontal, 18)
                            .padding(.vertical, 18)
                            .background {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .fill(lastUseSelection == option ? Color.clear : Color.white.opacity(0.001))
                                    .if(lastUseSelection == option) { view in
                                        view.overlay(
                                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                                .fill(
                                                    LinearGradient(
                                                        colors: [Color.buttonTop, Color.buttonBottom],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                )
                                        )
                                    }
                            }
                            .if(lastUseSelection != option) { view in
                                view.glassPanel(cornerRadius: 20, tint: Color.white, tintOpacity: 0.16, shadowOpacity: 0.05)
                            }
                        }
                        .buttonStyle(.plain)
                    }

                    if lastUseSelection == .earlier {
                        DatePicker(
                            "Last use",
                            selection: $earlierDate,
                            in: ...Date(),
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .padding(.top, 4)
                    }
                }
            }

            Spacer()

            primaryButton(title: "Continue") {
                advance()
            }
        }
    }

    private var valueStep: some View {
        VStack(spacing: 22) {
            ScreenHeader(
                eyebrow: "Your Plan",
                title: "Here is what we will help you with.",
                subtitle: "You are not starting from zero. You already gave the app enough context to make support feel personal."
            )

            OnboardingCard(fill: AnyShapeStyle(
                LinearGradient(
                    colors: [Color.white.opacity(0.96), Color(red: 0.95, green: 0.97, blue: 0.95)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )) {
                VStack(alignment: .leading, spacing: 16) {
                    summaryLine("\(goalSummaryLead).")
                    summaryLine("\(triggerSummaryLead).")
                    summaryLine("You are spending about \(monthlySpendText) per month on nicotine.")
                    summaryLine("We will help you survive cravings and understand your patterns.")

                    Text("Nothing is wrong with you. You have a pattern, and patterns can be changed.")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.heroAccent)
                        .lineSpacing(4)
                        .padding(.top, 4)
                }
            }

            Spacer()

            primaryButton(title: "Enter the app") {
                applyOnboardingValues()
                appState.hasCompletedOnboarding = true
            }
        }
    }

    private var monthlySpendText: String {
        (draftDailySpend * 30).formatted(.currency(code: "EUR"))
    }

    private var yearlySpendText: String {
        (draftDailySpend * 365).formatted(.currency(code: "EUR"))
    }

    private var goalSummaryLead: String {
        let items = draftGoals.prefix(2)
        if items.isEmpty {
            return "You want to get back a steadier version of yourself"
        }
        return "You want \(naturalList(from: Array(items)).lowercased())"
    }

    private var triggerSummaryLead: String {
        let items = draftTriggers.prefix(2)
        if items.isEmpty {
            return "Your triggers deserve more understanding"
        }
        return "Your biggest triggers seem to be \(naturalList(from: Array(items)).lowercased())"
    }

    private func summaryLine(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundStyle(Color.ink)
            .lineSpacing(4)
    }

    private func advance() {
        guard let next = Step(rawValue: step.rawValue + 1) else { return }
        withAnimation(.spring(response: 0.42, dampingFraction: 0.92)) {
            step = next
        }
    }

    private func toggleGoal(_ goal: String) {
        toggleItem(goal, in: &draftGoals)
    }

    private func toggleTrigger(_ trigger: String) {
        toggleItem(trigger, in: &draftTriggers)
    }

    private func toggleItem(_ item: String, in array: inout [String]) {
        if let index = array.firstIndex(of: item) {
            array.remove(at: index)
        } else if array.count < 3 {
            array.append(item)
        }
    }

    private func chipSymbol(for item: String) -> String {
        switch item {
        case "Better health": return "heart"
        case "More control": return "dial.low"
        case "More energy": return "bolt"
        case "Better sleep": return "moon"
        case "Less anxiety": return "wind"
        case "Save money": return "eurosign"
        case "Better focus": return "scope"
        case "Freedom": return "bird"
        case "Fitness": return "figure.run"
        case "Confidence": return "sparkles"
        case "Stress": return "cloud.rain"
        case "Boredom": return "hourglass"
        case "Coffee": return "cup.and.saucer"
        case "After meals": return "fork.knife"
        case "Alcohol": return "wineglass"
        case "Social situations": return "person.2"
        case "Driving": return "car"
        case "Nighttime": return "moon.stars"
        case "Loneliness": return "person"
        case "Habit / autopilot": return "repeat"
        default: return "circle"
        }
    }

    private func applyOnboardingValues() {
        appState.onboardingGoals = draftGoals
        appState.onboardingTriggers = draftTriggers
        appState.dailySpend = draftDailySpend
        appState.quitDate = resolvedQuitDate

        if appState.quitReasons.isEmpty {
            appState.quitReasons = Array(draftGoals.prefix(3))
        }
    }

    private var resolvedQuitDate: Date {
        let calendar = Calendar.current
        switch lastUseSelection {
        case .today:
            return .now
        case .yesterday:
            return calendar.date(byAdding: .day, value: -1, to: .now) ?? .now
        case .thisWeek:
            return calendar.date(byAdding: .day, value: -3, to: .now) ?? .now
        case .earlier:
            return earlierDate
        }
    }

    private func naturalList(from items: [String]) -> String {
        switch items.count {
        case 0:
            return ""
        case 1:
            return items[0]
        case 2:
            return "\(items[0]) and \(items[1])"
        default:
            return items.dropLast().joined(separator: ", ") + ", and " + (items.last ?? "")
        }
    }

    private func primaryButton(title: String, isEnabled: Bool = true, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
        }
        .buttonStyle(PrimaryButtonStyle(isEnabled: isEnabled))
        .disabled(!isEnabled)
    }
}

private struct SelectionChipGrid: View {
    let items: [String]
    let selection: [String]
    let selectionLimit: Int
    let iconForItem: (String) -> String
    let action: (String) -> Void

    private let columns = [
        GridItem(.flexible(minimum: 120, maximum: 220), spacing: 12),
        GridItem(.flexible(minimum: 120, maximum: 220), spacing: 12)
    ]

    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 14) {
            ForEach(items, id: \.self) { item in
                let selected = selection.contains(item)
                let disabled = !selected && selection.count >= selectionLimit

                SelectionChip(
                    title: item,
                    symbol: iconForItem(item),
                    isSelected: selected,
                    isDisabled: disabled
                ) {
                    action(item)
                }
                .opacity(disabled ? 0.42 : 1)
            }
        }
    }
}

private struct SelectionChip: View {
    let title: String
    let symbol: String
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button {
            guard !isDisabled else { return }

            withAnimation(.spring(response: 0.22, dampingFraction: 0.55)) {
                isPressed = true
            }

            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
                withAnimation(.spring(response: 0.28, dampingFraction: 0.72)) {
                    isPressed = false
                }
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: symbol)
                    .font(.footnote.weight(.semibold))

                Text(title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            .foregroundStyle(isSelected ? Color.white : Color.ink)
            .padding(.horizontal, 16)
            .padding(.vertical, 11)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                Capsule(style: .continuous)
                    .fill(.ultraThinMaterial)
                    .opacity(isSelected ? 0 : 1)
                    .overlay {
                        if isSelected {
                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.buttonTop.opacity(0.98),
                                            Color.buttonBottom
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            Capsule(style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.48),
                                            Color.mist.opacity(0.28)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
            }
            .overlay {
                Capsule(style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: isSelected
                                ? [Color.white.opacity(0.22), Color.white.opacity(0.06)]
                                : [Color.white.opacity(0.85), Color.white.opacity(0.24)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: isSelected ? Color.buttonBottom.opacity(0.16) : Color.shadowColor.opacity(0.04), radius: isSelected ? 12 : 8, x: 0, y: isSelected ? 7 : 4)
            .scaleEffect(isPressed ? 1.05 : 1)
        }
        .buttonStyle(.plain)
    }
}

private struct OnboardingCard<Content: View>: View {
    private let fill: AnyShapeStyle
    let content: Content

    init(fill: AnyShapeStyle = AnyShapeStyle(Color.cardBackground), @ViewBuilder content: () -> Content) {
        self.fill = fill
        self.content = content()
    }

    var body: some View {
        CardSection(fill: fill) {
            content
        }
    }
}

private struct ProgressDots: View {
    let currentIndex: Int
    let total: Int

    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Capsule()
                    .fill(index == currentIndex ? Color.buttonBottom : Color.white.opacity(0.58))
                    .frame(width: index == currentIndex ? 24 : 8, height: 8)
                    .animation(.easeOut(duration: 0.22), value: currentIndex)
            }
        }
    }
}

#Preview {
    OnboardingView()
        .environmentObject(AppState())
}
