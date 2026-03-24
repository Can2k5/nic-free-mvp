# Email Link Setup

## What was added

- The existing `Continue with Email` area in the account screen now supports real passwordless email link sign-in with Firebase Auth.
- Users can enter an email address inside the current custom account UI.
- The app sends a Firebase sign-in link using `ActionCodeSettings`.
- When the app is opened from that email link, `AuthManager` detects it and completes sign-in with Firebase Auth.
- The pending email address is saved locally in `UserDefaults` until sign-in finishes.

## How the flow works

1. The user opens the account screen while signed out.
2. The user taps `Continue with Email`.
3. The app shows an email field and a `Send sign-in link` button.
4. `AuthManager` sends a Firebase email link to that address.
5. The app saves that email address locally so it can finish sign-in later.
6. The user opens the email on iPhone and taps the sign-in link.
7. The app receives that incoming link.
8. `AuthManager` checks whether the URL is a Firebase email sign-in link.
9. If it is, Firebase Auth signs in with the saved email address and the incoming link.

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

## How to test it

### On iPhone

1. Run the app on a device.
2. Open the signed-out account screen.
3. Tap `Continue with Email`.
4. Enter an email address you can open on that same device.
5. Tap `Send sign-in link`.
6. Confirm the app shows the `Check your email` success state.
7. Open the email and tap the Firebase sign-in link.
8. The app should open and complete sign-in.
9. The account screen should show the signed-in state with provider `Email`.

### On simulator

You can still test sending the email link from the simulator.
To fully test completion, you need the incoming link to open the simulator app correctly.
Device testing is usually the most reliable for this flow.

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
