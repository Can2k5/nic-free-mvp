# Email Link Setup

## What was added

- The app includes an underlying passwordless email link sign-in implementation with Firebase Auth.
- The app can send a Firebase sign-in link using `ActionCodeSettings`.
- When the app is opened from that email link, `AuthManager` detects it and completes sign-in with Firebase Auth.
- The pending email address is saved locally in `UserDefaults` until sign-in finishes.
- For the first release, Email remains intentionally hidden behind a polished `Coming soon` state in the account screen.

## How the flow works

1. The app prepares an email address for passwordless sign-in.
2. `AuthManager` sends a Firebase email link to that address.
3. The app saves that email address locally so it can finish sign-in later.
4. The user opens the email on iPhone and taps the sign-in link.
5. The app receives that incoming link.
6. `AuthManager` checks whether the URL is a Firebase email sign-in link.
7. If it is, Firebase Auth signs in with the saved email address and the incoming link.

## Firebase assumptions

This setup assumes:

- Firebase Auth has both `Email/Password` and `Email Link` enabled
- the Firebase project is `ayo-freenic`
- the Hosting/Auth domain is `ayo-freenic.firebaseapp.com`
- the app has Associated Domains configured for:
  - `applinks:ayo-freenic.firebaseapp.com`
- the app bundle identifier matches the Firebase iOS app

## ActionCodeSettings used here

- `url = https://ayo-freenic.firebaseapp.com`
- `handleCodeInApp = true`
- iOS bundle ID comes from `Bundle.main.bundleIdentifier`

## Release note

For launch, the account screen keeps Email in a clear `Coming soon` state.
The underlying implementation stays in progress in the codebase, but it is intentionally not exposed in the visible release UI yet.

## What remains local

Firebase Auth is still only used for identity.

These remain local on device:

- cravings and craving history
- slip history
- onboarding answers
- quit progress and progress models
- settings
- birthday
- age
- gender

Only identity-related sign-in state is handled by Firebase Auth.
