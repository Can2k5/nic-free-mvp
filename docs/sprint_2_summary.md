# Sprint 2 Summary

## Goal
Strengthen ayo’s product core by implementing real premium gating, adding more contextual paywall timing, and reshaping Home into a clearer daily-loop screen.

## What was implemented
- Premium gating was implemented across core surfaces using centralized access-state helpers.
- A shared locked-state UI treatment was added so premium locks feel visually consistent and route to the same main paywall.
- Rescue was limited to one free use, then visually and behaviorally locked.
- Progress was split into free-visible basics and premium-locked deeper insight sections.
- Markers were split into visible overview content plus premium-locked deeper marker access.
- Dark Mode was gated as a premium feature.
- Locked-state visuals were strengthened with heavier blur / masking so premium content is less readable behind the lock layer.

- Contextual intent-based paywall triggers were added:
  - after first successful Rescue completion
  - when a free user scrolls deep enough into locked Progress content
  - when a free user interacts with locked Markers content, with cooldown protection

- Home was reworked so:
  - the graph-based hero remains the main visual anchor
  - the daily check-in action sits in the card directly below the hero
  - the check-in card clearly shows whether today is completed or not
  - the main check-in CTA is visually dominant
  - Rescue remains visible but secondary

## What was validated
- Free users now experience meaningful limitation instead of effectively receiving the full app.
- Premium users can access gated areas normally.
- Rescue behaves correctly:
  - one free use
  - locked afterward
- Progress and Markers locks behave correctly.
- Dark Mode behaves as a premium feature.
- Contextual paywall triggers work and feel substantially more intentional after the Progress timing fix.
- Home now has a clearer daily structure:
  - graph/status first
  - action second
  - support below

## What is still open
- Ticket 26 is still not implemented:
  - the actual streak system
  - on-ice state
  - lost state
  - streak recovery behavior
- RevenueCat still uses a Test Store API key, so monetization is not yet release-ready.
- Firebase startup warnings still need cleanup.

## Recommended next step
Continue Block 2 with Ticket 26 and implement the actual streak / on-ice logic so the daily loop is not only visible in UI hierarchy, but fully supported by product logic.