# Hosting Setup

## What was added

- `.firebaserc`
- `firebase.json`
- `public/index.html`

These are the minimum files needed for a simple Firebase Hosting setup in this repo.

## Firebase project configuration

- Firebase project ID: `ayo-freenic`
- Hosting serves files from: `public/`

The repo now points Firebase Hosting at the `public` folder, which contains a small static support page for the `ayo` domain.

## Why this Hosting site exists

This Hosting site exists so the Firebase Hosting domain can be active and ready for the iOS email-link and universal-link flow.

In this setup:

- Firebase Hosting provides the public domain
- Firebase Auth uses that domain for email-link sign-in support
- the iPhone app handles the actual sign-in completion

Without a working Hosting site, the Firebase Hosting domain can show `Site Not Found`, which makes the email-link flow harder to trust and debug.

## How Hosting is expected to be initialized and deployed

If Firebase CLI is already installed and authenticated, the usual flow is:

```bash
firebase use ayo-freenic
firebase deploy --only hosting
```

Because `.firebaserc` already sets the default project, a simple deploy is often enough:

```bash
firebase deploy --only hosting
```

## What the static site does

The site is intentionally minimal:

- branded for `ayo`
- confirms that identity links are active
- explains that personal progress stays local on device

It is static only. There is no web app, no JavaScript framework, and no build system.

## Custom AASA file for iOS

The Hosting setup now also includes a custom Apple App Site Association file at:

- `/.well-known/apple-app-site-association`

This file is used by iOS Universal Links so Apple can map the Hosting domain to the app:

- `9LD3X3K9BX.com.can.ayomvp`

Firebase Hosting is configured to serve that file directly, without a `.json` extension, and with JSON content type. This matters for:

- iOS Universal Links
- Firebase email-link sign-in opening the app instead of only the website

## What remains local

This Hosting setup does **not** move personal app data to the web or Firebase Hosting.

These still remain local in the iPhone app:

- cravings and craving history
- slips
- onboarding answers
- quit progress
- settings
- birthday, age, and gender

Firebase Hosting and Firebase Auth are only supporting account identity and email-link delivery.
