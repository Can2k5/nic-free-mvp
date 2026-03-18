import Foundation
import SwiftUI

enum ThemeMode: String, CaseIterable, Codable, Identifiable {
    case system
    case light
    case dark

    var id: String { rawValue }

    var title: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var subtitle: String {
        switch self {
        case .system: return "Follow your device appearance."
        case .light: return "Always use the bright theme."
        case .dark: return "Always use the dark theme."
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

@MainActor
final class ThemeManager: ObservableObject {
    @Published var mode: ThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: StorageKey.themeMode.rawValue)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: StorageKey.themeMode.rawValue)
        self.mode = ThemeMode(rawValue: stored ?? "") ?? .light
    }

    var preferredColorScheme: ColorScheme? {
        mode.preferredColorScheme
    }
}

enum CravingTrigger: String, CaseIterable, Codable, Identifiable {
    case stress
    case boredom
    case social
    case coffee
    case alcohol
    case afterMeal = "after_meal"
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stress: return "Stress"
        case .boredom: return "Boredom"
        case .social: return "Social"
        case .coffee: return "Coffee"
        case .alcohol: return "Alcohol"
        case .afterMeal: return "After meal"
        case .other: return "Other"
        }
    }
}

enum CravingTimeOfDay: String, CaseIterable, Codable, Identifiable {
    case morning
    case afternoon
    case evening
    case night

    var id: String { rawValue }

    var title: String {
        switch self {
        case .morning: return "Morning"
        case .afternoon: return "Afternoon"
        case .evening: return "Evening"
        case .night: return "Night"
        }
    }

    static func from(date: Date) -> CravingTimeOfDay {
        let hour = Calendar.current.component(.hour, from: date)
        switch hour {
        case 5..<11: return .morning
        case 11..<17: return .afternoon
        case 17..<22: return .evening
        default: return .night
        }
    }
}

struct CravingEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let intensity: Int
    let trigger: CravingTrigger
    let succeeded: Bool
    let timeOfDay: CravingTimeOfDay

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        intensity: Int,
        trigger: CravingTrigger,
        succeeded: Bool
    ) {
        self.id = id
        self.timestamp = timestamp
        self.intensity = intensity
        self.trigger = trigger
        self.succeeded = succeeded
        self.timeOfDay = CravingTimeOfDay.from(date: timestamp)
    }
}

enum SlipType: String, CaseIterable, Codable, Identifiable {
    case justOnce
    case fullRelapse
    case multipleTimesToday

    var id: String { rawValue }

    var title: String {
        switch self {
        case .justOnce: return "Just once"
        case .fullRelapse: return "A full relapse"
        case .multipleTimesToday: return "Multiple times today"
        }
    }
}

enum SlipTrigger: String, CaseIterable, Codable, Identifiable {
    case stress
    case socialSituation
    case alcohol
    case boredom
    case cravingTooStrong
    case other

    var id: String { rawValue }

    var title: String {
        switch self {
        case .stress: return "Stress"
        case .socialSituation: return "Social situation"
        case .alcohol: return "Alcohol"
        case .boredom: return "Boredom"
        case .cravingTooStrong: return "Craving was too strong"
        case .other: return "Other"
        }
    }
}

enum SlipRecoveryMode: String, CaseIterable, Codable, Identifiable {
    case keepGoing
    case resetStreak

    var id: String { rawValue }

    var title: String {
        switch self {
        case .keepGoing: return "Keep going from here"
        case .resetStreak: return "Reset my streak"
        }
    }
}

struct SlipEvent: Identifiable, Codable {
    let id: UUID
    let timestamp: Date
    let type: SlipType
    let trigger: SlipTrigger
    let recoveryMode: SlipRecoveryMode

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        type: SlipType,
        trigger: SlipTrigger,
        recoveryMode: SlipRecoveryMode
    ) {
        self.id = id
        self.timestamp = timestamp
        self.type = type
        self.trigger = trigger
        self.recoveryMode = recoveryMode
    }
}

enum DailyCravingLevel: String, CaseIterable, Codable, Identifiable {
    case low
    case medium
    case high

    var id: String { rawValue }

    var title: String {
        rawValue.capitalized
    }
}

struct DailyCheckin: Identifiable, Codable {
    let id: UUID
    let date: Date
    let cravingLevel: DailyCravingLevel

    init(id: UUID = UUID(), date: Date = .now, cravingLevel: DailyCravingLevel) {
        self.id = id
        self.date = date
        self.cravingLevel = cravingLevel
    }
}

