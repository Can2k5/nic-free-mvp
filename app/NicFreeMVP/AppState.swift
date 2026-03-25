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
            SettingsDataStore.shared.updateThemeMode(mode)
        }
    }

    init() {
        self.mode = SettingsDataStore.shared.load().themeMode
    }

    var preferredColorScheme: ColorScheme? {
        mode.preferredColorScheme
    }
}

@MainActor
private final class SettingsDataStore {
    static let shared = SettingsDataStore()

    func load() -> SettingsData {
        if let settings = Self.load(SettingsData.self, for: .settingsData) {
            return settings
        }

        let legacyTheme = UserDefaults.standard.string(forKey: StorageKey.themeMode.rawValue)
        return SettingsData(themeMode: ThemeMode(rawValue: legacyTheme ?? "") ?? .light)
    }

    func updateThemeMode(_ mode: ThemeMode) {
        var settings = load()
        settings.themeMode = mode
        save(settings, for: .settingsData)

        // Keep the old key in sync during the transition.
        UserDefaults.standard.set(mode.rawValue, forKey: StorageKey.themeMode.rawValue)
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
        case .justOnce: return "I used once"
        case .fullRelapse: return "I fully returned to it"
        case .multipleTimesToday: return "I used a few times today"
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
        case .socialSituation: return "Being around others"
        case .alcohol: return "Alcohol"
        case .boredom: return "Boredom"
        case .cravingTooStrong: return "The urge felt too strong"
        case .other: return "Something else"
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
        case .resetStreak: return "Start again from today"
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
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
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

enum SmokeFreeStreakState: String, Codable {
    case active
    case onIce
    case lost
}

struct SmokeFreeStreak: Codable {
    var streakCount: Int = 0
    var streakState: SmokeFreeStreakState = .lost
    var lastSmokeFreeCheckInDate: Date?
    var onIceEnteredAt: Date?
}

// MARK: - Grouped local models
//
// These models group local data by purpose so it is easier to understand.
// View-only @State values should stay in views and should not be stored here.

/// Personal setup for the user.
/// This is the data that answers "who is using the app?" and
/// "what is their current quit setup?"
struct ProfileData: Codable {
    var name: String = ""
    var quitDate: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? .now
    var dailySpend: Double = 8.5
    var quitReasons: [String] = []
    var birthday: Date?
    var age: Int?
    var gender: String?
}

/// Long-term journey data.
/// This is the history the user would expect the app to remember later.
struct ProgressData: Codable {
    var onboardingGoals: [String] = []
    var onboardingTriggers: [String] = []
    var cravingEvents: [CravingEvent] = []
    var slipEvents: [SlipEvent] = []
    var dailyCheckins: [DailyCheckin] = []
    var smokeFreeStreak: SmokeFreeStreak = SmokeFreeStreak()
}

/// Onboarding flow data.
/// This stores both progress inside onboarding and the answers gathered there.
struct OnboardingData: Codable {
    var hasCompletedOnboarding: Bool = false
    var state: OnboardingState = OnboardingState()
}

/// App preferences that should stay on device.
struct SettingsData: Codable {
    var themeMode: ThemeMode = .light
}

/// Useful short-term local state that improves UX if restored.
/// This is not view animation state. It is session-like user state.
struct SessionState: Codable {
    var completedTodayActionsByDate: [String: [String]] = [:]
}

enum OnboardingStep: Int, CaseIterable, Codable, Identifiable {
    case hook = 0
    case recognition = 1
    case system = 2
    case breakLoopHold = 3
    case costSlider = 5
    case future = 7
    case nameInput = 8
    case startPoint = 9
    case triggerQuestion = 10
    case profileQuestions = 11
    case loading = 12
    case planReady = 13
    case notificationPermission = 16
    case paywall = 14
    case exitOffer = 15

    var id: Int { rawValue }

    static let journeyOrder: [OnboardingStep] = [
        .hook,
        .recognition,
        .system,
        .breakLoopHold,
        .costSlider,
        .future,
        .nameInput,
        .startPoint,
        .triggerQuestion,
        .profileQuestions,
        .loading,
        .planReady,
        .notificationPermission,
        .paywall,
        .exitOffer
    ]

    static let progressOrder: [OnboardingStep] = [
        .hook,
        .recognition,
        .system,
        .breakLoopHold,
        .costSlider,
        .future,
        .nameInput,
        .startPoint,
        .triggerQuestion,
        .profileQuestions,
        .loading,
        .planReady,
        .notificationPermission,
        .paywall
    ]

    static var progressTotal: Int { progressOrder.count }

    var position: Int {
        if let index = Self.progressOrder.firstIndex(of: self) {
            return index + 1
        }
        return Self.progressTotal
    }
}

struct OnboardingState: Codable {
    var currentStep: OnboardingStep = .hook
    var name: String = ""
    var weeklySpending: Double = 35
    var recognitionResponse: String?
    var recognitionResponses: [String] = []
    var systemResponse: String?
    var breakLoopCommitment: String?
    var futureVision: String = ""
    var startPoint: String?
    var triggerQuestion: String?
    var profileQuestions: [String] = []
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
        if state.recognitionResponses.isEmpty, let recognitionResponse = state.recognitionResponse {
            state.recognitionResponses = [recognitionResponse]
        }
    }

    var currentStep: OnboardingStep {
        state.currentStep
    }

    func nextStep() {
        guard let index = OnboardingStep.journeyOrder.firstIndex(of: currentStep),
              index + 1 < OnboardingStep.journeyOrder.count else { return }
        let next = OnboardingStep.journeyOrder[index + 1]
        goToStep(next)
    }

    func previousStep() {
        guard let index = OnboardingStep.journeyOrder.firstIndex(of: currentStep),
              index > 0 else { return }
        let previous = OnboardingStep.journeyOrder[index - 1]
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
        case .firstDay: return "First full day"
        case .firstRescue: return "First urge outlasted"
        case .threeDays: return "3 steady days"
        case .saver50: return "EUR 50 kept"
        case .sevenDays: return "One steady week"
        case .tenRescues: return "10 urges outlasted"
        case .saver100: return "EUR 100 kept"
        case .fourteenDays: return "Two steady weeks"
        }
    }

