
---

## 3) `known_issues.md`

```md
# Known Issues

## Zweck
Diese Datei sammelt alle bekannten Probleme, Unsauberkeiten, verschobenen Punkte und bewussten Nicht-Fixes, damit nichts verloren geht.

## Schweregrad
- Release blocker
- High priority
- Medium
- Low
- Future / V1.1

## Entscheidungsstatus
- fix now
- fix in current block
- defer to later block
- observe
- move to V1.1
- intentionally out of scope

---

## Startzustand
Aktuell sind noch keine konkreten Implementierungsprobleme eingetragen, weil die operative Umsetzung der Tickets noch nicht vollständig begonnen hat.

---

## Bereits bewusst nicht in V1

Diese Punkte sind **keine Bugs**, aber bewusst aus V1 ausgeschlossen:

### Future / V1.1 / Out of scope
- Goal-/Reward-System
- Assistant-/AI-Layer
- Relaunch-/Return-Upsell
- breite Mehrsprachigkeit / breite Regionenfreischaltung
- App Preview für V1
- komplexere Notification-Steuerung
- spätere ASO-Feinoptimierung
- tiefere Store-Experimente
- zusätzliche große UX-Systeme außerhalb des definierten V1-Kerns

---

## Typische Problemkategorien

### Monetization
- RevenueCat Setup
- Trial / Purchase / Restore
- Paywall Error States
- Free vs Premium Inkonsistenzen

### Daily Loop
- Check-in Logik
- Streak / On Ice
- Progress / Kontinuität
- Reminder-Verhalten

### UX / Trust
- Placeholder
- alte Namen
- kaputte Fehlermeldungen
- unfertige Flows
- widersprüchliche Premium-States

### Auth / Account
- Apple Login
- Google Login
- Restore-Verständnis
- Account-/Data-Transparency

### Store / Release
- Screenshots
- Listing
- App Store Connect
- Legal URLs
- Regionensetup

---

## Issue-Vorlage

```md
### Issue: <Kurztitel>
- **Severity:** Release blocker / High priority / Medium / Low / Future / V1.1
- **Area:** Monetization / Daily Loop / UX / Auth / Store / Release / Other
- **Found in:** Codex run / manual test / TestFlight / device QA / post-launch
- **Description:** 
- **Impact:** 
- **Related ticket(s):** 
- **Decision:** fix now / fix in current block / defer / observe / move to V1.1
- **Target:** current block / next block / pre-release / post-launch / V1.1
- **Notes:** 


--------------

## Open issues after Sprint 1

- RevenueCat is still using a Test Store API key. This must be replaced before release.
- Firebase still logs startup configuration warnings and needs cleanup in a later block.
- Premium/free gating across the app is still incomplete and belongs to Block 2, especially Ticket 5.
- Final release-grade monetization validation is still required once the production RevenueCat/App Store setup is in place.

## Open issues after Sprint 2

- RevenueCat is still using a Test Store API key. This must be replaced before release.
- Firebase still logs startup configuration warnings and needs cleanup in a later block.
- Ticket 26 is still open: the actual streak / on-ice system is not yet implemented, even though the daily loop and Home hierarchy were already strengthened.
- Final release-grade monetization validation is still required once the production RevenueCat / App Store setup is in place.

- Ticket 26 streak logic is implemented but not fully manually validated yet because date-based state transitions (`on ice`, `lost`, recovery) could not be tested in the current device/simulator setup.

## Open issues after Sprint 3

- RevenueCat is still using a Test Store API key. This must be replaced before release.
- Firebase still logs startup configuration warnings and needs cleanup in a later block.
- Ticket 21 notification foundation is implemented, but on-ice reminder and trial reminder could not be fully manually validated in the current setup.
- Ticket 25 progress continuity is implemented, but specific on-ice / lost state presentation could not be fully manually validated in the current setup.
- Ticket 26 streak logic is implemented, but full manual validation of date-based transitions (`on ice`, `lost`, recovery) was not possible in the current setup.
- The onboarding Access step is still visually constrained by the current paywall structure. A later dedicated paywall / access redesign pass may still be warranted.
- Final release-grade monetization validation is still required once the production RevenueCat / App Store setup is in place.

## Open issues after Sprint 4

- RevenueCat is still using a Test Store API key. This must be replaced before release.
- Firebase still logs startup configuration warnings and needs cleanup in a later block.
- Ticket 21 notification foundation is implemented, but on-ice reminder and trial reminder could not be fully manually validated in the current setup.
- Ticket 25 progress continuity is implemented, but specific on-ice / lost state presentation could not be fully manually validated in the current setup.
- Ticket 26 streak logic is implemented, but full manual validation of date-based transitions (`on ice`, `lost`, recovery) was not possible in the current setup.
- Some Block 4 offline / delayed-response edge cases were only partially manually validated in the current environment and should be covered again during later QA / TestFlight.
- The onboarding Access step is still visually constrained by the current paywall structure. A later dedicated paywall / access redesign pass may still be warranted.
- Final release-grade monetization validation is still required once the production RevenueCat / App Store setup is in place.