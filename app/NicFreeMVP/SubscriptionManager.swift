import Foundation
import OSLog
import RevenueCat

@MainActor
final class SubscriptionManager: NSObject, ObservableObject {
    enum AccessState: Equatable {
        case loading
        case free
        case premium
    }

    struct PaywallNotice: Equatable {
        enum Tone: Equatable {
            case info
            case error
        }

        let tone: Tone
        let message: String
        let allowsRetry: Bool
    }

    enum PurchaseOutcome {
        case success
        case cancelled
        case failed(String)
    }

    enum RestoreOutcome {
        case restored
        case noActiveSubscription
        case failed(String)
    }

    static let entitlementID = "ayo_premium"
    static let mainOfferingID = "main"
    static let annualPackageID = "annual"
    static let monthlyPackageID = "monthly"

    private static let logger = Logger(subsystem: "com.can.ayo", category: "Subscription")
    private static let accessStateStorageKey = "subscription.accessState"
    private static let customerInfoTimeoutNanoseconds: UInt64 = 8_000_000_000
    private static let offeringsTimeoutNanoseconds: UInt64 = 8_000_000_000

    @Published private(set) var accessState: AccessState = .loading
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var currentOffering: Offering?
    @Published private(set) var availablePackages: [Package] = []
    @Published private(set) var isLoadingOfferings = false
    @Published private(set) var isRefreshingCustomerInfo = false
    @Published private(set) var purchasingPackageID: String?
    @Published private(set) var isRestoringPurchases = false
    @Published private(set) var paywallNotice: PaywallNotice?

    private let analytics: AnalyticsService
    private let revenueCatIsConfigured: Bool
    private var hasStarted = false
    private let defaults: UserDefaults
    private var hasResolvedAccessState = false

    init(
        analytics: AnalyticsService,
        revenueCatIsConfigured: Bool,
        defaults: UserDefaults = .standard
    ) {
        self.analytics = analytics
        self.revenueCatIsConfigured = revenueCatIsConfigured
        self.defaults = defaults
        super.init()
        if let cachedState = Self.cachedAccessState(from: defaults) {
            accessState = cachedState
        }
    }

    var isPremium: Bool { accessState == .premium }
    var isFree: Bool { accessState == .free }
    var isProUser: Bool { isPremium }
    var isAccessLoading: Bool { accessState == .loading }

    var highlightedPackage: Package? {
        annualPackage ?? monthlyPackage ?? availablePackages.first
    }

    var monthlyPackage: Package? {
        availablePackages.first(where: { $0.identifier == Self.monthlyPackageID })
    }

    var annualPackage: Package? {
        availablePackages.first(where: { $0.identifier == Self.annualPackageID })
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        guard revenueCatIsConfigured else {
            accessState = .free
            hasResolvedAccessState = true
            Self.logger.error("RevenueCat is unavailable at startup because it was not configured")
            return
        }

        Purchases.shared.delegate = self
        accessState = .loading
        Self.logger.debug("Subscription manager started")

        Task {
            await refreshAll()
        }
    }

    func refreshAll() async {
        async let customerTask: Void = refreshCustomerInfo()
        async let offeringsTask: Void = loadOfferings()
        _ = await (customerTask, offeringsTask)
    }

    func refreshCustomerInfo() async {
        guard revenueCatIsConfigured else {
            if !hasResolvedAccessState {
                accessState = .free
                hasResolvedAccessState = true
            }
            return
        }

        isRefreshingCustomerInfo = true
        defer { isRefreshingCustomerInfo = false }

        if !hasResolvedAccessState {
            accessState = .loading
        }

        do {
            Self.logger.debug("Refreshing customer info")
            let customerInfo = try await customerInfoWithTimeout()
            apply(customerInfo)
            hasResolvedAccessState = true
            Self.logger.debug("Customer info refresh success. accessState=\(String(describing: self.accessState), privacy: .public)")
        } catch {
            Self.logger.error("Customer info refresh failed: \(error.localizedDescription, privacy: .public)")
            if !hasResolvedAccessState {
                if let cachedState = Self.cachedAccessState(from: defaults) {
                    accessState = cachedState
                } else {
                    accessState = .free
                }
                hasResolvedAccessState = true
            }
        }
    }