    var subtitle: String {
        switch self {
        case .firstDay: return "One full day behind you."
        case .firstRescue: return "You stayed with the wave and got through it."
        case .threeDays: return "Your footing is getting steadier."
        case .saver50: return "That money stayed with you."
        case .sevenDays: return "A week of quiet progress."
        case .tenRescues: return "You are learning how to ride urges out."
        case .saver100: return "A meaningful amount stayed in your pocket."
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

    // AppState stays the shared object used by SwiftUI views.
    // The actual persistent local data now lives inside these grouped models.
    @Published var profile: ProfileData { didSet { persist() } }
    @Published var progress: ProgressData { didSet { persist() } }
    @Published var onboarding: OnboardingData { didSet { persist() } }
    @Published var sessionState: SessionState { didSet { persist() } }

    private var rewardToastTask: Task<Void, Never>?

    init() {
        let defaults = UserDefaults.standard
        self.profile = Self.load(ProfileData.self, for: .profileData) ?? ProfileData(
            name: defaults.string(forKey: StorageKey.profileName.rawValue) ?? "",
            quitDate: defaults.object(forKey: StorageKey.quitDate.rawValue) as? Date
                ?? Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1))
                ?? .now,
            dailySpend: defaults.object(forKey: StorageKey.dailySpend.rawValue) as? Double ?? 8.5,
            quitReasons: Self.load([String].self, for: .quitReasons) ?? [],
            birthday: nil,
            age: Self.legacyAge(from: Self.load(OnboardingState.self, for: .onboardingState)),
            gender: Self.legacyGender(from: Self.load(OnboardingState.self, for: .onboardingState))
        )
        self.progress = Self.load(ProgressData.self, for: .progressData) ?? ProgressData(
            onboardingGoals: Self.load([String].self, for: .onboardingGoals) ?? [],
            onboardingTriggers: Self.load([String].self, for: .onboardingTriggers) ?? [],
            cravingEvents: Self.load([CravingEvent].self, for: .cravingEvents) ?? [],
            slipEvents: Self.load([SlipEvent].self, for: .slipEvents) ?? [],
            dailyCheckins: Self.load([DailyCheckin].self, for: .dailyCheckins) ?? []
        )
        self.onboarding = Self.load(OnboardingData.self, for: .onboardingData) ?? OnboardingData(
            hasCompletedOnboarding: defaults.object(forKey: StorageKey.onboardingCompleted.rawValue) as? Bool ?? false,
            state: Self.load(OnboardingState.self, for: .onboardingState) ?? OnboardingState()
        )
        self.sessionState = Self.load(SessionState.self, for: .sessionState) ?? SessionState()
        refreshSmokeFreeStreakState()
    }

