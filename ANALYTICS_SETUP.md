# Analytics Setup

This app uses a very small, privacy-conscious PostHog setup.

The goal is simple:
- understand the onboarding funnel
- understand a few key product actions
- measure retention at a basic level

It is not meant to collect personal diary-style data.

## How PostHog is initialized

Initialization lives in:
- [Analytics.swift](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/app/NicFreeMVP/Analytics.swift)
- [NicFreeMVPApp.swift](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/app/NicFreeMVP/NicFreeMVPApp.swift)

The app reads these `Info.plist` keys:
- `POSTHOG_API_KEY`
- `POSTHOG_HOST`

If `POSTHOG_API_KEY` is empty or missing:
- analytics becomes a safe no-op
- the app still builds
- the app still runs normally

Default host:
- `https://us.i.posthog.com`

## Which automatic PostHog tracking is disabled

This setup intentionally disables PostHog's noisier automatic capture features:

- automatic screen view capture
- automatic application lifecycle events
- element autocapture
- session replay
- surveys
- feature flag request events

Why:
- we only want our own human-readable screen names
- we want to avoid generic events like `Screen` or `UIHostingController<...>`
- we want one small, understandable event stream
- we do not want duplicate or confusing analytics

Because of this, analytics in this app should come from our own manual custom events only.

## Which events are tracked

Current event list:
- `app_opened`
- `onboarding_started`
- `onboarding_step_viewed`
- `onboarding_completed`
- `home_viewed`
- `craving_rescue_started`
- `craving_rescue_completed`
- `paywall_viewed`
- `purchase_completed`

This app intentionally does **not** send separate PostHog `screen()` events.
That means:
- no extra `Screen` events
- no generic `UIHostingController<...>` names
- lower event volume
- one smaller, clearer event stream

## What must never be tracked in this app

Do not send:
- free-text motivation entries
- private journal text
- detailed health notes
- personal reflection text
- raw user-entered emotional or medical content

Do not add:
- session replay
- feature flags
- surveys
- broad automatic screen scraping
- noisy background event spam

This app is local-first, so personal progress stays on device.

## How anonymous tracking works

This first version does **not** call `identify()`.

That means:
- there is no login-based analytics identity yet
- PostHog uses its anonymous device/install identifier
- this is enough for early funnel metrics and retention trends

Later, if auth is added, identity can be introduced separately and carefully.

## How to add a new event safely

1. Add the event name to `AnalyticsEventName` in [Analytics.swift](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/app/NicFreeMVP/Analytics.swift).
2. Track it in one intentional place in the app.
3. Only send small, non-sensitive properties like:
   - onboarding step name
   - package id
   - trigger enum value
   - numeric intensity bucket
4. Avoid sending raw user text.
5. Prefer meaningful events over lots of tiny events.

## Why this supports funnel metrics and retention

This setup is enough to answer early product questions like:

- How many users open the app?
- How many start onboarding?
- Which onboarding steps are most viewed?
- Where do people drop before completion?
- How often is the paywall seen?
- How often does a purchase complete?
- Do people come back on later days?

For retention:
- `app_opened`
- `home_viewed`
- `craving_rescue_started`
- `craving_rescue_completed`

are enough to support basic D1 and D7 retention analysis without collecting sensitive personal content.