enum OnboardingStep: Int, CaseIterable, Codable, Identifiable {
    case welcome
    case name
    case consumption
    case goal
    case pace
    case motivation
    case concerns
    case planGeneration
    case planReveal
    case planReady
    case value
    case savingsReminder
    case paywall
    case exitOffer

    var id: Int { rawValue }

    var position: Int { rawValue + 1 }
}

struct OnboardingState: Codable {
    var currentStep: OnboardingStep = .welcome
    var name: String = ""
    var weeklySpending: Double = 35
    var goal: String?
    var pace: String?
    var motivation: String = ""
    var concerns: [String] = []
    var accountChoice: String?
    var notificationsChoice: String?
}

@MainActor
final class OnboardingManager: ObservableObject {
    @Published var state: OnboardingState {
        didSet { persist() }
    }

    init() {
        self.state = Self.load() ?? OnboardingState()
    }

    var currentStep: OnboardingStep {
        state.currentStep
    }

    func nextStep() {
        guard let next = OnboardingStep(rawValue: currentStep.rawValue + 1) else { return }
        goToStep(next)
    }

    func previousStep() {
        guard let previous = OnboardingStep(rawValue: currentStep.rawValue - 1) else { return }
        goToStep(previous)
    }

    func goToStep(_ step: OnboardingStep) {
        state.currentStep = step
    }

    func reset() {
        state = OnboardingState()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(state) {
            UserDefaults.standard.set(data, forKey: StorageKey.onboardingState.rawValue)
        }
    }

    private static func load() -> OnboardingState? {
        guard let data = UserDefaults.standard.data(forKey: StorageKey.onboardingState.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(OnboardingState.self, from: data)
    }
}

struct RewardToastContent: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let message: String
}

enum JourneyAchievementID: String, CaseIterable, Identifiable {
    case firstDay
    case firstRescue
    case threeDays
    case saver50
    case sevenDays
    case tenRescues
    case saver100
    case fourteenDays

    var id: String { rawValue }

    var title: String {
        switch self {
        case .firstDay: return "First 24 hours"
        case .firstRescue: return "First craving resisted"
        case .threeDays: return "3 steady days"
        case .saver50: return "Saved EUR 50"
        case .sevenDays: return "7 day streak"
        case .tenRescues: return "10 urges survived"
        case .saver100: return "Saved EUR 100"
        case .fourteenDays: return "Two week streak"
        }
    }

    var subtitle: String {
        switch self {
        case .firstDay: return "A full nicotine-free day."
        case .firstRescue: return "You got through an urge."
        case .threeDays: return "Momentum is forming."
        case .saver50: return "Your money is staying with you."
        case .sevenDays: return "A full week of recovery."
        case .tenRescues: return "You are building resilience."
        case .saver100: return "Visible financial progress."
        case .fourteenDays: return "Two weeks of real change."
        }
    }

    var symbol: String {
        switch self {
        case .firstDay: return "sun.max.fill"
        case .firstRescue: return "shield.fill"
        case .threeDays: return "leaf.fill"
        case .saver50: return "eurosign.circle.fill"
        case .sevenDays: return "sparkles"
        case .tenRescues: return "figure.mind.and.body"
        case .saver100: return "crown.fill"
        case .fourteenDays: return "rosette"
        }
    }

    var accentTop: Color {
        switch self {
        case .firstDay: return Color(red: 0.99, green: 0.80, blue: 0.48)
        case .firstRescue: return Color(red: 0.55, green: 0.77, blue: 0.98)
        case .threeDays: return Color(red: 0.50, green: 0.86, blue: 0.66)
        case .saver50: return Color(red: 0.99, green: 0.64, blue: 0.60)
        case .sevenDays: return Color(red: 0.66, green: 0.56, blue: 0.99)
        case .tenRescues: return Color(red: 0.50, green: 0.90, blue: 0.88)
        case .saver100: return Color(red: 1.00, green: 0.73, blue: 0.44)
        case .fourteenDays: return Color(red: 0.99, green: 0.58, blue: 0.78)
        }
    }

    var accentBottom: Color {
        switch self {
        case .firstDay: return Color(red: 0.96, green: 0.57, blue: 0.30)
        case .firstRescue: return Color(red: 0.34, green: 0.53, blue: 0.95)
        case .threeDays: return Color(red: 0.23, green: 0.67, blue: 0.42)
        case .saver50: return Color(red: 0.90, green: 0.32, blue: 0.39)
        case .sevenDays: return Color(red: 0.43, green: 0.28, blue: 0.92)
        case .tenRescues: return Color(red: 0.19, green: 0.66, blue: 0.63)
        case .saver100: return Color(red: 0.95, green: 0.48, blue: 0.24)
        case .fourteenDays: return Color(red: 0.88, green: 0.30, blue: 0.61)
        }
    }
}

