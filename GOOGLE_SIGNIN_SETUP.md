# Google Sign-In Setup

## What was added

- The existing `Continue with Google` button now starts a real Google Sign-In flow.
- Google Sign-In now feeds into the same `AuthManager` that already handles Apple Sign-In.
- After Google returns an ID token and access token, the app creates a Firebase Auth credential and signs in through Firebase.
- The signed-in provider shown in the account UI now correctly displays `Google` when the user used Google Sign-In.

## What Firebase is used for here

Firebase Auth is only used for identity.

That means Firebase can remember:

- who is signed in
- the user display name
- the user email
- which sign-in provider was used

Firebase is **not** used for:

- quit progress
- cravings
- slips
- onboarding answers
- settings
- birthday
- age
- gender

Those still remain local in the app's own `AppState` and grouped local models.

## Xcode and Firebase setup assumptions

This implementation assumes these pieces are already in place:

- Google Sign-In is enabled in the Firebase console
- the refreshed `GoogleService-Info.plist` is already in the app target
- the iOS bundle identifier in Firebase matches this app
- the app uses the Google reversed client ID as a URL scheme

The URL scheme is required so Google can hand control back to the app after sign-in.

## How to test Google Sign-In

1. Build and run the app on a simulator or device.
2. Open the account screen while signed out.
3. Tap `Continue with Google`.
4. Complete the Google account chooser flow.
5. After sign-in finishes, the account screen should show the signed-in state.
6. The provider row should say `Google`.
7. Sign out and confirm the app returns to the signed-out account screen.

## What remains local

The app is still local-first.

These values stay on device and are not stored in Firebase Auth:

- cravings and craving history
- slip history
- onboarding answers
- quit date and money settings
- account profile fields like birthday, age, and gender
- app settings and session-like local state
