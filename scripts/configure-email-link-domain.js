#!/usr/bin/env node

/**
 * This script updates Firebase Authentication project settings so mobile auth links
 * use the Firebase Hosting domain for this app.
 *
 * Why this matters:
 * iOS email-link sign-in works best when Firebase Auth knows which Hosting domain
 * should be used for mobile links. Without that project-level setting, the AASA file
 * can stay incomplete and iOS may open the website instead of the app.
 *
 * What this changes:
 * mobileLinksConfig.domain = "ayo-freenic.firebaseapp.com"
 *
 * Credentials:
 * Run this with a Firebase service account JSON file by setting:
 * GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json
 */

const admin = require("firebase-admin");

const PROJECT_ID = "ayo-freenic";
const HOSTING_DOMAIN = "HOSTING_DOMAIN";

async function main() {
  if (!process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    throw new Error(
      "Missing GOOGLE_APPLICATION_CREDENTIALS. Point it to your Firebase service account JSON file."
    );
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: PROJECT_ID
  });

  const projectConfigManager = admin.auth().projectConfigManager();

  console.log(`Updating Firebase Auth mobile links domain for project "${PROJECT_ID}"...`);

  await projectConfigManager.updateProjectConfig({
    mobileLinksConfig: {
      domain: HOSTING_DOMAIN
    }
  });

  const updatedConfig = await projectConfigManager.getProjectConfig();
  const appliedDomain = updatedConfig.mobileLinksConfig?.domain;

  console.log("Done.");
  console.log(`mobileLinksConfig.domain: ${appliedDomain ?? "(not set)"}`);

  if (appliedDomain !== HOSTING_DOMAIN) {
    throw new Error(
      `Expected domain "${HOSTING_DOMAIN}", but Firebase returned "${appliedDomain ?? "empty"}".`
    );
  }

  console.log("Firebase Authentication is now configured to use the Hosting domain for mobile auth links.");
}

main().catch((error) => {
  console.error("");
  console.error("Failed to configure Firebase Auth mobile links domain.");
  console.error(error.message);
  process.exitCode = 1;
});
