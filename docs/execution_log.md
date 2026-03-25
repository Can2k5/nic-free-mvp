# Ticket 40 – V1 vs. V1.1 sauber abgrenzen / Immediate Next Iteration planen

## Ergebnis

Für **ayo** wird eine klare Trennung zwischen **V1** und **V1.1** festgelegt, damit der erste Release fokussiert, hochwertig und monetär testbar bleibt.

V1 soll nur das enthalten, was den ersten echten Produktkern stark macht.  
Alles, was diesen Kern nicht direkt verbessert oder absichert, bleibt bewusst außerhalb des initialen Release-Scope.

## Strategische Entscheidung

Die erste Iteration nach Launch soll eine **Mischung aus Produkt-/Retention-Vertiefung und Store-/Growth-Optimierung** sein, mit klarem Schwerpunkt auf **Retention / Daily Loop zuerst**.

Das bedeutet:
- zuerst das Produkt stärker machen
- dann Wachstum / ASO / Store-Effizienz vertiefen
- kein wahlloser Ausbau nach dem Launch

## Klarer V1-Scope

V1 umfasst den bereits definierten Kern von ayo, insbesondere:

- Onboarding
- Plan-Processing / Plan-Ready-Finish
- Trial-/Reminder-Screen
- Main Paywall
- Free vs Premium Gating
- Daily smoke-free check-in
- Streak + on-ice-Logik
- Progress mit stärkerem Check-in-Bezug
- Rescue als Premium-Hebel
- lokale Notifications
- Auth in reduzierter V1-Form
- Legal / Store / Release-Grundlagen
- englischsprachiger Erstlaunch

## Was bewusst nicht in V1 gehört

Die folgenden Themen werden **bewusst nicht** Teil von V1:

- Goal-/Belohnungssystem
- Assistant-/AI-Layer
- Relaunch-/Return-Upsell
- tieferer Notification-Ausbau
- breiter Sprachen-/Regionen-Rollout
- App Preview
- große neue UX-Systeme
- alles, was den V1-Kern nicht direkt stärker oder releasefähiger macht

## Leitregel für V1

Für V1 gilt ausdrücklich:

- **Alles, was V1 nicht direkt stärker macht, bleibt draußen.**

Ziel:
- Scope sauber halten
- Release nicht aufblähen
- Produkt nicht mit zu vielen halbfertigen Zusatzideen verwässern

## V1.1-Schwerpunkt

Die erste sinnvolle Iteration nach Launch soll auf zwei Ebenen aufbauen:

### 1. Retention / Daily Loop vertiefen
Das ist der primäre Schwerpunkt.

### 2. Store / Growth / ASO optimieren
Das ist sekundär wichtig, aber erst nach einem stabilen Produktkern.

## Wichtigster V1.1-Kandidat

Das **Goal-/Reward-/Assistant-System** wird ausdrücklich als wahrscheinlich stärkster V1.1-Kandidat dokumentiert.

### Entscheidung
Dieses System ist die wichtigste bereits identifizierte Ausbau-Richtung nach V1.

Warum:
- es macht den Daily Loop persönlicher
- es verstärkt Check-ins, Streak und Motivation
- es kann das Produkt emotional und funktional vertiefen
- es schafft einen stärkeren persönlichen Anker als reine Zahlen

## Relaunch-/Return-Upsell

Ein Relaunch-/Return-Upsell wird ebenfalls ausdrücklich als möglicher **V1.1-Test** dokumentiert.

### Entscheidung
Dieses Element gehört nicht in V1, bleibt aber als naheliegende nächste Monetization-/Retention-Erweiterung festgehalten.

## Weitere sinnvolle V1.1-Bereiche

Zusätzliche mögliche Themen für V1.1 oder frühe Folgeiteration:

- tiefere Notification-Logik / feinere Reminder-Steuerung
- Store-/ASO-Optimierungen
- Subtitle-/Description-/Keyword-Feinschliff
- mögliche spätere App Preview
- spätere Regionen-/Sprachen-Erweiterung
- weitere Premium-Tiefe, sofern aus Launch-Learnings sinnvoll

