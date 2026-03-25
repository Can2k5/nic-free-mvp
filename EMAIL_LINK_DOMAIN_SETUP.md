# Email Link Domain Setup

## What this script does

The script at [scripts/configure-email-link-domain.js](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/scripts/configure-email-link-domain.js) updates Firebase Authentication project settings so mobile auth links use:

- `ayo-freenic.firebaseapp.com`

Specifically, it sets:

- `mobileLinksConfig.domain = "ayo-freenic.firebaseapp.com"`

This is important for iOS email-link sign-in because Firebase Auth needs to know which Hosting domain should be used for mobile auth links. If this setting is missing, the Apple App Site Association response can stay incomplete and iOS may open the hosted website instead of the app.

## Files added

- [package.json](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/package.json)
- [scripts/configure-email-link-domain.js](/Users/user_can/Documents/DevLibrary/Projects/nic-free-mvp/scripts/configure-email-link-domain.js)

## What credentials are needed

You need a Firebase service account JSON file with permission to manage Firebase Authentication project config.

Before running the script, set:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
```

The script reads that file through the Firebase Admin SDK.

## How to run it

1. Install the dependency:

```bash
npm install
```

2. Set your service account path:

```bash
export GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/to/service-account.json"
```

3. Run the script:

```bash
npm run configure:email-link-domain
```

## How to verify success

The script prints the final value returned by Firebase:

- `mobileLinksConfig.domain: ayo-freenic.firebaseapp.com`

After that, give Firebase a little time to update.

Then verify:

1. Visit:
   - `https://ayo-freenic.firebaseapp.com/.well-known/apple-app-site-association`
2. Confirm the `applinks.details` section is no longer empty.
3. Tap a new email sign-in link on iPhone and confirm iOS opens the app instead of just the website.

## Why this is separate from the iOS app

This setting lives in Firebase Authentication project configuration, not in SwiftUI app code.

That means:

- your iOS app code can already be correct
- but Firebase still needs this project-level mobile links domain setting

## What remains local

This change does **not** move your app data into Firebase.

These still remain local on device:

- cravings and progress
- onboarding answers
- settings
- birthday, age, and gender

Firebase Auth here is still only being used for account identity and email-link sign-in.
