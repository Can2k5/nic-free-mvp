import AuthenticationServices
import CryptoKit
import FirebaseAuth
import FirebaseCore
import Foundation
import GoogleSignIn
import Security
import SwiftUI
import UIKit

/// A small, app-level view of authentication.
/// This only represents identity from Firebase Auth.
/// Personal progress, cravings, check-ins, and settings still stay local in AppState.
struct AuthUser: Equatable {
    let displayName: String?
    let email: String?
    let provider: AuthProviderType
}

enum AuthStatus: Equatable {
    case signedOut
    case signedIn(AuthUser)
}

enum AuthProviderType: Equatable {
    case apple
    case google
    case email
    case unknown

    var title: String {
        switch self {
        case .apple: return "Apple"
        case .google: return "Google"
        case .email: return "Email"
        case .unknown: return "Unknown"
        }
    }
}

@MainActor
final class AuthManager: ObservableObject {
    @Published private(set) var status: AuthStatus = .signedOut
    @Published private(set) var isLoading = false
    @Published var authErrorMessage: String?
    @Published private(set) var activeSignInProvider: AuthProviderType?
    @Published private(set) var emailLinkSentTo: String?

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var currentNonce: String?
    private let pendingEmailDefaultsKey = "auth.pendingEmailForSignIn"
    private var lastProcessedEmailLink: String?

    init() {
        status = Self.makeStatus(from: Auth.auth().currentUser)
    }

    deinit {
        if let authStateHandle {
            Auth.auth().removeStateDidChangeListener(authStateHandle)
        }
    }

