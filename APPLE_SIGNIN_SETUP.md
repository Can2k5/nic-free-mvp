# Apple Sign-In Setup

## What Was Added

- Firebase Auth is now used for Sign in with Apple.
- A small `AuthManager` listens to Firebase Auth and exposes a simple signed-in or signed-out state to SwiftUI.
- The native Apple sign-in button is shown in Settings inside an Account section.

## What Firebase Is Used For Here

Firebase is only used for identity.

- Apple returns a credential after the user approves sign-in.
- That Apple credential is turned into a Firebase Auth credential.
- Firebase Auth keeps track of whether this device currently has a signed-in user.

This setup does **not** move cravings, progress, check-ins, onboarding answers, or settings into Firebase.

## What Remains Local

Your app is still local-first.

These stay on the device in your existing local data layer:

- profile data
- progress data
- onboarding data
- settings
- session-like local state

Firebase Auth only answers: "who is signed in?"

## How To Test Apple Sign-In

1. Open the app on a simulator or physical device with Sign in with Apple support.
2. Go to the Settings tab.
3. Find the Account section.
4. Tap the Apple sign-in button.
5. Complete the Apple sheet.
6. After success, the Account section should show that the user is signed in.
7. Try the Sign out button and confirm the state changes back to signed out.

## Beginner Notes

- The nonce is a random one-time string used for security.
- The app sends a hashed version of that nonce to Apple.
- Firebase later checks the original nonce when creating the Firebase credential.
- This helps prove the Apple response matches the request your app started.
