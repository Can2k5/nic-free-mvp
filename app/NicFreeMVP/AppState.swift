import Foundation

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

final class AppState: ObservableObject {
    @Published var activeRescueSessionID = UUID()

    @Published var onboardingCompleted: Bool { didSet { persist() } }
    @Published var onboardingGoals: [String] { didSet { persist() } }
    @Published var onboardingTriggers: [String] { didSet { persist() } }
    @Published var quitDate: Date { didSet { persist() } }
    @Published var dailySpend: Double { didSet { persist() } }
    @Published var cravingEvents: [CravingEvent] { didSet { persist() } }
    @Published var slipEvents: [SlipEvent] { didSet { persist() } }
    @Published var quitReasons: [String] { didSet { persist() } }
    @Published var dailyCheckins: [DailyCheckin] { didSet { persist() } }

    init() {
        let defaults = UserDefaults.standard
        self.onboardingCompleted = defaults.object(forKey: StorageKey.onboardingCompleted.rawValue) as? Bool ?? false
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

    private func persist() {
        let defaults = UserDefaults.standard
        defaults.set(onboardingCompleted, forKey: StorageKey.onboardingCompleted.rawValue)
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
    case onboardingGoals
    case onboardingTriggers
    case quitDate
    case dailySpend
    case cravingEvents
    case slipEvents
    case quitReasons
    case dailyCheckins
}