    func loadOfferings() async {
        guard revenueCatIsConfigured else {
            currentOffering = nil
            availablePackages = []
            Self.logger.error("Skipping offerings load because RevenueCat is not configured")
            paywallNotice = PaywallNotice(
                tone: .error,
                message: "Purchase options are not available right now.",
                allowsRetry: true
            )
            return
        }

        isLoadingOfferings = true
        paywallNotice = nil
        defer { isLoadingOfferings = false }

        do {
            Self.logger.debug("Offerings load started")
            let offerings = try await offeringsWithTimeout()
            let offering = offerings.offering(identifier: Self.mainOfferingID)

            let offeringIdentifiers = offerings.all.keys.sorted().joined(separator: ", ")
            Self.logger.debug("Fetched offerings. available_offerings=\(offeringIdentifiers, privacy: .public)")

            if offering == nil {
                Self.logger.error("Required offering '\(Self.mainOfferingID, privacy: .public)' was not found")
            }

            currentOffering = offering
            availablePackages = orderedPackages(from: requiredPackages(from: offering))

            if let offering {
                let availablePackageDetails = offering.availablePackages.map {
                    "\($0.identifier)|\(String(describing: $0.packageType))|\($0.storeProduct.productIdentifier)"
                }.joined(separator: ", ")
                Self.logger.debug("Offering '\(Self.mainOfferingID, privacy: .public)' packages=\(availablePackageDetails, privacy: .public)")
            }

            if offering == nil || availablePackages.count != 2 {
                let resolvedPackageDetails = availablePackages.map {
                    "\($0.identifier)|\(String(describing: $0.packageType))|\($0.storeProduct.productIdentifier)"
                }.joined(separator: ", ")
                Self.logger.error("Offerings load finished without the required annual/monthly packages. resolved_packages=\(resolvedPackageDetails, privacy: .public)")
                availablePackages = []
                paywallNotice = PaywallNotice(
                    tone: .error,
                    message: "We couldn't load purchase options right now.",
                    allowsRetry: true
                )
            } else {
                let packageIDs = availablePackages.map(\.storeProduct.productIdentifier).joined(separator: ", ")
                Self.logger.debug("Offerings load success. packages=\(packageIDs, privacy: .public)")
            }
        } catch {
            currentOffering = nil
            availablePackages = []
            Self.logger.error("Offerings load failed: \(error.localizedDescription, privacy: .public)")
            paywallNotice = PaywallNotice(
                tone: .error,
                message: "We couldn't load purchase options right now.",
                allowsRetry: true
            )
        }
    }