struct JourneyAchievement: Identifiable {
    let id: JourneyAchievementID
    let title: String
    let subtitle: String
    let symbol: String
    let progress: Double
    let progressText: String
    let isUnlocked: Bool
    let accentTop: Color
    let accentBottom: Color
}

@MainActor
final class AppState: ObservableObject {
    @Published var activeRescueSessionID = UUID()
    @Published var rewardToast: RewardToastContent?

    @Published private var onboardingCompleted: Bool { didSet { persist() } }
    @Published var profileName: String { didSet { persist() } }
    @Published var onboardingGoals: [String] { didSet { persist() } }
    @Published var onboardingTriggers: [String] { didSet { persist() } }
    @Published var quitDate: Date { didSet { persist() } }
    @Published var dailySpend: Double { didSet { persist() } }
    @Published var cravingEvents: [CravingEvent] { didSet { persist() } }
    @Published var slipEvents: [SlipEvent] { didSet { persist() } }
    @Published var quitReasons: [String] { didSet { persist() } }
    @Published var dailyCheckins: [DailyCheckin] { didSet { persist() } }

    private var rewardToastTask: Task<Void, Never>?

    init() {
        let defaults = UserDefaults.standard
        self.onboardingCompleted = defaults.object(forKey: StorageKey.onboardingCompleted.rawValue) as? Bool ?? false
        self.profileName = defaults.string(forKey: StorageKey.profileName.rawValue) ?? ""
        self.onboardingGoals = Self.load([String].self, for: .onboardingGoals) ?? []
        self.onboardingTriggers = Self.load([String].self, for: .onboardingTriggers) ?? []
        self.quitDate = defaults.object(forKey: StorageKey.quitDate.rawValue) as? Date
            ?? Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))
            ?? .now
        self.dailySpend = defaults.object(forKey: StorageKey.dailySpend.rawValue) as? Double ?? 8.5
        self.cravingEvents = Self.load([CravingEvent].self, for: .cravingEvents) ?? []
        self.slipEvents = Self.load([SlipEvent].self, for: .slipEvents) ?? []
        self.quitReasons = Self.load([String].self, for: .quitReasons) ?? []
        self.dailyCheckins = Self.load([DailyCheckin].self, for: .dailyCheckins) ?? []
    }

    var hasCompletedOnboarding: Bool {
        get { onboardingCompleted }
        set { onboardingCompleted = newValue }
    }

    var cravingsDefeated: Int {
        cravingEvents.filter(\.succeeded).count
    }

    var nicotineFreeDays: Int {
        let start = Calendar.current.startOfDay(for: quitDate)
        let today = Calendar.current.startOfDay(for: .now)
        return max(Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0, 0)
    }

    var moneySaved: Double {
        Double(nicotineFreeDays) * dailySpend
    }

    var cigarettesAvoided: Int {
        max(Int((moneySaved / 0.45).rounded()), 0)
    }

    var smokeFreeTimeText: String {
        let components = Calendar.current.dateComponents([.day, .hour], from: quitDate, to: .now)
        let days = max(components.day ?? 0, 0)
        let hours = max(components.hour ?? 0, 0) % 24
        return "\(days)d \(hours)h"
    }

    var journeyMotivations: [String] {
        let combined = (quitReasons + onboardingGoals).filter {
            !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
        let unique = Array(NSOrderedSet(array: combined)) as? [String] ?? []
        let defaults = ["Health", "Family", "Freedom", "Money"]
        return Array((unique.isEmpty ? defaults : unique).prefix(4))
    }

    var journeyAchievements: [JourneyAchievement] {
        JourneyAchievementID.allCases.map { achievement in
            let metrics = achievementMetrics(for: achievement)
            return JourneyAchievement(
                id: achievement,
                title: achievement.title,
                subtitle: achievement.subtitle,
                symbol: achievement.symbol,
                progress: metrics.progress,
                progressText: metrics.progressText,
                isUnlocked: metrics.isUnlocked,
                accentTop: achievement.accentTop,
                accentBottom: achievement.accentBottom
            )
        }
    }

    var unlockedJourneyAchievements: [JourneyAchievement] {
        journeyAchievements.filter(\.isUnlocked)
    }

    var recentUnlockedJourneyAchievements: [JourneyAchievement] {
        Array(unlockedJourneyAchievements.reversed().prefix(3))
    }

    var nextJourneyAchievement: JourneyAchievement? {
        journeyAchievements
            .filter { !$0.isUnlocked }
            .max(by: { $0.progress < $1.progress })
    }

    var dynamicMotivation: String {
        if nicotineFreeDays < 3 {
            return "The first days are the hardest. Getting through today matters."
        }
        if cravingsDefeated >= 10 {
            return "You have already survived many urges. That strength compounds."
        }
        if nicotineFreeDays >= 7 {
            return "One week nicotine free. Your body is already recovering."
        }
        return "Every urge you outlast is evidence that this new rhythm is taking hold."
    }

    var highlightedQuitReason: String? {
        guard !quitReasons.isEmpty else { return nil }
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: .now) ?? 0
        return quitReasons[dayOfYear % quitReasons.count]
    }

    var latestCheckin: DailyCheckin? {
        dailyCheckins.sorted(by: { $0.date > $1.date }).first
    }

    var totalCravingsSurvived: Int {
        cravingsDefeated
    }

    var cravingsThisWeek: Int {
        weekEvents.count
    }

    var mostCommonTriggerTitle: String {
        mostCommonTrigger(in: cravingEvents)?.title ?? "No pattern yet"
    }

    var mostCommonTimeOfCravingTitle: String {
        let grouped = Dictionary(grouping: cravingEvents, by: \.timeOfDay)
        return grouped.max(by: { $0.value.count < $1.value.count })?.key.title ?? "No pattern yet"
    }

    var averageCravingIntensityThisWeekText: String {
        averageIntensityText(for: weekEvents)
    }

    var weeklyCravingsSurvivedText: String {
        let count = weekEvents.filter(\.succeeded).count
        return count == 0 ? "No data yet" : "\(count)"
    }

    var strongestTriggerThisWeekText: String {
        mostCommonTrigger(in: weekEvents)?.title ?? "No data yet"
    }

    var weeklyAverageIntensityText: String {
        averageIntensityText(for: weekEvents)
    }

    func saveCravingEvent(intensity: Int, trigger: CravingTrigger, succeeded: Bool) {
        let event = CravingEvent(intensity: intensity, trigger: trigger, succeeded: succeeded)
        cravingEvents.insert(event, at: 0)
    }

    func beginCravingSession() {
        activeRescueSessionID = UUID()
    }

    func applyOnboarding(_ onboarding: OnboardingState) {
        profileName = onboarding.name.trimmingCharacters(in: .whitespacesAndNewlines)
        onboardingGoals = onboarding.goal.map { [$0] } ?? []
        onboardingTriggers = onboarding.concerns
        dailySpend = max(onboarding.weeklySpending / 7, 0)

        var reasons: [String] = []
        if let goal = onboarding.goal?.trimmingCharacters(in: .whitespacesAndNewlines), !goal.isEmpty {
            reasons.append(goal)
        }
        let motivation = onboarding.motivation.trimmingCharacters(in: .whitespacesAndNewlines)
        if !motivation.isEmpty, !reasons.contains(motivation) {
            reasons.append(motivation)
        }
        quitReasons = Array(reasons.prefix(3))

        hasCompletedOnboarding = true
    }

    func recordSlip(type: SlipType, trigger: SlipTrigger, recoveryMode: SlipRecoveryMode) {
        let event = SlipEvent(type: type, trigger: trigger, recoveryMode: recoveryMode)
        slipEvents.insert(event, at: 0)
        if recoveryMode == .resetStreak {
            quitDate = Calendar.current.startOfDay(for: .now)
        }
    }

    func addQuitReason(_ reason: String) {
        let cleaned = reason.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty, quitReasons.count < 3, !quitReasons.contains(cleaned) else { return }
        quitReasons.append(cleaned)
    }

    func removeQuitReason(_ reason: String) {
        quitReasons.removeAll { $0 == reason }
    }

    func saveDailyCheckin(level: DailyCravingLevel) {
        let today = Calendar.current.startOfDay(for: .now)
        if let index = dailyCheckins.firstIndex(where: { Calendar.current.isDate($0.date, inSameDayAs: today) }) {
            dailyCheckins[index] = DailyCheckin(id: dailyCheckins[index].id, date: today, cravingLevel: level)
        } else {
            dailyCheckins.insert(DailyCheckin(date: today, cravingLevel: level), at: 0)
        }
    }

    func resetProgress() {
        quitDate = Calendar.current.startOfDay(for: .now)
        cravingEvents = []
        slipEvents = []
        dailyCheckins = []
    }

    func clearCravingHistory() {
        cravingEvents = []
    }

    func resetOnboardingForDebug() {
        hasCompletedOnboarding = false
        profileName = ""
        onboardingGoals = []
        onboardingTriggers = []
        quitReasons = []
    }

    func showRewardToast(title: String, message: String, duration: Double = 1.8) {
        rewardToastTask?.cancel()
        withAnimation(.easeOut(duration: 0.25)) {
            rewardToast = RewardToastContent(title: title, message: message)
        }

        rewardToastTask = Task { @MainActor in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            withAnimation(.easeOut(duration: 0.3)) {
                rewardToast = nil
            }
        }
    }

    private var weekEvents: [CravingEvent] {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -6, to: Calendar.current.startOfDay(for: .now)) ?? .now
        return cravingEvents.filter { $0.timestamp >= weekAgo }
    }

    private func mostCommonTrigger(in events: [CravingEvent]) -> CravingTrigger? {
        let grouped = Dictionary(grouping: events, by: \.trigger)
        return grouped.max(by: { lhs, rhs in
            if lhs.value.count == rhs.value.count {
                return lhs.key.title > rhs.key.title
            }
            return lhs.value.count < rhs.value.count
        })?.key
    }

    private func averageIntensityText(for events: [CravingEvent]) -> String {
        guard !events.isEmpty else { return "No data yet" }
        let average = Double(events.reduce(0) { $0 + $1.intensity }) / Double(events.count)
        return String(format: "%.1f / 5", average)
    }

    private func achievementMetrics(for achievement: JourneyAchievementID) -> (
        progress: Double,
        progressText: String,
        isUnlocked: Bool
    ) {
        switch achievement {
        case .firstDay:
            return boundedProgress(current: Double(nicotineFreeDays), goal: 1) { current in
                "\(Int(current)) / 1 day"
            }
        case .firstRescue:
            return boundedProgress(current: Double(cravingsDefeated), goal: 1) { current in
                "\(Int(current)) / 1 rescue"
            }
        case .threeDays:
            return boundedProgress(current: Double(nicotineFreeDays), goal: 3) { current in
                "\(Int(current)) / 3 days"
            }
        case .saver50:
            return boundedProgress(current: moneySaved, goal: 50) { current in
                "\(Int(current.rounded())) / 50"
            }
        case .sevenDays:
            return boundedProgress(current: Double(nicotineFreeDays), goal: 7) { current in
                "\(Int(current)) / 7 days"
            }
        case .tenRescues:
            return boundedProgress(current: Double(cravingsDefeated), goal: 10) { current in
                "\(Int(current)) / 10 rescues"
            }
        case .saver100:
            return boundedProgress(current: moneySaved, goal: 100) { current in
                "\(Int(current.rounded())) / 100"
            }
        case .fourteenDays:
            return boundedProgress(current: Double(nicotineFreeDays), goal: 14) { current in
                "\(Int(current)) / 14 days"
            }
        }
    }

    private func boundedProgress(
        current: Double,
        goal: Double,
        valueFormatter: (Double) -> String
    ) -> (progress: Double, progressText: String, isUnlocked: Bool) {
        let bounded = min(max(current, 0), goal)
        let unlocked = bounded >= goal
        return (
            progress: goal == 0 ? 1 : bounded / goal,
            progressText: unlocked ? "Unlocked" : valueFormatter(bounded),
            isUnlocked: unlocked
        )
    }

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(onboardingCompleted, forKey: StorageKey.onboardingCompleted.rawValue)
        defaults.set(profileName, forKey: StorageKey.profileName.rawValue)
        save(onboardingGoals, for: .onboardingGoals)
        save(onboardingTriggers, for: .onboardingTriggers)
        defaults.set(quitDate, forKey: StorageKey.quitDate.rawValue)
        defaults.set(dailySpend, forKey: StorageKey.dailySpend.rawValue)
        save(cravingEvents, for: .cravingEvents)
        save(slipEvents, for: .slipEvents)
        save(quitReasons, for: .quitReasons)
        save(dailyCheckins, for: .dailyCheckins)
    }

    private func save<T: Encodable>(_ value: T, for key: StorageKey) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key.rawValue)
        }
    }

    private static func load<T: Decodable>(_ type: T.Type, for key: StorageKey) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key.rawValue) else {
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
}

private enum StorageKey: String {
    case onboardingCompleted
    case onboardingState
    case profileName
    case themeMode
    case onboardingGoals
    case onboardingTriggers
    case quitDate
    case dailySpend
    case cravingEvents
    case slipEvents
    case quitReasons
    case dailyCheckins
}