## Reihenfolge nach Launch

Die produktstrategische Priorität nach Launch lautet:

1. reale Launch-Signale auswerten
2. Retention / Daily Loop stärken
3. Goal-/Reward-/Assistant-Richtung vorbereiten
4. Relaunch-/Return-Upsell testen
5. Store-/Growth-Optimierung vertiefen
6. weitere Regionen / Sprachen später erweitern

## Was bewusst vermieden wird

- kein Scope creep kurz vor oder direkt nach V1
- kein ungeplanter Ausbau aus „wir könnten auch noch...“
- keine Vermischung von aktuellem Release-Fokus und späteren Ideen
- keine verfrühte Umsetzung dokumentierter Future-Themen
- kein Wachstumsschub auf Kosten eines noch nicht stabilen Produktkerns

## Begründung

Diese Entscheidung wurde getroffen, weil ayo als Produkt jetzt einen klaren Kern hat, der im ersten Release sauber validiert werden soll:

- funktioniert der Daily Loop?
- funktioniert Monetization?
- funktioniert Gating?
- wirkt das Produkt vertrauenswürdig?
- trägt die App über Check-in, Streak und Progress?

Erst wenn diese Grundlagen real im Markt stehen, ist es sinnvoll, V1.1 gezielt und datenbasiert zu vertiefen.

## Definition of Done

Ticket 40 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass V1 und V1.1 klar getrennt werden
- dass V1 fokussiert und nicht überladen bleibt
- dass alles, was V1 nicht direkt stärker macht, draußen bleibt
- dass V1.1 als Mischung aus Retention- und Growth-Optimierung gedacht wird, mit Schwerpunkt Retention zuerst
- dass das Goal-/Reward-/Assistant-System als wichtigster V1.1-Kandidat dokumentiert ist
- dass ein Relaunch-/Return-Upsell als möglicher V1.1-Test festgehalten wird




------------------

## Sprint 1 / Block 1 – Monetization Core

- RevenueCat API key was moved from inline app code into `Info.plist` via `REVENUECAT_API_KEY`.
- App startup ordering was reworked in `NicFreeMVPApp.swift` so SDK setup happens before monetization state sync.
- `SubscriptionManager` was refactored into the central monetization state source with `loading / free / premium`.
- A guarded startup path was added so RevenueCat is never touched unless it has been configured.
- A bounded customer-info refresh timeout and fallback-to-free path were added to prevent global loading deadlocks.
- Inline paywall notice/error handling was introduced through `PaywallNotice` and shared `PaywallNoticeCard`.
- Both onboarding and in-app paywalls were aligned to use shared fallback/info/error behavior.
- A compile blocker was fixed by changing `PaywallNotice` from an invalid enum-with-stored-properties shape to a struct.
- A shared-component scope blocker was fixed by exposing `PaywallNoticeCard` for both paywall surfaces.
- A local CTA bug was fixed where `nil == nil` caused a fake perpetual `Starting...` state.
- RevenueCat offering resolution was corrected from strict raw identifier filtering to package-type-based annual/monthly resolution.
- RevenueCat dashboard was aligned to the code-side contract:
  - offering `main`
  - entitlement `ayo_premium`
  - packages `annual` and `monthly`
- Runtime validation confirmed:
  - products load successfully
  - annual and monthly render
  - purchase success resolves to `accessState=premium`
  - purchase cancel is handled calmly
  - purchase failure is handled calmly
  - restore returns to the app without trapping the user

------------------


## Sprint 2 / Block 2 – Product Core Loop

- Premium gating was implemented across the core app surfaces using `SubscriptionManager` as the access-state source of truth.
- Access helpers were added so free vs premium state can be derived centrally and reused consistently.
- A shared locked-state UI pattern was introduced to keep premium locks visually consistent and route blocked actions directly to the main paywall.
- Rescue was changed so free users can use Rescue once, after which Rescue visibly locks and tapping a locked Rescue option opens the main paywall.
- Progress was updated so basic information stays visible for free users while deeper insight sections are locked behind the shared premium lock treatment.
- Markers / Achievements were updated so overview content stays visible for free users while the full markers grid is locked behind premium.
- Dark Mode was gated so free users are redirected to the main paywall when trying to activate it.
- Lock visuals were strengthened with heavier masking / blur so hidden premium content is significantly less readable behind locked overlays.
- Rescue was visually corrected so, after the one free use is consumed, Rescue cards already look locked instead of appearing active until tapped.

