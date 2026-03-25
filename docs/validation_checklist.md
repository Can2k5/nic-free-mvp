
---

## 2) `validation_checklist.md`

```md
# Validation Checklist

## Zweck
Diese Datei prüft nach jeder Codex-Umsetzung, ob ein Ticket oder Block wirklich:
- zur Ticket-Entscheidung passt,
- funktioniert,
- getestet wurde,
- und damit als **Validated** gelten darf.

## Validierungsstatus
- Not started
- In progress
- Passed
- Failed
- Deferred

---

## Grundregel
Ein Ticket ist **nicht** schon dann fertig, wenn Codex Code geschrieben hat.

Ein Ticket gilt erst als validiert, wenn:
- die Implementierung gegen das Ticket geprüft wurde,
- der Build sauber läuft,
- die relevanten Flows getestet wurden,
- keine kritischen Seiteneffekte sichtbar sind.

---

## Vollständige Ticket-Validierung 1–40

### Ticket 1 – Monetarisierungsmodell final festlegen
**Status:** Passed  
**Hinweis:** Inhaltlich entschieden, keine direkte Code-Validierung nötig.

### Ticket 2 – Produktpositionierung in 1 Satz festlegen
**Status:** Passed  
**Hinweis:** Inhaltlich entschieden, später bei Store/Copy anwenden.

### Ticket 3 – RevenueCat auf Production-Setup umstellen
Status: Passed in dev/test, not release-ready

Validated:
- `REVENUECAT_API_KEY` is read from `Info.plist`
- RevenueCat config happens before monetization state usage
- offering `main` is loaded successfully
- packages resolve correctly to annual + monthly
- paywall renders real dynamic products
- annual is prioritized
- entitlement `ayo_premium` is aligned with RevenueCat dashboard

Still open before release:
- replace Test Store API key with real production key
- final production-side release validation
### Ticket 4 – Paywall komplett neu ausarbeiten
**Status:** Not started

### Ticket 5 – Premium-Gating sauber implementieren
**Status:** Passed

Validated:
- free vs premium access is now differentiated through centralized access-state helpers
- Rescue is free once, then fully locked
- Progress basic info remains visible while deeper sections are locked
- Markers overview remains visible while deeper marker content is locked
- Dark Mode is premium-gated
- locked interactions route directly to the main paywall
- premium users can access gated areas normally

Still open before release:
- final release validation in a production purchase environment

### Ticket 6 – Paywall-Platzierung final entscheiden
**Status:** Not started

### Ticket 7 – Monetization Analytics ergänzen
**Status:** Not started

### Ticket 8 – Placeholder- und Debug-Cleanup
**Status:** Passed

Validated:
- visible old branding was cleaned from user-facing surfaces
- visible placeholder / temporary auth residue was reduced
- unfinished visible email auth UI is no longer shown in release-facing surfaces
- the account/settings experience feels more intentional and less like an MVP/debug build

Decision:
- Passed

### Ticket 9 – Edge Cases für Kauf und Login testen
**Status:** Passed with limited manual validation caveat

Validated:
- RevenueCat offerings load now has a timeout/fallback guardrail
- auth cancel / failure / offline handling was hardened
- stale email-link auth state is cleared on sign-out
- the tested edge-case surfaces now feel less likely to strand the user

Still open:
- some offline / delayed-response scenarios could not be fully manually stress-tested in the current setup
- broader end-to-end edge-case validation still depends on later release QA

Decision:
- Passed for tested V1 scope

### Ticket 10 – Fehlerzustände UX-fähig machen
**Status:** Passed

Validated:
- visible auth error states now use calmer and less technical wording
- account sign-in errors are shown in a more intentional embedded surface
- visible error handling feels more product-ready and less like raw system/debug text
- paywall distinction between no-result, technical failure, and cancel/info remains intact

Decision:
- Passed

### Ticket 11 – RevenueCat- und State-Sync robuster machen
Status: Passed

Validated:
- central access state is `loading / free / premium`
- startup no longer crashes when RevenueCat config is missing
- loading deadlock was removed with timeout/fallback logic
- successful purchase updates access state to `premium`
- app returns to usable state after restart

### Ticket 12 – Paywall-/Purchase-Fehler und Retry-Flows konkretisieren
Status: Passed in dev/test

Validated:
- paywall fallback state is integrated and handlable
- `Try again` reacts
- `Restore purchases` reacts
- `Continue with limited access` is available
- purchase cancel is treated calmly
- purchase failure is treated calmly
- restore exits cleanly without trapping the user

Still open before release:
- final validation against non-Test-Store production configuration

### Ticket 13 – Auth-Flows für Release reduzieren und finalisieren
**Status:** Passed

Validated:
- visible auth methods for V1 are limited to Apple Sign-In and Google Sign-In
- email login is no longer exposed in user-facing V1 UI
- auth remains optional and non-blocking
- auth stays primarily in the Settings / Account area
- the existing Home auth entry remains small and calm

Decision:
- Passed

### Ticket 14 – Privacy Policy final erstellen und live stellen
**Status:** Not started

### Ticket 15 – Terms / Abo-relevante Rechtstexte finalisieren
**Status:** Not started

### Ticket 16 – Health-/Claims-/Store-Sprache absichern
**Status:** Not started

### Ticket 17 – Account-/Data-Transparency ergänzen
**Status:** Not started

### Ticket 18 – Apple- und Google-Login final reviewen
**Status:** Passed

Validated:
- Apple and Google login were reviewed as the two release-facing V1 auth flows
- Apple and Google now feel more equivalent on iOS
- Apple appears before Google on the signed-out auth surface
- technical signed-in account copy was cleaned up
- return-state handling after sign-in / sign-out / relaunch is cleaner because stale auth UI state is reset on real auth changes
- signed-in account action failures are now surfaced more clearly

Still open:
- deeper real-device / real-network auth stress cases remain part of later broader QA, not this ticket

Decision:
- Passed

### Ticket 19 – Daily Loop final definieren
**Status:** Passed in current implemented scope

Validated:
- the product now uses the daily smoke-free check-in as a visible daily action
- Rescue is treated as a secondary situational flow instead of the main daily loop
- contextual paywall triggers were added at high-intent moments:
  - post-Rescue completion
  - deeper Progress scroll
  - Markers interaction
- the Progress trigger was corrected so it no longer fires immediately on first screen open

Still open before release:
- deeper daily-loop reinforcement still depends on Ticket 26 and later retention/onboarding tickets

### Ticket 20 – Home auf 1 tägliche Hauptaktion zuspitzen
**Status:** Passed

Validated:
- Home uses the graph-based hero as the main visual anchor
- the daily check-in lives directly below the hero
- the check-in card now shows explicit daily status
- the primary CTA is visually strong and clearly actionable
- Rescue remains visible but secondary
- Home feels more guided and less like a set of equally weighted cards

Still open before release:
- further refinement is optional, but Ticket 20 is functionally and UX-wise strong enough to pass


### Ticket 21 – Lokale Notifications einbauen
**Status:** Passed with limited manual validation caveat

Validated:
- central local notification manager exists
- global notifications toggle works
- daily reminder toggle works
- daily reminder is logically subordinate to the global notifications toggle
- current settings flow works without visible runtime issues
- build blocker around notification manager target membership was fixed

Still open:
- manual validation of on-ice reminder
- manual validation of trial reminder

Decision:
- Passed for tested V1 scope

### Ticket 22 – Onboarding-Finish verbessern
**Status:** Passed

Validated:
- the final onboarding sequence now feels more coherent:
  - planReady
  - notificationPermission
  - paywall / access
  - finish / exitOffer
- a shared Final setup sequence indicator improves orientation across the finish flow
- wording and hierarchy were refined so the user better understands what this step is for and what comes next
- the step indicator readability issue was fixed
- Plan and Reminders were tightened into cleaner, more self-contained screens
- the Access step was improved and compacted without changing paywall logic
- build succeeded after the finish-flow and indicator polish passes

Still open before later design work:
- the Access step is still visually constrained by the current paywall structure and may benefit from a later dedicated paywall/access redesign

Decision:
- Passed

### Ticket 23 – Notification-Permission-Screen sinnvoll platzieren und gestalten
**Status:** Passed

Validated:
- a dedicated ayo notification pre-prompt exists
- the pre-prompt is placed after planReady and before the paywall/access step
- the primary action triggers the native iOS notification permission flow
- the secondary action continues onboarding calmly without blocking
- the onboarding flow continues normally in both cases
- manual test confirmed the screen feels calm and product-like rather than like a raw system permission request

Decision:
- Passed

### Ticket 24 – Trial-Reminder und Notification-Copy festlegen
**Status:** Passed

Validated:
- notification copy is centralized in the notification manager
- daily reminder copy is aligned to “Mark today as smoke-free”
- on-ice reminder uses “on ice” directly and frames the state as recoverable
- trial reminder copy is clear, calm, and fair rather than salesy
- build succeeded after the copy-only change

Decision:
- Passed

### Ticket 25 – Progress stärker an Check-ins koppeln
**Status:** Passed with limited manual validation caveat

Validated:
- Progress now contains a visible recent continuity module
- check-in continuity is visible near the top of the screen
- streak state is more clearly reflected in Progress
- continuity has more strategic weight than passive metrics alone
- free/premium structure remained coherent
- manual validation confirmed the new continuity element is visible and makes Progress feel more alive

Still open:
- manual validation of specific on-ice / lost visual states was not possible in the current time-based test setup

Decision:
- Passed for tested V1 scope

### Ticket 26 – Streak-System und On-Ice-Logik final definieren
**Status:** Passed with limited manual validation caveat

Validated:
- central streak model exists with `active / onIce / lost`
- Home and Progress read from the new streak state
- same-day repeat check-ins do not incorrectly increment the streak
- recovery / lost logic was implemented centrally in app state

Still open:
- full manual validation of time-based transitions (`on ice`, `lost`, recovery) was not possible in the current setup

Decision:
- Passed for tested V1 scope

### Ticket 27 – Goal-/Belohnungssystem als Future Direction sauber abgrenzen
**Status:** Passed  
**Hinweis:** Nur dokumentierte Future Direction, keine aktuelle Umsetzung.

### Ticket 28 – App-Store-Positionierung finalisieren
**Status:** Not started

### Ticket 29 – App Store Screenshots planen
**Status:** Not started

### Ticket 30 – App Store Listing Copy strukturieren
**Status:** Not started

### Ticket 31 – Preview-Video / App Preview Entscheidung treffen
**Status:** Passed  
**Hinweis:** Inhaltlich entschieden, keine unmittelbare Build-Validierung nötig.

### Ticket 32 – App Icon finalisieren
**Status:** Not started

### Ticket 33 – App Store Connect Setup final vorbereiten
**Status:** Not started

### Ticket 34 – Device QA Matrix abarbeiten
**Status:** Not started

### Ticket 35 – TestFlight Soft Launch / internen Test sauber aufsetzen
**Status:** Not started

### Ticket 36 – High-severity Bugs fixen / Release-Blocker-Regel finalisieren
**Status:** Not started

### Ticket 37 – Release Candidate Build finalisieren
**Status:** Not started

### Ticket 38 – Release Day Checklist / Submission-Ablauf festlegen
**Status:** Not started

### Ticket 39 – Post-Launch Monitoring / First 48 Hours definieren
**Status:** Not started

### Ticket 40 – V1 vs. V1.1 sauber abgrenzen / Immediate Next Iteration planen
**Status:** Passed  
**Hinweis:** Inhaltlich entschieden, operative Folge später.

---

## Blockorientierte Validierung

### Block 1 — Monetization Core
- [ ] Ticket 3 validiert
- [ ] Ticket 11 validiert
- [ ] Ticket 12 validiert

### Block 2 — Product Core Loop
- [x] Ticket 5 validiert
- [x] Ticket 19 validiert
- [x] Ticket 20 validiert
- [x] Ticket 26 validiert

### Block 3 — Retention & Onboarding Finish
- [x] Ticket 21 validiert
- [x] Ticket 23 validiert
- [x] Ticket 24 validiert
- [x] Ticket 25 validiert
- [x] Ticket 22 validiert

### Block 4 — Stability, Cleanup, Auth
- [x] Ticket 8 validiert
- [x] Ticket 9 validiert
- [x] Ticket 10 validiert
- [x] Ticket 13 validiert
- [x] Ticket 18 validiert

### Block 5 — Legal, Trust, Review Safety
- [ ] Ticket 14 validiert
- [ ] Ticket 15 validiert
- [ ] Ticket 16 validiert
- [ ] Ticket 17 validiert

### Block 6 — Store & Presentation
- [ ] Ticket 28 validiert
- [ ] Ticket 29 validiert
- [ ] Ticket 30 validiert
- [ ] Ticket 32 validiert
- [ ] Ticket 33 validiert

### Block 7 — QA, Launch, Post-Launch
- [ ] Ticket 34 validiert
- [ ] Ticket 35 validiert
- [ ] Ticket 36 validiert
- [ ] Ticket 37 validiert
- [ ] Ticket 38 validiert
- [ ] Ticket 39 validiert

---

## Validierungsvorlage pro Ticket

```md
### Ticket X – <Name>
**Status:** Not started / In progress / Passed / Failed / Deferred

**Definition of Done geprüft**
- [ ] Ja
- [ ] Nein

**Codex-Umsetzung geprüft**
- [ ] Ja
- [ ] Nein

**Build läuft**
- [ ] Ja
- [ ] Nein

**Manueller Test durchgeführt**
- [ ] Ja
- [ ] Nein

**Entspricht der Ticket-Entscheidung**
- [ ] Ja
- [ ] Nein

**Seiteneffekte geprüft**
- [ ] Ja
- [ ] Nein

**Offene Punkte**
- 

**Entscheidung**
- Passed / Failed / Deferred