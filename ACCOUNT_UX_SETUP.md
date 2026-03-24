# Account UX Setup

## Which Account Screens Were Added

- A new account entry button on the Home screen.
- A custom account login/sign-up screen.
- A cleaner account info screen that can be opened from Settings or from the Home screen icon.

## Which Account Cards Were Removed

- The signed-out login screen no longer shows the bottom “What stays where” card.
- The signed-in account screen no longer shows the bottom “Local-first account note” card.

## Birthday And Age Logic

- `Birthday` is stored locally in `ProfileData`.
- `Age` is also stored locally in `ProfileData`, but birthday is now the more precise source of truth.
- When a birthday is set or changed, the app automatically derives the local age from it.
- The app shows age using the same grouped format used in onboarding: `Under 18`, `18–25`, or `25+`.
- If no birthday is set yet, age can still be edited as a local fallback.
- None of this profile data is stored in Firebase Auth.

## How The Flow Works

- If the user is signed out:
  - tapping the Home account icon opens the account login/sign-up screen
  - tapping the Account row in Settings also opens that same screen
- If the user is signed in:
  - tapping either entry point opens the account info screen

## Where Each Displayed Field Comes From

### From Firebase Auth

- Name: `AuthManager` from the current Firebase user when available
- Email: `AuthManager` from the current Firebase user
- Login way / provider: `AuthManager` from Firebase Auth provider data

### From Local App Data

- Birthday: stored locally in `ProfileData`
- Age: stored locally in `ProfileData`
- Gender: stored locally in `ProfileData`

These fields are now editable from the signed-in account details screen:

- Birthday
- Age
- Gender

## What Stays Local

These still stay on device in your local-first app data layer:

- progress data
- cravings and slips
- check-ins
- motivations
- onboarding answers
- settings
- birthday
- age
- gender

These values remain local and are not stored in Firebase Auth.

Signing in does not move your product progress into Firebase.

## What Comes From Firebase Auth

Firebase Auth is only used for identity details such as:

- whether the user is signed in
- display name
- email
- sign-in provider

## Settings Structure

- `Reset Options` moved out of the main Settings screen into its own detail screen.
- `App Information` also moved out of the main Settings screen into its own detail screen.
- The main Settings page now stays lighter and more scannable because those heavier sections are no longer expanded inline.

## What Is Still Placeholder

The login screen already shows:

- Continue with Google
- Continue with Apple
- Continue with Email

For now:

- Apple is fully wired to the existing Firebase Auth Apple sign-in flow
- Google is a visible placeholder for future integration
- Email is a visible placeholder for future integration