- Intent-based paywall triggers were added to make upsell timing feel more contextual:
  - after first successful Rescue completion
  - when scrolling deep enough into locked Progress content
  - when interacting with locked Markers content, with cooldown protection

- The Progress trigger was corrected after an initial too-early implementation:
  - the auto-trigger was moved from the first locked section to a deeper locked section
  - this made the paywall appear only after real scroll intent

- Home was reworked to better support the daily loop:
  - the graph-based hero was restored as the main visual anchor
  - the daily check-in action was moved into the card directly below the hero
  - the check-in card gained an explicit daily status:
    - “Today / Not checked in yet”
    - “Today / ✓ Completed”
  - the check-in CTA was strengthened into a filled primary action button
  - the check-in card received subtle visual emphasis so it reads as the main daily action
  - Rescue remained visible but secondary within Home hierarchy

- Manual validation confirmed:
  - free vs premium behavior is now meaningfully differentiated
  - Rescue is free once, then locked
  - Progress deeper content locks correctly
  - Markers premium depth locks correctly
  - Dark Mode is premium-gated
  - premium users can access all gated areas normally
  - Rescue completion trigger feels acceptable
  - Progress auto-trigger was corrected so it no longer appears immediately on opening the screen
  - Home now reads more clearly as graph/status first, action second, support below

- Block 2 is functionally in place for:
  - Ticket 5
  - Ticket 19
  - Ticket 20

- Ticket 26 remains the major open item inside Block 2 and still needs the actual streak / on-ice logic to be finalized.

- Ticket 26 streak logic was implemented with `active / onIce / lost` and integrated into Home and Progress.
- Same-day check-ins were verified as idempotent.
- Full manual validation of date-based transitions is still pending because the current test setup did not allow practical date manipulation.
------------------

## Sprint 3 / Block 3 – Retention & Onboarding Finish

- A shared `LocalNotificationManager` was added as the central local notification service for V1 reminder behavior.
- Notification settings were introduced in Settings with:
  - global notifications on/off
  - daily reminder on/off
- A build blocker was fixed by adding `LocalNotificationManager.swift` to the AyoMVP target / Compile Sources.
- Manual validation confirmed the notification settings toggles and daily reminder flow work in the tested scope.
- On-ice reminder and trial reminder were implemented in the notification layer, but could not be fully manually validated in the current setup.

- A dedicated onboarding notification pre-prompt was inserted into the final onboarding flow.
- The onboarding finish sequence now runs as:
  - planReady
  - notificationPermission
  - paywall / access
  - exitOffer / finish
- The primary action on the pre-prompt triggers the native iOS notification permission flow.
- The secondary action (“Not now”) continues onboarding normally without blocking the user.

- Notification copy was finalized and centralized inside `LocalNotificationManager`.
- Final V1 copy now exists for:
  - daily reminder
  - on-ice reminder
  - trial reminder
- The daily reminder copy was aligned to the core product action:
  - “Mark today as smoke-free”
- The on-ice reminder now uses the term “on ice” directly and frames the state as recoverable.
- The trial reminder copy was made clearer and calmer rather than sales-driven.

- Progress was updated to feel more connected to actual daily smoke-free behavior.
- A new recent continuity element was added near the top of Progress.
- The continuity strip shows recent smoke-free check-in behavior over 7 days using the existing local data.
- The Progress screen now reflects streak state more clearly and gives continuity more weight than passive metrics alone.
- Money saved and KPI cards remain, but the screen now reads more like continuity first, metrics second.
- Manual validation confirmed the new continuity module is visible and improves the feel of Progress, but on-ice / lost display states could not be fully manually validated due to time-based test limitations.