    var hasCompletedOnboarding: Bool {
        get { onboarding.hasCompletedOnboarding }
        set { onboarding.hasCompletedOnboarding = newValue }
    }

    // Compatibility accessors let the rest of the app keep using the same names.
    // That keeps this refactor small and safe.
    var profileName: String {
        get { profile.name }
        set { profile.name = newValue }
    }

    var onboardingGoals: [String] {
        get { progress.onboardingGoals }
        set { progress.onboardingGoals = newValue }
    }

    var onboardingTriggers: [String] {
        get { progress.onboardingTriggers }
        set { progress.onboardingTriggers = newValue }
    }

    var quitDate: Date {
        get { profile.quitDate }
        set { profile.quitDate = newValue }
    }

    var dailySpend: Double {
        get { profile.dailySpend }
        set { profile.dailySpend = newValue }
    }

    var cravingEvents: [CravingEvent] {
        get { progress.cravingEvents }
        set { progress.cravingEvents = newValue }
    }

    var slipEvents: [SlipEvent] {
        get { progress.slipEvents }
        set { progress.slipEvents = newValue }
    }

    var quitReasons: [String] {
        get { profile.quitReasons }
        set { profile.quitReasons = newValue }
    }

    var dailyCheckins: [DailyCheckin] {
        get { progress.dailyCheckins }
        set { progress.dailyCheckins = newValue }
    }

    var smokeFreeStreak: SmokeFreeStreak {
        get { progress.smokeFreeStreak }
        set { progress.smokeFreeStreak = newValue }
    }

    var birthday: Date? {
        get { profile.birthday }
        set {
            profile.birthday = newValue
            if let newValue {
                profile.age = Self.ageFromBirthday(newValue)
            }
        }
    }

    var age: Int? {
        get { effectiveAge }
        set {
            guard profile.birthday == nil else { return }
            profile.age = newValue
        }
    }

    var gender: String? {
        get { profile.gender }
        set { profile.gender = newValue }
    }

    var effectiveAge: Int? {
        if let birthday = profile.birthday {
            return Self.ageFromBirthday(birthday)
        }
        return profile.age
    }

    var hasBirthday: Bool {
        profile.birthday != nil
    }

    var ageBucketLabel: String? {
        guard let age = effectiveAge else { return nil }
        return Self.ageBucket(for: age)
    }

    func completedTodayActions(for date: Date = .now) -> Set<String> {
        let key = Self.sessionDayKey(for: date)
        return Set(sessionState.completedTodayActionsByDate[key] ?? [])
    }

    func isTodayActionCompleted(_ actionID: String, on date: Date = .now) -> Bool {
        completedTodayActions(for: date).contains(actionID)
    }

    func setTodayActionCompleted(_ actionID: String, isCompleted: Bool, on date: Date = .now) {
        let key = Self.sessionDayKey(for: date)
        var updated = completedTodayActions(for: date)

        if isCompleted {
            updated.insert(actionID)
        } else {
            updated.remove(actionID)
        }

        sessionState.completedTodayActionsByDate[key] = Array(updated).sorted()
        pruneOldCompletedTodayActions()
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

    var smokeFreeStreakState: SmokeFreeStreakState {
        evaluatedSmokeFreeStreak().streakState
    }

    var smokeFreeStreakCount: Int {
        evaluatedSmokeFreeStreak().streakCount
    }

    var didSmokeFreeCheckInToday: Bool {
        let today = Calendar.current.startOfDay(for: .now)
        guard let lastCheckIn = evaluatedSmokeFreeStreak().lastSmokeFreeCheckInDate else { return false }
        return Calendar.current.isDate(lastCheckIn, inSameDayAs: today)
    }

    var smokeFreeStreakStatusLine: String {
        switch smokeFreeStreakState {
        case .active:
            if didSmokeFreeCheckInToday {
                return "Streak active"
            }
            return smokeFreeStreakCount <= 1 ? "Streak active" : "\(smokeFreeStreakCount)-day streak active"
        case .onIce:
            return "Streak on ice"
        case .lost:
            return "Streak lost"
        }
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
        let defaults = ["Health", "Peace of mind", "Freedom", "More money for yourself"]
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
            return "Early days can feel uneven. Getting through today is enough."
        }
        if cravingsDefeated >= 10 {
            return "You have already gotten through many urges. That steadiness adds up."
        }
        if nicotineFreeDays >= 7 {
            return "A full week in. Your body is already settling into something new."
        }
        return "Each urge you outlast makes the next caring choice a little easier."
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
        mostCommonTrigger(in: cravingEvents)?.title ?? "Patterns are still forming"
    }

