import Foundation
import UserNotifications

@MainActor
final class LocalNotificationManager: ObservableObject {
    static let shared = LocalNotificationManager()

    private enum NotificationID {
        static let dailyCheckIn = "ayo.notifications.daily_check_in"
        static let onIceRecovery = "ayo.notifications.on_ice_recovery"
        static let trialReminder = "ayo.notifications.trial_reminder"
    }

    private enum StorageKey {
        static let notificationsEnabled = "notifications.enabled"
        static let dailyReminderEnabled = "notifications.dailyReminderEnabled"
        static let trialReminderDate = "notifications.trialReminderDate"
    }

    private enum NotificationCopy {
        static let dailyTitle = "Mark today as smoke-free"
        static let dailyBody = "Take a moment to check in and keep today moving your way."

        static let onIceTitle = "Your streak is on ice"
        static let onIceBody = "It is still recoverable. Mark today as smoke-free to keep it going."

        static let trialTitle = "Your free trial ends tomorrow"
        static let trialBody = "Take a moment to review your plan and keep your support in place."
    }

    @Published private(set) var notificationsEnabled: Bool
    @Published private(set) var dailyReminderEnabled: Bool
    @Published private(set) var authorizationStatus: UNAuthorizationStatus = .notDetermined

    private let center: UNUserNotificationCenter
    private let defaults: UserDefaults
    private var lastKnownSmokeFreeStreakState: SmokeFreeStreakState = .lost

    private init(
        center: UNUserNotificationCenter = .current(),
        defaults: UserDefaults = .standard
    ) {
        self.center = center
        self.defaults = defaults
        self.notificationsEnabled = defaults.object(forKey: StorageKey.notificationsEnabled) as? Bool ?? false
        self.dailyReminderEnabled = defaults.object(forKey: StorageKey.dailyReminderEnabled) as? Bool ?? true

        Task {
            await refreshAuthorizationStatus()
        }
    }

    func setNotificationsEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await requestAuthorizationIfNeeded()
            notificationsEnabled = granted
        } else {
            notificationsEnabled = false
        }

        defaults.set(notificationsEnabled, forKey: StorageKey.notificationsEnabled)
        await refreshSchedules()
    }

    func setDailyReminderEnabled(_ enabled: Bool) async {
        if enabled && !notificationsEnabled {
            await setNotificationsEnabled(true)
            guard notificationsEnabled else { return }
        }

        dailyReminderEnabled = enabled
        defaults.set(enabled, forKey: StorageKey.dailyReminderEnabled)
        await refreshSchedules()
    }

    func refreshSchedules(appState: AppState? = nil) async {
        if let appState {
            lastKnownSmokeFreeStreakState = appState.smokeFreeStreakState
        }

        await refreshAuthorizationStatus()

        guard notificationsEnabled, authorizationStatus == .authorized || authorizationStatus == .provisional else {
            cancelManagedNotifications()
            return
        }

        await syncDailyReminder()
        await syncOnIceReminder()
        await syncTrialReminder()
    }

    func setTrialReminder(endDate: Date?) async {
        if let endDate {
            defaults.set(endDate, forKey: StorageKey.trialReminderDate)
        } else {
            defaults.removeObject(forKey: StorageKey.trialReminderDate)
        }

        await refreshSchedules()
    }

    private func requestAuthorizationIfNeeded() async -> Bool {
        await refreshAuthorizationStatus()

        if authorizationStatus == .authorized || authorizationStatus == .provisional {
            return true
        }

        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            await refreshAuthorizationStatus()
            return granted
        } catch {
            return false
        }
    }

    private func refreshAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }

    private func syncDailyReminder() async {
        guard notificationsEnabled, dailyReminderEnabled else {
            center.removePendingNotificationRequests(withIdentifiers: [NotificationID.dailyCheckIn])
            return
        }

        var components = DateComponents()
        components.hour = 19
        components.minute = 0

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.dailyTitle
        content.body = NotificationCopy.dailyBody
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: NotificationID.dailyCheckIn,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        )
        try? await center.add(request)
    }

    private func syncOnIceReminder() async {
        guard notificationsEnabled, lastKnownSmokeFreeStreakState == .onIce else {
            center.removePendingNotificationRequests(withIdentifiers: [NotificationID.onIceRecovery])
            return
        }

        let now = Date()
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: now)
        let preferred = calendar.date(bySettingHour: 19, minute: 0, second: 0, of: today) ?? now
        let fireDate = max(preferred, calendar.date(byAdding: .minute, value: 45, to: now) ?? now)

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.onIceTitle
        content.body = NotificationCopy.onIceBody
        content.sound = .default

        let triggerDate = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: fireDate)
        let request = UNNotificationRequest(
            identifier: NotificationID.onIceRecovery,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        )
        try? await center.add(request)
    }

    private func syncTrialReminder() async {
        guard
            notificationsEnabled,
            let trialEndDate = defaults.object(forKey: StorageKey.trialReminderDate) as? Date
        else {
            center.removePendingNotificationRequests(withIdentifiers: [NotificationID.trialReminder])
            return
        }

        let reminderDate = max(
            Calendar.current.date(byAdding: .day, value: -1, to: trialEndDate) ?? trialEndDate,
            Date().addingTimeInterval(60 * 60)
        )

        guard reminderDate < trialEndDate else {
            center.removePendingNotificationRequests(withIdentifiers: [NotificationID.trialReminder])
            return
        }

        let content = UNMutableNotificationContent()
        content.title = NotificationCopy.trialTitle
        content.body = NotificationCopy.trialBody
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let request = UNNotificationRequest(
            identifier: NotificationID.trialReminder,
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        )
        try? await center.add(request)
    }

    private func cancelManagedNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [
            NotificationID.dailyCheckIn,
            NotificationID.onIceRecovery,
            NotificationID.trialReminder
        ])
    }
}