- The onboarding finish flow was polished so the final setup sequence feels more coherent and connected.
- A shared “Final setup” sequence indicator was added across:
  - planReady
  - notificationPermission
  - paywall / access
  - exitOffer / finish
- Copy and hierarchy were refined so the user understands:
  - what this step is for
  - what comes next
  - how to continue without being trapped
- The final setup indicator was further polished so its labels no longer wrap awkwardly and the block feels calmer.
- The Plan, Reminders, and Access finish screens were tightened with reduced copy density and less vertical pressure.
- Plan and Reminders were specifically tightened toward a non-scrolling, self-contained presentation.
- Access was improved and compacted, but still remains partly constrained by the current paywall structure.

- Manual validation confirmed:
  - the notification permission pre-prompt is correctly placed after plan-ready and before paywall
  - continue / not-now behavior works
  - the finish flow feels more coherent than before
  - the final setup indicator is more readable
  - Plan and Reminders feel substantially cleaner
  - the Access step is improved, but the remaining visual limitation is mainly tied to the current paywall structure

- Block 3 is now functionally in place for:
  - Ticket 21
  - Ticket 23
  - Ticket 24
  - Ticket 25
  - Ticket 22

------------------

## Sprint 4 / Block 4 – Stability, Cleanup, Auth

- A visible cleanup pass was completed to remove release-facing MVP residue.
- User-facing old branding was cleaned where it still appeared in settings/app information.
- Visible placeholder residue was reduced by removing unfinished auth surfaces that were still shown as disabled or temporary.
- The account area was tightened so it feels more like an intentional release surface and less like an MVP/debug build.

- Edge-case hardening was added in the most important product risk areas.
- RevenueCat offerings loading now has a bounded timeout so slow or offline product fetches do not leave the paywall hanging indefinitely.
- Existing paywall fallback handling is now more reliable when offerings are delayed or unavailable.
- Auth failure/cancel/offline states were hardened so raw system-facing behavior does not leak through as easily.
- Pending email-link auth state is now cleared on sign-out so stale return state is less likely after account changes.

- Visible error states were refined to feel calmer and more product-ready.
- Auth-related errors now use calmer, shorter, non-technical language.
- The account sign-in flow now shows a more intentional embedded auth error surface instead of tiny raw-looking error text.
- Existing paywall distinction between:
  - no-result
  - technical failure
  - cancel/info
  was preserved as a good product behavior.

- Auth was reduced and finalized for V1 release-facing use.
- Visible login methods are now limited to:
  - Apple Sign-In
  - Google Sign-In
- Email login remains internal only and is no longer exposed in the visible V1 auth UI.
- Auth remains optional and does not block onboarding, paywall access, or free usage.
- Auth remains primarily placed in the Settings / Account area, with the existing small Home entry kept calm and non-dominant.

- Apple and Google login were reviewed as the final visible V1 auth flows.
- Apple and Google now feel more equivalent and release-ready on iOS.
- Apple was moved ahead of Google on the signed-out account surface to better match iOS expectations and review-readiness.
- Technical Firebase-oriented copy was removed from the signed-in account area.
- Signed-in account error handling was improved so sign-out/account-action failures are not silent.
- Auth state recovery now clears stale loading/provider/error state on real auth-state changes, improving re-entry after sign-in, sign-out, and relaunch.

- Manual validation confirmed:
  - visible cleanup feels better and less MVP-like
  - signed-out auth surface now feels optional and intentional
  - Apple and Google are the only visible auth methods
  - Apple appears before Google on iOS
  - restore-without-purchase now reads clearly and does not trap the user
  - the tested visible auth and paywall error surfaces behave calmly
  - sign-in / sign-out / relaunch behavior appears coherent in the tested scope

- Manual validation was limited in a few areas:
  - some offline/failure cases could not be fully forced in the current setup
  - some access-sync / offerings-delay paths were validated only indirectly in the current environment

- Block 4 is now functionally in place for:
  - Ticket 8
  - Ticket 9
  - Ticket 10
  - Ticket 13
  - Ticket 18

------------------



------------------
