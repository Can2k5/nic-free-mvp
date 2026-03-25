
---

## 4) `implementation_workflow.md`

```md
# Implementation Workflow

## Ziel
Diese Datei beschreibt den verbindlichen Arbeitsprozess zwischen:
- Planung
- Codex-Umsetzung
- Review
- manuellem Test
- Validierung
- Dokumentation

Ziel ist ein kontrollierter Build-Prozess ohne Chaos, Scope creep oder unklare Zustände.

---

## Grundprinzip

Es wird **nicht wahllos Ticket für Ticket** gearbeitet.

Stattdessen wird in **Umsetzungsblöcken** gearbeitet.

Jeder Block hat:
- klaren Scope,
- klaren Codex-Prompt,
- klare Validierung,
- klare Dokumentation.

---

## Gesamt-Reihenfolge

### Block 1 — Monetization Core
- Ticket 3
- Ticket 11
- Ticket 12

### Block 2 — Product Core Loop
- Ticket 5
- Ticket 19
- Ticket 20
- Ticket 26

### Block 3 — Retention & Onboarding Finish
- Ticket 21
- Ticket 23
- Ticket 24
- Ticket 25
- Ticket 22

### Block 4 — Stability, Cleanup, Auth
- Ticket 8
- Ticket 9
- Ticket 10
- Ticket 13
- Ticket 18

### Block 5 — Legal, Trust, Review Safety
- Ticket 14
- Ticket 15
- Ticket 16
- Ticket 17

### Block 6 — Store & Presentation
- Ticket 28
- Ticket 29
- Ticket 30
- Ticket 31
- Ticket 32
- Ticket 33

### Block 7 — QA, Launch, Post-Launch
- Ticket 34
- Ticket 35
- Ticket 36
- Ticket 37
- Ticket 38
- Ticket 39
- Ticket 40

---

## Standardprozess pro Block

### Schritt 1 — Block wählen
Es wird genau **ein Block** oder ein klar abgegrenzter Unterblock gewählt.

Nicht mehrere unverbundene Systeme gleichzeitig.

---

### Schritt 2 — Ziel präzisieren
Vor Codex muss klar sein:
- welches Ticket / welcher Unterblock umgesetzt wird
- welches Ergebnis erwartet wird
- welche Dateien / Bereiche wahrscheinlich betroffen sind
- was nicht kaputtgehen darf

---

### Schritt 3 — Prompt durch mich erstellen lassen
Ich schreibe den Prompt so, dass er enthält:
- Ziel
- Produktkontext
- Ticketbezug
- Constraints
- Definition of done
- Test-/QA-Hinweise

---

### Schritt 4 — Du gibst den Prompt an Codex
Codex arbeitet nur auf den aktuellen Scope.

Wichtige Regel:
- nicht nebenbei neue Features hinzufügen
- nicht mehrere lose Themen kombinieren
- nicht „wenn du schon dabei bist, mach auch noch ...“

---

### Schritt 5 — Du gibst mir die Codex-Rückgabe
Nach jedem Codex-Lauf sollst du mir möglichst immer diese Dinge geben:

1. **Codex-Zusammenfassung**
2. **Welche Dateien geändert wurden**
3. **Build-/Compiler-Status**
4. **Screenshots oder sichtbares Verhalten**
5. **Offene Warnungen / Unsicherheiten**

Ohne diese Dinge ist gute Validierung deutlich schwächer.

---

### Schritt 6 — Ich validiere gegen Ticket und Produktlogik
Ich prüfe:
- passt die Umsetzung zum Ticket?
- gibt es Seiteneffekte?
- wirkt die UX noch wie ayo?
- wurde der Scope sauber eingehalten?
- was muss noch nachgeschärft werden?

Ergebnis:
- validierbar
- korrigieren
- teilweise okay
- zurück in neue Schleife

---

### Schritt 7 — Du testest gezielt
Nicht „bisschen rumklicken“, sondern gezielt gegen:
- Ticket-Definition
- betroffene Flows
- relevante Geräte / Zustände

---

### Schritt 8 — Dokumentation aktualisieren
Nach jeder Schleife / jedem Block:

- `execution_log.md` aktualisieren
- `validation_checklist.md` aktualisieren
- `known_issues.md` ergänzen

Nichts nur „im Kopf behalten“.

---

## Statusmodell

Diese Status werden verwendet:

- **Planned** → noch nicht begonnen
- **In progress** → gerade in Umsetzung / Schleife
- **Implemented** → Codex hat umgesetzt, aber noch nicht vollständig validiert
- **Validated** → geprüft und akzeptiert
- **Deferred** → bewusst verschoben

---

## Go/No-Go-Regeln

### Kein Block gilt als abgeschlossen, wenn:
- der Build nicht sauber ist,
- der Kernflow nicht getestet wurde,
- das Ticket nur „halb so ungefähr“ getroffen wurde,
- Seiteneffekte noch unklar sind.

### Nach Release Candidate
Ab Ticket 37 / RC gilt zusätzlich:
- keine neuen Features mehr
- nur noch Blocker / High-severity / kleine Release-Fixes

---

## Praktische Arbeitsregel für uns

Der operative Prozess zwischen uns ist:

1. Wir wählen den nächsten Block
2. Ich schreibe den präzisen Codex-Prompt
3. Du gibst ihn an Codex
4. Du schickst mir Ergebnis + Dateien + Buildstatus + Screens
5. Ich validiere
6. Du testest
7. Wir dokumentieren
8. Dann nächster Block

---

## Erste empfohlene Umsetzung

### Start mit Block 1
- Ticket 3
- Ticket 11
- Ticket 12

Warum zuerst:
- monetärer Kern
- Premium-State als zentrale Wahrheit
- Purchase / Restore / Fehlerzustände
- Grundlage für Gating und spätere Produktvalidität

---

## Danach empfohlene Reihenfolge

### Zweiter Block
- Ticket 5
- Ticket 19
- Ticket 20
- Ticket 26

### Dritter Block
- Ticket 21
- Ticket 23
- Ticket 24
- Ticket 25
- Ticket 22

Erst danach Cleanup/Auth/Legal/Store/QA.

---

## Was bewusst vermieden wird

- kein chaotisches Springen zwischen Tickets
- kein Scope creep mitten im Block
- kein „erstmal alles implementieren, später schauen“
- keine fehlende Dokumentation
- keine Block-Abnahme ohne Validierung