    func purchase(_ package: Package) async -> PurchaseOutcome {
        guard revenueCatIsConfigured else {
            let message = "Purchase options are not available right now."
            paywallNotice = PaywallNotice(tone: .error, message: message, allowsRetry: true)
            return .failed(message)
        }

        purchasingPackageID = package.storeProduct.productIdentifier
        paywallNotice = nil
        defer { purchasingPackageID = nil }

        do {
            Self.logger.debug("Purchase tapped for package \(package.storeProduct.productIdentifier, privacy: .public)")
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            guard !userCancelled else {
                let message = "Purchase cancelled."
                paywallNotice = PaywallNotice(tone: .info, message: message, allowsRetry: false)
                Self.logger.debug("Purchase cancelled for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .cancelled
            }

            accessState = .loading
            apply(customerInfo)
            await refreshCustomerInfo()

            if isProUser {
                await updateTrialReminder(for: package)
                Self.logger.debug("Purchase success for package \(package.storeProduct.productIdentifier, privacy: .public)")
                analytics.track(
                    .purchaseCompleted,
                    properties: [
                        "package_id": package.storeProduct.productIdentifier,
                        "source": "paywall"
                    ]
                )
                return .success
            } else {
                let message = "Your access is updating."
                paywallNotice = PaywallNotice(tone: .info, message: message, allowsRetry: false)
                Self.logger.error("Purchase completed without active entitlement for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .failed(message)
            }
        } catch {
            let message = readableMessage(for: error, fallback: "The purchase didn't go through. Please try again.")
            if message == "Purchase cancelled." {
                paywallNotice = PaywallNotice(tone: .info, message: message, allowsRetry: false)
                Self.logger.debug("Purchase cancelled via error for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .cancelled
            } else {
                paywallNotice = PaywallNotice(tone: .error, message: message, allowsRetry: true)
                Self.logger.error("Purchase failed for package \(package.storeProduct.productIdentifier, privacy: .public): \(message, privacy: .public)")
                return .failed(message)
            }
        }
    }

    func restorePurchases() async -> RestoreOutcome {
        guard revenueCatIsConfigured else {
            let message = "We couldn't restore purchases right now. Please try again."
            paywallNotice = PaywallNotice(tone: .error, message: message, allowsRetry: true)
            return .failed(message)
        }

        isRestoringPurchases = true
        paywallNotice = nil
        defer { isRestoringPurchases = false }

        do {
            Self.logger.debug("Restore started")
            let customerInfo = try await Purchases.shared.restorePurchases()
            accessState = .loading
            apply(customerInfo)
            await refreshCustomerInfo()

            if isProUser {
                Self.logger.debug("Restore success. Ayo Pro active")
                return .restored
            } else {
                let message = "No active purchase was found for this account."
                paywallNotice = PaywallNotice(tone: .info, message: message, allowsRetry: false)
                Self.logger.debug("Restore finished without active subscription")
                return .noActiveSubscription
            }
        } catch {
            let message = readableMessage(for: error, fallback: "We couldn't restore purchases right now. Please try again.")
            paywallNotice = PaywallNotice(tone: .error, message: message, allowsRetry: true)
            Self.logger.error("Restore failed: \(message, privacy: .public)")
            return .failed(message)
        }
    }

    func clearPaywallNotice() {
        paywallNotice = nil
    }

    private func apply(_ customerInfo: CustomerInfo?) {
        self.customerInfo = customerInfo
        let hasPremium = customerInfo?.entitlements.active[Self.entitlementID] != nil
        accessState = hasPremium ? .premium : .free
        defaults.set(accessState.cacheValue, forKey: Self.accessStateStorageKey)
    }

    private func orderedPackages(from packages: [Package]) -> [Package] {
        packages.sorted { lhs, rhs in
            rank(for: lhs) < rank(for: rhs)
        }
    }

    private func rank(for package: Package) -> Int {
        switch package.identifier {
        case Self.annualPackageID:
            return 0
        case Self.monthlyPackageID:
            return 1
        default:
            return 2
        }
    }

    private func requiredPackages(from offering: Offering?) -> [Package] {
        guard let offering else { return [] }

        return offering.availablePackages.filter {
            $0.packageType == .annual || $0.packageType == .monthly
        }
    }

    private func updateTrialReminder(for package: Package) async {
        guard
            package.packageType == .annual,
            let introductoryDiscount = package.storeProduct.introductoryDiscount,
            introductoryDiscount.price == 0,
            let trialEndDate = Calendar.current.date(
                byAdding: introductoryDiscount.subscriptionPeriod.dateComponents,
                to: .now
            )
        else {
            await LocalNotificationManager.shared.setTrialReminder(endDate: nil)
            return
        }

        await LocalNotificationManager.shared.setTrialReminder(endDate: trialEndDate)
    }

    private func readableMessage(for error: Error, fallback: String) -> String {
        let nsError = error as NSError
        if nsError.domain == RevenueCat.ErrorCode.errorDomain,
           let code = ErrorCode(rawValue: nsError.code),
           code == .purchaseCancelledError {
            return "Purchase cancelled."
        }

        return fallback
    }

    private func customerInfoWithTimeout() async throws -> CustomerInfo {
        try await withThrowingTaskGroup(of: CustomerInfo.self) { group in
            group.addTask {
                try await Purchases.shared.customerInfo()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: Self.customerInfoTimeoutNanoseconds)
                throw TimeoutError()
            }

            let customerInfo = try await group.next()!
            group.cancelAll()
            return customerInfo
        }
    }

    private func offeringsWithTimeout() async throws -> Offerings {
        try await withThrowingTaskGroup(of: Offerings.self) { group in
            group.addTask {
                try await Purchases.shared.offerings()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: Self.offeringsTimeoutNanoseconds)
                throw TimeoutError()
            }

            let offerings = try await group.next()!
            group.cancelAll()
            return offerings
        }
    }

    private static func cachedAccessState(from defaults: UserDefaults) -> AccessState? {
        guard let rawValue = defaults.string(forKey: accessStateStorageKey) else {
            return nil
        }

        switch rawValue {
        case "free":
            return .free
        case "premium":
            return .premium
        default:
            return nil
        }
    }
}

private struct TimeoutError: LocalizedError {
    var errorDescription: String? {
        "Timed out while refreshing customer info."
    }
}

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            apply(customerInfo)
            isRefreshingCustomerInfo = false
            hasResolvedAccessState = true
        }
    }
}

private extension SubscriptionManager.AccessState {
    var cacheValue: String {
        switch self {
        case .loading:
            return "loading"
        case .free:
            return "free"
        case .premium:
            return "premium"
        }
    }
}

private extension SubscriptionPeriod {
    var dateComponents: DateComponents {
        switch unit {
        case .day:
            return DateComponents(day: value)
        case .week:
            return DateComponents(day: value * 7)
        case .month:
            return DateComponents(month: value)
        case .year:
            return DateComponents(year: value)
        @unknown default:
            return DateComponents(day: value)
        }
    }
}