    func start() {
        guard authStateHandle == nil else { return }

        restorePendingEmailState()

        // Firebase Auth remembers the signed-in user for us.
        // This listener keeps SwiftUI in sync when that auth state changes.
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            Task { @MainActor in
                self?.status = Self.makeStatus(from: user)
                self?.isLoading = false
                self?.activeSignInProvider = nil
                self?.authErrorMessage = nil
            }
        }
    }

    func prepareAppleSignInRequest(_ request: ASAuthorizationAppleIDRequest) {
        authErrorMessage = nil

        let nonce = Self.randomNonceString()
        currentNonce = nonce

        request.requestedScopes = [.fullName, .email]

        // The nonce is a one-time random value.
        // We send its SHA256 hash to Apple now, then Firebase checks the original value later.
        // This helps prevent a token from being replayed by someone else.
        request.nonce = Self.sha256(nonce)
    }

    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .failure(let error):
            activeSignInProvider = nil
            authErrorMessage = Self.message(for: error, provider: .apple)

        case .success(let authorization):
            guard let appleCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
                authErrorMessage = "We couldn't finish Apple Sign-In right now. Please try again."
                return
            }

            guard let nonce = currentNonce else {
                authErrorMessage = "We couldn't start Apple Sign-In right now. Please try again."
                return
            }

            guard let identityTokenData = appleCredential.identityToken,
                  let identityToken = String(data: identityTokenData, encoding: .utf8) else {
                authErrorMessage = "We couldn't finish Apple Sign-In right now. Please try again."
                return
            }

            isLoading = true
            activeSignInProvider = .apple

            // Apple gives us an identity token.
            // Firebase turns that Apple token into a Firebase credential so Auth can manage the session.
            let credential = OAuthProvider.appleCredential(
                withIDToken: identityToken,
                rawNonce: nonce,
                fullName: appleCredential.fullName
            )

            Auth.auth().signIn(with: credential) { [weak self] _, error in
                Task { @MainActor in
                    self?.isLoading = false
                    self?.currentNonce = nil
                    self?.activeSignInProvider = nil

                    if let error {
                        self?.authErrorMessage = Self.message(for: error, provider: .apple)
                    } else {
                        self?.authErrorMessage = nil
                    }
                }
            }
        }
    }

    func signInWithGoogle() async {
        authErrorMessage = nil
        emailLinkSentTo = nil

        guard let clientID = FirebaseApp.app()?.options.clientID, !clientID.isEmpty else {
            authErrorMessage = "Google Sign-In isn't available right now. Please try again later."
            return
        }

        guard let presentingViewController = Self.topViewController() else {
            authErrorMessage = "We couldn't open Google Sign-In right now. Please try again."
            return
        }

        isLoading = true
        activeSignInProvider = .google

        do {
            let configuration = GIDConfiguration(clientID: clientID)
            GIDSignIn.sharedInstance.configuration = configuration

            // Google returns an ID token and access token.
            // FirebaseAuth uses those tokens to create a Firebase credential,
            // which lets the app keep one shared auth system for Apple and Google.
            let signInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController)

            guard let idToken = signInResult.user.idToken?.tokenString else {
                throw AuthFlowError.missingGoogleIDToken
            }

            let accessToken = signInResult.user.accessToken.tokenString
            let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)

            _ = try await Auth.auth().signIn(with: credential)
            authErrorMessage = nil
        } catch {
            authErrorMessage = Self.message(for: error, provider: .google)
        }

        isLoading = false
        activeSignInProvider = nil
    }

    func sendEmailSignInLink(to email: String) async {
        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        authErrorMessage = nil

        guard !trimmedEmail.isEmpty else {
            authErrorMessage = "Enter your email address first."
            return
        }

        guard trimmedEmail.contains("@"), trimmedEmail.contains(".") else {
            authErrorMessage = "Enter a valid email address."
            return
        }

        guard let bundleID = Bundle.main.bundleIdentifier, !bundleID.isEmpty else {
            authErrorMessage = "Email sign-in isn't available right now. Please try again later."
            return
        }

        isLoading = true
        activeSignInProvider = .email
        emailLinkSentTo = nil

        // Firebase sends a passwordless sign-in email.
        // The link comes back to this app, and then Firebase Auth completes the sign-in locally from that link.
        let settings = ActionCodeSettings()
        settings.url = URL(string: "https://ayo-freenic.firebaseapp.com")
        settings.handleCodeInApp = true
        settings.setIOSBundleID(bundleID)

        do {
            try await Auth.auth().sendSignInLink(toEmail: trimmedEmail, actionCodeSettings: settings)
            UserDefaults.standard.set(trimmedEmail, forKey: pendingEmailDefaultsKey)
            emailLinkSentTo = trimmedEmail
            authErrorMessage = nil
        } catch {
            authErrorMessage = Self.message(for: error, provider: .email)
        }

        isLoading = false
        activeSignInProvider = nil
    }

    func handleIncomingEmailLink(_ url: URL) async {
        let link = url.absoluteString

        guard lastProcessedEmailLink != link else {
            return
        }

        guard Auth.auth().isSignIn(withEmailLink: link) else {
            return
        }

        guard let pendingEmail = pendingEmail else {
            authErrorMessage = "Open the sign-in link on the same device where you requested it."
            return
        }

        isLoading = true
        activeSignInProvider = .email
        lastProcessedEmailLink = link

        do {
            // Firebase checks that the stored email and incoming email link belong together,
            // then turns that into a signed-in Firebase Auth session.
            _ = try await Auth.auth().signIn(withEmail: pendingEmail, link: link)
            clearPendingEmail()
            authErrorMessage = nil
        } catch {
            lastProcessedEmailLink = nil
            authErrorMessage = Self.message(for: error, provider: .email)
        }

        isLoading = false
        activeSignInProvider = nil
    }

    func signOut() {
        do {
            GIDSignIn.sharedInstance.signOut()
            try Auth.auth().signOut()
            clearPendingEmail()
            authErrorMessage = nil
        } catch {
            authErrorMessage = Self.message(for: error, provider: nil)
        }
    }

    var signedInUser: AuthUser? {
        if case .signedIn(let user) = status {
            return user
        }
        return nil
    }

    var pendingEmail: String? {
        UserDefaults.standard.string(forKey: pendingEmailDefaultsKey)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
    }

    private static func makeStatus(from user: User?) -> AuthStatus {
        guard let user else { return .signedOut }

        let provider = user.providerData
            .map(\.providerID)
            .compactMap(Self.authProvider(from:))
            .first ?? .unknown

        return .signedIn(
            AuthUser(
                displayName: user.displayName,
                email: user.email,
                provider: provider
            )
        )
    }

    private static func authProvider(from providerID: String) -> AuthProviderType? {
        switch providerID {
        case "apple.com":
            return .apple
        case "google.com":
            return .google
        case "password":
            return .email
        case "firebase":
            return nil
        default:
            return .unknown
        }
    }

    private static func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        return hashedData.map { String(format: "%02x", $0) }.joined()
    }

    private static func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while remainingLength > 0 {
            let randoms: [UInt8] = (0..<16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate a secure nonce. OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }

                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }

        return result
    }

    @MainActor
    private static func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let resolvedBase = base ?? UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
        if let navigationController = resolvedBase as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }

        if let tabBarController = resolvedBase as? UITabBarController,
           let selectedViewController = tabBarController.selectedViewController {
            return topViewController(base: selectedViewController)
        }

        if let presentedViewController = resolvedBase?.presentedViewController {
            return topViewController(base: presentedViewController)
        }

        return resolvedBase
    }

    private static func message(for error: Error, provider: AuthProviderType?) -> String {
        if let gidError = error as? GIDSignInError, gidError.code == .canceled {
            return "Google Sign-In was canceled."
        }

        if let authError = error as? ASAuthorizationError, authError.code == .canceled {
            return "Apple Sign-In was canceled."
        }

        let nsError = error as NSError
        if nsError.domain == NSURLErrorDomain {
            switch nsError.code {
            case NSURLErrorNotConnectedToInternet,
                 NSURLErrorNetworkConnectionLost,
                 NSURLErrorTimedOut,
                 NSURLErrorInternationalRoamingOff,
                 NSURLErrorDataNotAllowed,
                 NSURLErrorCannotFindHost,
                 NSURLErrorCannotConnectToHost,
                 NSURLErrorDNSLookupFailed:
                switch provider {
                case .google:
                    return "Google Sign-In needs a connection right now. Please try again."
                case .apple:
                    return "Apple Sign-In needs a connection right now. Please try again."
                case .email:
                    return "We couldn't send the sign-in email right now. Please check your connection and try again."
                default:
                    return "Please check your connection and try again."
                }
            default:
                break
            }
        }

        switch provider {
        case .google:
            return "We couldn't sign you in with Google right now. Please try again."
        case .apple:
            return "We couldn't sign you in with Apple right now. Please try again."
        case .email:
            return "We couldn't complete email sign-in right now. Please try again."
        default:
            return "We couldn't complete that action right now. Please try again."
        }
    }

    private func restorePendingEmailState() {
        emailLinkSentTo = pendingEmail
    }

    private func clearPendingEmail() {
        UserDefaults.standard.removeObject(forKey: pendingEmailDefaultsKey)
        emailLinkSentTo = nil
    }
}

private enum AuthFlowError: LocalizedError {
    case missingGoogleIDToken

    var errorDescription: String? {
        switch self {
        case .missingGoogleIDToken:
            return "Google Sign-In did not return an identity token."
        }
    }
}