    var mostCommonTimeOfCravingTitle: String {
        let grouped = Dictionary(grouping: cravingEvents, by: \.timeOfDay)
        return grouped.max(by: { $0.value.count < $1.value.count })?.key.title ?? "Still getting to know your rhythm"
    }

    var averageCravingIntensityThisWeekText: String {
        averageIntensityText(for: weekEvents)
    }

    var weeklyCravingsSurvivedText: String {
        let count = weekEvents.filter(\.succeeded).count
        return count == 0 ? "Log a few moments to see this" : "\(count)"
    }

    var strongestTriggerThisWeekText: String {
        mostCommonTrigger(in: weekEvents)?.title ?? "Log a few moments to see this"
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
        self.onboarding.state = onboarding
        profileName = onboarding.name.trimmingCharacters(in: .whitespacesAndNewlines)
        onboardingGoals = onboarding.startPoint.map { [$0] } ?? onboarding.goal.map { [$0] } ?? []

        var triggers: [String] = []
        if let triggerQuestion = onboarding.triggerQuestion?.trimmingCharacters(in: .whitespacesAndNewlines), !triggerQuestion.isEmpty {
            triggers.append(triggerQuestion)
        }
        triggers.append(contentsOf: onboarding.profileQuestions)
        if triggers.isEmpty {
            triggers = onboarding.concerns
        }
        onboardingTriggers = triggers
        dailySpend = max(onboarding.weeklySpending / 7, 0)
        if profile.birthday == nil {
            profile.age = Self.legacyAge(from: onboarding)
        }
        gender = Self.legacyGender(from: onboarding)

        var reasons: [String] = []
        if let startPoint = onboarding.startPoint?.trimmingCharacters(in: .whitespacesAndNewlines), !startPoint.isEmpty {
            reasons.append(startPoint)
        }
        let futureVision = onboarding.futureVision.trimmingCharacters(in: .whitespacesAndNewlines)
        if !futureVision.isEmpty, !reasons.contains(futureVision) {
            reasons.append(futureVision)
        }
        let motivation = onboarding.motivation.trimmingCharacters(in: .whitespacesAndNewlines)
        if !motivation.isEmpty, !reasons.contains(motivation) {
            reasons.append(motivation)
        }
        if let commitment = onboarding.breakLoopCommitment?.trimmingCharacters(in: .whitespacesAndNewlines), !commitment.isEmpty, !reasons.contains(commitment) {
            reasons.append(commitment)
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

    func markSmokeFreeForToday(on date: Date = .now) {
        let day = Calendar.current.startOfDay(for: date)
        var streak = evaluatedSmokeFreeStreak(referenceDate: day)

        if let lastCheckIn = streak.lastSmokeFreeCheckInDate,
           Calendar.current.isDate(lastCheckIn, inSameDayAs: day) {
            setTodayActionCompleted("smoke_free_today", isCompleted: true, on: day)
            smokeFreeStreak = streak
            return
        }

        switch streak.streakState {
        case .active:
            if let lastCheckIn = streak.lastSmokeFreeCheckInDate {
                let lastDay = Calendar.current.startOfDay(for: lastCheckIn)
                let daysBetween = Calendar.current.dateComponents([.day], from: lastDay, to: day).day ?? 0
                streak.streakCount = daysBetween == 1 ? max(streak.streakCount + 1, 1) : 1
            } else {
                streak.streakCount = 1
            }
        case .onIce:
            streak.streakCount = max(streak.streakCount, 1)
        case .lost:
            streak.streakCount = 1
        }

        streak.streakState = .active
        streak.lastSmokeFreeCheckInDate = day
        streak.onIceEnteredAt = nil
        smokeFreeStreak = streak
        setTodayActionCompleted("smoke_free_today", isCompleted: true, on: day)
    }

    func resetProgress() {
        quitDate = Calendar.current.startOfDay(for: .now)
        cravingEvents = []
        slipEvents = []
        dailyCheckins = []
        smokeFreeStreak = SmokeFreeStreak()
        sessionState.completedTodayActionsByDate = [:]
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
        onboarding.state = OnboardingState()
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
        guard !events.isEmpty else { return "Log a few moments to see this" }
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
                "\(Int(current)) / 1 urge"
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
                "\(Int(current)) / 10 urges"
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
            progressText: unlocked ? "Reached" : valueFormatter(bounded),
            isUnlocked: unlocked
        )
    }

    private func persist() {
        let defaults = UserDefaults.standard
        save(profile, for: .profileData)
        save(progress, for: .progressData)
        save(onboarding, for: .onboardingData)
        save(sessionState, for: .sessionState)

        // Also keep the older keys up to date so existing installs can migrate safely.
        defaults.set(onboarding.hasCompletedOnboarding, forKey: StorageKey.onboardingCompleted.rawValue)
        defaults.set(profile.name, forKey: StorageKey.profileName.rawValue)
        save(progress.onboardingGoals, for: .onboardingGoals)
        save(progress.onboardingTriggers, for: .onboardingTriggers)
        defaults.set(profile.quitDate, forKey: StorageKey.quitDate.rawValue)
        defaults.set(profile.dailySpend, forKey: StorageKey.dailySpend.rawValue)
        save(progress.cravingEvents, for: .cravingEvents)
        save(progress.slipEvents, for: .slipEvents)
        save(profile.quitReasons, for: .quitReasons)
        save(progress.dailyCheckins, for: .dailyCheckins)
        save(onboarding.state, for: .onboardingState)
    }

    private func refreshSmokeFreeStreakState(referenceDate: Date = .now) {
        smokeFreeStreak = evaluatedSmokeFreeStreak(referenceDate: referenceDate)
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

    private func pruneOldCompletedTodayActions(keepingRecentDays daysToKeep: Int = 14) {
        let calendar = Calendar.current
        let earliestDate = calendar.date(
            byAdding: .day,
            value: -(daysToKeep - 1),
            to: calendar.startOfDay(for: .now)
        ) ?? .now

        sessionState.completedTodayActionsByDate = sessionState.completedTodayActionsByDate.filter { key, _ in
            guard let date = Self.sessionDayFormatter.date(from: key) else { return false }
            return date >= earliestDate
        }
    }

    private static func sessionDayKey(for date: Date) -> String {
        sessionDayFormatter.string(from: Calendar.current.startOfDay(for: date))
    }

    private func evaluatedSmokeFreeStreak(referenceDate: Date = .now) -> SmokeFreeStreak {
        var streak = smokeFreeStreak
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: referenceDate)

        guard let lastCheckIn = streak.lastSmokeFreeCheckInDate else {
            streak.streakCount = 0
            streak.streakState = .lost
            streak.onIceEnteredAt = nil
            return streak
        }

        let lastDay = calendar.startOfDay(for: lastCheckIn)
        let daysBetween = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        switch daysBetween {
        case ...0:
            streak.streakState = .active
            streak.onIceEnteredAt = nil
        case 1:
            streak.streakState = .active
            streak.onIceEnteredAt = nil
        case 2:
            streak.streakState = .onIce
            streak.onIceEnteredAt = streak.onIceEnteredAt ?? calendar.date(byAdding: .day, value: 1, to: lastDay)
        default:
            streak.streakState = .lost
            streak.streakCount = 0
            streak.onIceEnteredAt = nil
        }

        return streak
    }

    private static let sessionDayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()

    private static func legacyAge(from onboarding: OnboardingState?) -> Int? {
        guard let rawValue = legacyProfileQuestionValue(for: "age", in: onboarding) else {
            return nil
        }

        switch rawValue {
        case "Under 18":
            return 17
        case "18–25":
            return 22
        case "25+":
            return 30
        default:
            return Int(rawValue)
        }
    }

    private static func legacyGender(from onboarding: OnboardingState?) -> String? {
        legacyProfileQuestionValue(for: "gender", in: onboarding)
    }

    private static func legacyProfileQuestionValue(for key: String, in onboarding: OnboardingState?) -> String? {
        onboarding?.profileQuestions
            .first(where: { $0.hasPrefix("\(key):") })?
            .split(separator: ":", maxSplits: 1)
            .dropFirst()
            .first
            .map(String.init)
    }

    static func ageBucket(for age: Int) -> String {
        if age < 18 {
            return "Under 18"
        }
        if age <= 25 {
            return "18–25"
        }
        return "25+"
    }

    private static func ageFromBirthday(_ birthday: Date) -> Int {
        let components = Calendar.current.dateComponents([.year], from: birthday, to: .now)
        return max(components.year ?? 0, 0)
    }
}

private enum StorageKey: String {
    case profileData
    case progressData
    case onboardingData
    case settingsData
    case sessionState
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
