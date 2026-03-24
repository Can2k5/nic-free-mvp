# Local Data Architecture

This app is local-first.

That means the user's personal quit journey stays on the device first, and the app is designed to work without needing a backend for core progress data.

## Grouped persistent structure

The app now groups local `UserDefaults` data into a few beginner-friendly models:

### `ProfileData`

What it is for:
- Personal setup data
- The user's current quit setup

What belongs here:
- `name`
- `quitDate`
- `dailySpend`
- `quitReasons`

### `ProgressData`

What it is for:
- Long-term progress and history

What belongs here:
- `onboardingGoals`
- `onboardingTriggers`
- `cravingEvents`
- `slipEvents`
- `dailyCheckins`

### `OnboardingData`

What it is for:
- Restoring onboarding if the user leaves and comes back
- Tracking whether onboarding is complete

What belongs here:
- `hasCompletedOnboarding`
- `state` (`OnboardingState`)

### `SettingsData`

What it is for:
- App preferences that should remain saved on device

What belongs here:
- `themeMode`

### `SessionState`

What it is for:
- Short-term local state that improves UX if restored
- Not full progress history, but still useful to remember

What belongs here:
- `completedTodayActionsByDate`

## What is persistent

The following data is persisted locally with `UserDefaults`:

- profile/setup data
- progress/history data
- onboarding progress
- theme/settings data
- completed "today focus" actions by date

The app also keeps writing the older `UserDefaults` keys during the transition so existing installs can migrate safely.

## What is temporary

These values should stay temporary and should not be persisted:

- SwiftUI animation flags
- sheet/modal visibility
- selected tabs
- in-progress visual transitions
- toast presentation state
- short-lived per-screen interaction state that only matters while a view is open

In SwiftUI, this usually means view-local `@State`.

## Why this app is local-first

This app is local-first because the most important data is personal journey data:

- quit date
- cravings
- slips
- check-ins
- reasons and motivations

That data should stay available even when the user is offline.

External services can be added later for things like:

- authentication
- analytics

But they do not need to be the source of truth for the user's personal progress.
