import Foundation
import OSLog
import RevenueCat

@MainActor
final class SubscriptionManager: NSObject, ObservableObject {
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

    static let proEntitlementID = "Ayo Pro"
    private static let logger = Logger(subsystem: "com.can.ayo", category: "Subscription")

    @Published private(set) var isProUser = false
    @Published private(set) var customerInfo: CustomerInfo?
    @Published private(set) var currentOffering: Offering?
    @Published private(set) var availablePackages: [Package] = []
    @Published private(set) var isLoadingOfferings = false
    @Published private(set) var isRefreshingCustomerInfo = false
    @Published private(set) var purchasingPackageID: String?
    @Published private(set) var isRestoringPurchases = false
    @Published var errorMessage: String?

    private var hasStarted = false

    var highlightedPackage: Package? {
        monthlyPackage ?? annualPackage ?? availablePackages.first
    }

    var monthlyPackage: Package? {
        availablePackages.first(where: { $0.packageType == .monthly })
    }

    var annualPackage: Package? {
        availablePackages.first(where: { $0.packageType == .annual })
    }

    func start() {
        guard !hasStarted else { return }
        hasStarted = true
        Purchases.shared.delegate = self
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
        isRefreshingCustomerInfo = true
        defer { isRefreshingCustomerInfo = false }

        do {
            Self.logger.debug("Refreshing customer info")
            let customerInfo = try await Purchases.shared.customerInfo()
            apply(customerInfo)
            Self.logger.debug("Customer info refresh success. isProUser=\(self.isProUser, privacy: .public)")
        } catch {
            Self.logger.error("Customer info refresh failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = readableMessage(for: error, fallback: "We couldn't refresh your subscription status right now.")
        }
    }

    func loadOfferings() async {
        isLoadingOfferings = true
        errorMessage = nil
        defer { isLoadingOfferings = false }

        do {
            Self.logger.debug("Offerings load started")
            let offerings = try await Purchases.shared.offerings()
            let offering = offerings.current

            currentOffering = offering
            availablePackages = orderedPackages(from: offering?.availablePackages ?? [])

            if offering == nil || availablePackages.isEmpty {
                Self.logger.error("Offerings load finished without packages")
                errorMessage = "We couldn't load subscription options right now. Please try again in a moment."
            } else {
                let packageIDs = availablePackages.map(\.storeProduct.productIdentifier).joined(separator: ", ")
                Self.logger.debug("Offerings load success. packages=\(packageIDs, privacy: .public)")
            }
        } catch {
            currentOffering = nil
            availablePackages = []
            Self.logger.error("Offerings load failed: \(error.localizedDescription, privacy: .public)")
            errorMessage = readableMessage(for: error, fallback: "We couldn't load subscription options right now. Please try again in a moment.")
        }
    }

    func purchase(_ package: Package) async -> PurchaseOutcome {
        purchasingPackageID = package.storeProduct.productIdentifier
        errorMessage = nil
        defer { purchasingPackageID = nil }

        do {
            Self.logger.debug("Purchase tapped for package \(package.storeProduct.productIdentifier, privacy: .public)")
            let (_, customerInfo, userCancelled) = try await Purchases.shared.purchase(package: package)
            guard !userCancelled else {
                let message = "The purchase was cancelled."
                errorMessage = message
                Self.logger.debug("Purchase cancelled for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .cancelled
            }

            apply(customerInfo)
            await refreshCustomerInfo()

            if isProUser {
                Self.logger.debug("Purchase success for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .success
            } else {
                let message = "Your purchase completed, but Ayo Pro is not active yet. Please try restoring purchases in a moment."
                errorMessage = message
                Self.logger.error("Purchase completed without active entitlement for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .failed(message)
            }
        } catch {
            let message = readableMessage(for: error, fallback: "The purchase didn't go through. Please try again.")
            errorMessage = message
            if message == "The purchase was cancelled." {
                Self.logger.debug("Purchase cancelled via error for package \(package.storeProduct.productIdentifier, privacy: .public)")
                return .cancelled
            } else {
                Self.logger.error("Purchase failed for package \(package.storeProduct.productIdentifier, privacy: .public): \(message, privacy: .public)")
                return .failed(message)
            }
        }
    }

    func restorePurchases() async -> RestoreOutcome {
        isRestoringPurchases = true
        errorMessage = nil
        defer { isRestoringPurchases = false }

        do {
            Self.logger.debug("Restore started")
            let customerInfo = try await Purchases.shared.restorePurchases()
            apply(customerInfo)
            await refreshCustomerInfo()

            if isProUser {
                Self.logger.debug("Restore success. Ayo Pro active")
                return .restored
            } else {
                let message = "No active Ayo Pro subscription was found to restore."
                errorMessage = message
                Self.logger.debug("Restore finished without active subscription")
                return .noActiveSubscription
            }
        } catch {
            let message = readableMessage(for: error, fallback: "We couldn't restore purchases right now. Please try again.")
            errorMessage = message
            Self.logger.error("Restore failed: \(message, privacy: .public)")
            return .failed(message)
        }
    }

    func clearError() {
        errorMessage = nil
    }

    private func apply(_ customerInfo: CustomerInfo?) {
        self.customerInfo = customerInfo
        isProUser = customerInfo?.entitlements.active[Self.proEntitlementID] != nil
    }

    private func orderedPackages(from packages: [Package]) -> [Package] {
        packages.sorted { lhs, rhs in
            rank(for: lhs) < rank(for: rhs)
        }
    }

    private func rank(for package: Package) -> Int {
        switch package.packageType {
        case .monthly:
            return 0
        case .annual:
            return 1
        default:
            return 2
        }
    }

    private func readableMessage(for error: Error, fallback: String) -> String {
        let nsError = error as NSError
        if nsError.domain == RevenueCat.ErrorCode.errorDomain,
           let code = ErrorCode(rawValue: nsError.code),
           code == .purchaseCancelledError {
            return "The purchase was cancelled."
        }

        return nsError.localizedDescription.isEmpty ? fallback : nsError.localizedDescription
    }
}

extension SubscriptionManager: PurchasesDelegate {
    nonisolated func purchases(_ purchases: Purchases, receivedUpdated customerInfo: CustomerInfo) {
        Task { @MainActor in
            apply(customerInfo)
            isRefreshingCustomerInfo = false
        }
    }
}
