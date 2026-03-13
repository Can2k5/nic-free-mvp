import Foundation

final class AppState: ObservableObject {
    @Published var quitDate: Date
    @Published var dailySpend: Double
    @Published var cravingsDefeated: Int

    init(
        quitDate: Date = Calendar.current.date(from: DateComponents(year: 2026, month: 3, day: 1)) ?? .now,
        dailySpend: Double = 8.5,
        cravingsDefeated: Int = 12
    ) {
        self.quitDate = quitDate
        self.dailySpend = dailySpend
        self.cravingsDefeated = cravingsDefeated
    }

    var nicotineFreeDays: Int {
        let start = Calendar.current.startOfDay(for: quitDate)
        let today = Calendar.current.startOfDay(for: .now)
        return max(Calendar.current.dateComponents([.day], from: start, to: today).day ?? 0, 0)
    }

    var moneySaved: Double {
        Double(nicotineFreeDays) * dailySpend
    }

    func recordCravingVictory() {
        cravingsDefeated += 1
    }
}
