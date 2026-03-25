# Ticket 1 – Monetarisierungsmodell final festlegen

## Ergebnis

Für **ayo** wird als finales Monetarisierungsmodell festgelegt:

- **Modell:** Free + Premium + Free Trial
- **Trial-Länge:** 7 Tage
- **Abo-Optionen:** Monthly + Annual
- **Annual:** wird als Hauptoption priorisiert
- **Lifetime:** wird zum Start nicht angeboten

## Strategische Entscheidung

ayo soll als **Premium-Produkt** wahrgenommen werden.  
Die kostenlose Version dient nur dazu, den Wert der App kurz erfahrbar zu machen, nicht dazu, die volle App dauerhaft gratis nutzbar zu machen.

Ziel ist:
- Premium klar begehrenswert machen
- Conversion früh im Funnel fördern
- trotzdem keinen kompletten Hard-Wall-Effekt erzeugen

## Paywall-Logik

- Die Paywall bleibt **direkt nach dem Onboarding**
- Es wird eine **3-Step-Paywall-Sequenz** angestrebt:
  1. emotionaler Übergang
  2. Trial-/Reminder-Kommunikation
  3. eigentliche Paywall

## Free Version

Die Free-Version wird bewusst **stark reduziert** gehalten.

Enthalten:
- komplettes Onboarding
- Home in reduzierter Form
- 1 Rescue Tool
- Basis-Metriken:
  - nicotine-free days
  - money saved
- minimale Vorschau auf Marker / Achievements
- Settings / Login / Basiszugang

## Premium Version

Premium ist die eigentliche Vollversion von ayo.

Enthalten:
- komplette Rescue Library
- volle Daily Guidance
- kompletter Progress-Bereich
- tiefere Insights / History / Muster
- komplette Marker & Achievements
- erweiterte Reflection- / Recovery-Flows
- zusätzliche personalisierte Unterstützung

## Upsell-Logik

Kontextuelle Upsells sollen an relevanten Premium-Momenten erscheinen, z. B.:
- beim Öffnen weiterer Rescue Tools
- beim Öffnen tieferer Progress-Insights
- beim Zugriff auf vollständige Marker / Achievements
- bei Premium-Daily-Guidance

## Begründung

Dieses Modell wurde gewählt, weil:
- ayo kein Einmal-Tool, sondern ein wiederkehrendes Support-Produkt ist
- Subscription besser zur Nutzung über Zeit passt
- Trial den Einstieg erleichtert
- ein zu großzügiger Free-Tier Premium entwerten würde
- ein komplett harter Paywall-Ansatz Vertrauen und Conversion unnötig riskant machen könnte

## Definition of Done

Ticket 1 gilt als inhaltlich entschieden, weil festgelegt wurde:
- welches Monetarisierungsmodell genutzt wird
- wie Trial und Abo-Struktur aussehen
- dass Annual priorisiert wird
- dass es keinen Lifetime-Plan zum Start gibt
- welche Bereiche Free vs Premium sind
- dass die Paywall direkt nach dem Onboarding bleibt

———————————————————

# Ticket 2 – Produktpositionierung in 1 Satz festlegen

## Ergebnis

Die finale Produktpositionierung für **ayo** lautet:

**Ayo gives you calm, practical support to quit nicotine one craving at a time.**

## Strategische Entscheidung

Dieser Satz wird als zentrale Positionierung der App verwendet und dient als Grundlage für:

- Paywall-Kommunikation
- App Store Subtitle
- Screenshot-Headlines
- Store-Beschreibung
- Onboarding-Ton
- spätere Marketingtexte

## Begründung

Der Satz wurde gewählt, weil er die stärksten Eigenschaften von ayo klar zusammenführt:

- **calm** → passt zur ruhigen, unterstützenden Markenwirkung
- **practical support** → zeigt, dass die App nicht nur motiviert, sondern konkret hilft
- **quit nicotine** → benennt das Kernziel direkt
- **one craving at a time** → hebt den entscheidenden situativen Nutzen hervor und macht die App weniger generisch als ein reiner Quit-Tracker

## Was bewusst vermieden wurde

Nicht gewählt wurden Formulierungen, die zu generisch, zu klinisch oder zu austauschbar wirken, z. B.:

- „quit smoking and track progress“
- „stop nicotine addiction“
- „habit tracker for quitting“

ayo soll nicht wie ein gewöhnlicher Tracker oder eine rein motivierende Wellness-App wirken, sondern wie ein **ruhiges, hochwertiges Support-System für echte Craving-Momente**.

## Abgeleitete Richtungen für andere Bereiche

### Paywall
**Get calm, practical support to quit nicotine — one craving at a time.**

### App Store Subtitle
**Calm support for cravings and quitting nicotine**

### Screenshot-Headline
**Quit nicotine one craving at a time**

### Tonalität
Die gesamte Kommunikation von ayo soll:
- ruhig
- unterstützend
- modern
- nicht klinisch
- nicht belehrend
- nicht generisch

sein.

## Definition of Done

Ticket 2 gilt als entschieden, weil:
- ein finaler Positionierungssatz gewählt wurde
- dieser Satz als zentrale Kommunikationsbasis festgelegt wurde
- klar definiert wurde, wie sich ayo sprachlich von generischen Quit-Apps abgrenzt

———————————————————

# Ticket 3 – RevenueCat auf Production-Setup umstellen

## Ergebnis

Für **ayo** wird das RevenueCat-Setup als bewusst einfaches, robustes und revenue-orientiertes Subscription-System festgelegt.

## Finale Struktur

### Entitlement
Es wird genau **ein Entitlement** verwendet:

- `ayo_premium`

Dieses Entitlement steht für die vollständige Premium-Version der App.

### Offering
Es wird ein zentrales Haupt-Offering verwendet:

- `main`

Dieses Offering bildet die Standard-Paywall-Logik von ayo ab und dient als primäre Produktquelle für den Release.

### Produkte / Packages
Im Offering `main` werden genau zwei Subscription-Pakete geführt:

- **monthly**
- **annual**

### Trial-Logik
Die Trial-Strategie wird wie folgt festgelegt:

- **Annual:** 7-day free trial
- **Monthly:** kein free trial

### Priorisierung
- **Annual** ist das klar bevorzugte Hauptangebot auf der Paywall
- **Monthly** ist die sekundäre Alternative
- **Lifetime** wird zum Start nicht angeboten

## Strategische Entscheidung

Das RevenueCat-Setup soll bewusst **einfach und klar** bleiben.

Es wird **keine komplexe Entitlement-Struktur** mit mehreren Premium-Stufen oder Sonderfällen eingeführt, weil ayo aktuell eine zentrale Premium-Vollversion besitzt und keine mehrstufige Produktlandschaft benötigt.

Ziel ist:
- einfache technische Integration
- saubere Gating-Logik
- geringere Fehleranfälligkeit
- klare Messbarkeit der Monetarisierung
- bessere QA-Fähigkeit vor dem Release

## Technische Prinzipien

Für den finalen Release gelten folgende Regeln:

- Produkte und Preise werden **dynamisch aus RevenueCat / StoreKit geladen**
- es gibt **keine hardcoded Preislogik** im finalen Release
- es gibt **keine hardcoded Trial-Kommunikation**, die nicht exakt der echten Store-Konfiguration entspricht
- der Premium-Status wird zentral über das Entitlement `ayo_premium` geprüft
- Kauf, Restore und Entitlement-Refresh müssen den UI-Zustand sofort korrekt aktualisieren

## Warum diese Struktur gewählt wurde

Diese Struktur wurde gewählt, weil sie für den aktuellen Stand von ayo die beste Balance aus **Einfachheit, Conversion-Fokus und Skalierbarkeit** bietet.

### Gründe:
- ayo hat aktuell **eine Premium-Vollversion**, keine mehreren Produktstufen
- ein einzelnes Entitlement reduziert technische Komplexität
- Annual mit Trial unterstützt eine stärkere LTV-Strategie
- Monthly bleibt als niedrigere Einstiegshürde sichtbar
- Trial nur auf Annual lenkt Nutzer bewusst auf das wertvollere Hauptangebot
- das Setup ist leicht testbar und sauber für spätere Erweiterungen

## Was bewusst nicht gemacht wird

Zum Start wird bewusst **nicht** eingeführt:

- kein zweites Premium-Entitlement
- keine Sonder-Entitlements für Trial-User
- kein Lifetime-Produkt
- keine unnötig komplexe Offering-Struktur
- keine widersprüchliche Trial-Logik auf mehreren Ebenen

## Definition of Done

Ticket 3 gilt als inhaltlich entschieden, weil festgelegt wurde:

- welches Entitlement genutzt wird
- welches Haupt-Offering genutzt wird
- welche Subscription-Pakete enthalten sind
- dass Annual das Hauptangebot ist
- dass nur Annual einen 7-day free trial erhält
- dass Monthly ohne free trial geführt wird
- dass Lifetime zum Start nicht angeboten wird
- dass Preise und Produktdaten dynamisch aus RevenueCat geladen werden

———————————————————

# Ticket 4 – Paywall komplett neu ausarbeiten

## Ergebnis

Die Paywall von **ayo** wird nicht als einzelner harter Abo-Screen aufgebaut, sondern als klar geführte Premium-Sequenz direkt nach dem personalisierten Plan.

## Finale Struktur

Die bisherige Struktur wird wie folgt überarbeitet:

1. **Plan-Ready-Screen** wird zur inhaltlichen Bridge überarbeitet  
2. danach folgt ein eigener **Trial-/Reminder-Screen**  
3. danach folgt die eigentliche **Main Paywall**

Es wird **kein zusätzlicher neuer Step vor dem Plan-Screen** eingeführt.  
Stattdessen übernimmt der überarbeitete Plan-Screen den Übergang vom Onboarding in die Premium-Entscheidung.

## Screen 1 – Überarbeiteter Plan-Ready-Screen

### Rolle
Der Screen bestätigt, dass der personalisierte Plan erstellt wurde, und leitet logisch in den vollen Premium-Support über.

### Headline
**Your plan is ready — now unlock the full support behind it**

### Ziel
- den Wert des erstellten Plans erhöhen
- den Nutzer nicht direkt hart verkaufen
- den Übergang zur Trial-/Paywall-Sequenz logisch machen

## Screen 2 – Trial-/Reminder-Screen

### Headline
**Start with 7 days of full support**

### Subtext
**Try Ayo Premium free for 7 days. We’ll remind you before your trial ends.**

### CTA
**See premium access**

### Ziel
- Risiko senken
- Trial verständlich machen
- Vertrauen aufbauen
- die Premium-Version als vollen Support-Raum fram en

## Screen 3 – Main Paywall

### Main Headline
**Get the full support system for quitting nicotine**

### Benefit-Liste
- Get support when cravings hit
- Unlock the full rescue library
- See your progress more clearly
- Build a stronger quit routine

### CTA
**Start 7-day free trial**

### Skip
**Continue with limited access**

## Angebotslogik

### Annual Plan
Der Annual Plan ist das klar bevorzugte Hauptangebot.

#### Framing
- **Annual**
- **7-day free trial**
- **Best value**
- **Most popular · Save X%**

### Monthly Plan
Der Monthly Plan bleibt sichtbar, ist aber klar sekundär.

#### Framing
- **Monthly**
- **Pay monthly, cancel anytime**

## Strategische Entscheidung

Die Paywall soll:
- Premium als eigentliche Vollversion von ayo positionieren
- den Annual Plan mit Trial priorisieren
- Free bewusst begrenzt lassen
- konvertieren, ohne billig oder spammy zu wirken

## Rabatt-/Value-Logik

Der Preisvorteil des Annual Plans wird nicht als künstlicher Fake-Sale dargestellt, sondern als glaubwürdiger Jahresvorteil.

Dafür wird auf der Annual-Option ein klares Value-Framing genutzt:

- **Best value**
- **Most popular**
- **Save X%**

Der Rabatt wird also als **wertorientierter Vergleich zum Monthly Plan** kommuniziert, nicht als aggressiver Countdown- oder Flash-Sale.

## Was bewusst vermieden wird

Die neue Paywall soll **nicht** mit folgenden Mechaniken arbeiten:

- keine künstlichen Wartezeiten
- keine hektischen Countdown-Elemente
- keine aggressive Spam-Unterbrechung
- keine überladene Discount-Kommunikation
- keine billig wirkenden Dark-Pattern-Elemente

## Tonalität

Die gesamte Paywall-Kommunikation soll:
- ruhig
- hochwertig
- klar
- vertrauenswürdig
- premium-orientiert

sein.

## Definition of Done

Ticket 4 gilt als inhaltlich entschieden, weil festgelegt wurde:

- wie die neue Paywall-Sequenz aufgebaut ist
- dass der Plan-Ready-Screen die Bridge übernimmt
- wie Trial-/Reminder-Screen formuliert sind
- wie die Main Paywall formuliert ist
- welche Benefit-Liste genutzt wird
- wie Annual und Monthly geframet werden
- wie der Skip-Pfad benannt wird
- wie der Preisvorteil des Annual Plans kommuniziert wird

———————————————————

# Ticket 5 – Premium-Gating sauber implementieren

## Ergebnis

Das Premium-Gating von **ayo** wird bewusst klar, sichtbar und conversion-orientiert aufgebaut.  
Die kostenlose Nutzung soll den Wert der App kurz erlebbar machen, aber Premium klar als eigentliche Vollversion positionieren.

## Grundprinzip

Free soll:
- die App verständlich machen
- den Kernnutzen kurz erlebbar machen
- Premium sichtbar begehrenswert machen

Premium soll:
- sich wie die eigentliche App anfühlen
- in mehreren Kernbereichen deutlich mehr bieten
- durch sichtbare Locks und klare Grenzen logisch aufgewertet werden

## Gating-Struktur nach Bereichen

### Home
Die Home-Seite bleibt im Free-Plan vollständig sichtbar.

Ziel:
- Überblick geben
- Produktwert zeigen
- die App nicht kaputt oder leer wirken lassen

Home dient als sichtbares Schaufenster des Systems, ohne dass dadurch automatisch alle Premium-Vorteile frei nutzbar sind.

---

### Rescue
Der Rescue-Bereich wird zum stärksten Premium-Hebel.

#### Free
- der Nutzer sieht genau **1 Rescue Tool**
- dieses eine Tool kann **genau 1 Mal** genutzt werden

#### Danach
- nach der ersten Nutzung wird auch dieses Tool gesperrt
- alle Rescue Tools sind danach:
  - gesperrt
  - visuell abgeschwächt / blurred
  - mit Schloss versehen

#### Verhalten
- Tap auf ein gesperrtes Rescue Tool öffnet **direkt die Main Paywall**

#### Zusätzliche Logik
Nach der einmaligen kostenlosen Nutzung des freien Rescue-Tools erscheint direkt ein kleiner Upsell-Moment, der erklärt, dass die freie Rescue-Session verbraucht wurde und die volle Rescue-Bibliothek nur mit Premium verfügbar ist.

Ziel:
- Nutzer den Kernnutzen einmal erleben lassen
- danach Rescue klar als Premium-System positionieren

---

### Progress
Im Progress-Bereich bleiben nur die Basic-Infos frei.

#### Free
- nicotine-free days
- money saved

#### Premium
- deeper insights
- history
- patterns
- weiterführende Progress-Karten

#### Darstellung
- Premium-Progress-Bereiche bleiben sichtbar
- sie sind jedoch gesperrt
- Tap auf gesperrte Progress-Elemente öffnet direkt die Main Paywall

Ziel:
- Fortschritt sichtbar machen
- gleichzeitig klar zeigen, dass die eigentliche Tiefe nur in Premium liegt

---

### Markers / Achievements
Markers werden teilweise frei und teilweise Premium.

#### Free
- einige wenige Marker sind frei verfügbar

#### Premium
- weitere Marker / Achievements sind gesperrt
- sie bleiben sichtbar, aber locked

#### Verhalten
- Tap auf gesperrte Marker öffnet direkt die Main Paywall

Ziel:
- Premium emotional greifbar machen
- sichtbare Motivation erzeugen
- das Achievement-System nicht komplett verschenken

---

### Settings
Der Settings-Bereich bleibt grundsätzlich frei zugänglich.

#### Free
- Basis-Settings
- Account
- Login
- Privacy / Terms
- allgemeine App-Funktionen

#### Premium
- **Dark Mode** ist Premium

Ziel:
- Settings nicht künstlich unbenutzbar machen
- gleichzeitig einen klar sichtbaren Premium-Mehrwert im Bereich Appearance schaffen

## Reaktionslogik bei gesperrten Bereichen

Für gesperrte Premium-Elemente gilt appweit:

- Tap auf ein gesperrtes Element öffnet **direkt die Main Paywall**

Es wird **kein separates Zwischensheet** vor der Paywall verwendet.

## Strategische Entscheidung

Dieses Gating wurde bewusst relativ klar und streng gewählt, damit:

- Premium sich wie die eigentliche Vollversion anfühlt
- Free nicht zu großzügig wird
- der Nutzer Premium in mehreren Bereichen sichtbar wahrnimmt
- besonders der Rescue-Bereich als klarer Conversion-Hebel funktioniert

## Was bewusst vermieden wird

- keine unklare Mischlogik
- keine versteckten Premium-Bereiche ohne Sichtbarkeit
- keine komplett leere Free-Version
- kein uneinheitliches Verhalten zwischen gesperrten Bereichen
- keine zu großzügige Free-Nutzung im Rescue-Kernbereich

## Definition of Done

Ticket 5 gilt als inhaltlich entschieden, weil festgelegt wurde:

- welche Bereiche frei und welche premium sind
- dass Home vollständig sichtbar bleibt
- dass Rescue nur 1 Mal kostenlos nutzbar ist
- dass Rescue danach vollständig gesperrt wird
- dass Progress nur Basic-Infos frei zeigt
- dass Marker teilweise frei und teilweise premium sind
- dass Dark Mode Premium ist
- dass gesperrte Bereiche direkt zur Main Paywall führen
- dass nach der einmaligen Free-Rescue-Nutzung ein direkter Upsell-Moment erscheint

———————————————————


# Ticket 6 – Paywall-Platzierung final entscheiden

## Ergebnis

Die Haupt-Paywall von **ayo** wird final **direkt nach dem Onboarding** platziert, genauer gesagt nach dem fertiggestellten personalisierten Plan und vor dem ersten Eintritt in die eigentliche App.

## Finale Funnel-Reihenfolge

Die finale Reihenfolge lautet:

1. Onboarding
2. personalisierter Plan wird erstellt / angezeigt
3. überarbeiteter Plan-Ready-Bridge-Screen
4. Trial-/Reminder-Screen
5. Main Paywall
6. Einstieg in die App

## Strategische Entscheidung

Die Haupt-Paywall wird an den Punkt gesetzt, an dem:

- der Nutzer bereits emotional investiert ist
- der personalisierte Plan fertig ist
- der wahrgenommene Wert hoch ist
- der Nutzer das Gefühl hat, jetzt den eigentlichen Support nutzen zu wollen

Die Paywall erscheint also **nicht zufällig**, sondern an einem klaren Intent-Moment.

## Verhalten bei Kauf / Trial-Start

Wenn der Nutzer den Trial startet oder Premium aktiviert:

- Onboarding gilt als abgeschlossen
- Premium ist sofort aktiv
- der Nutzer wird direkt in die App geführt
- keine zusätzliche Schleife oder weiterer Monetization-Screen folgt

## Verhalten bei Skip

Wenn der Nutzer **Continue with limited access** wählt:

- Onboarding gilt ebenfalls als abgeschlossen
- der Nutzer wird **direkt in die App** geführt
- es gibt **keinen zusätzlichen Hinweis-Screen**
- die App startet in der reduzierten Free-Version

## In-App-Paywalls nach dem Onboarding

Für die erste Release-Version werden spätere In-App-Paywalls **nur reaktiv über gesperrte Bereiche** ausgelöst.

Das betrifft insbesondere:

- gesperrte Rescue-Tools
- gesperrte Progress-Bereiche
- gesperrte Marker / Achievements
- Dark Mode

Tap auf ein gesperrtes Premium-Element führt direkt zur Main Paywall.

## Was bewusst nicht gemacht wird

Zum Start wird bewusst **nicht** eingeführt:

- kein zusätzlicher Exit-Offer-Screen direkt nach dem Skip
- kein weiterer Monetization-Screen vor dem Eintritt in die Free-Version
- kein sanfter Relaunch-Upsell direkt nach dem Onboarding
- keine unnötig verlängerte Funnel-Struktur

## Spätere Erweiterung

Ein zusätzlicher sanfter Relaunch-Upsell kann **später in Updates** getestet werden, ist aber **nicht Teil von V1**.

Für den ersten Release bleibt die In-App-Monetarisierung nach dem Onboarding bewusst einfacher:

- Haupt-Paywall direkt nach dem Plan
- danach nur reaktive Upsells über Locks

## Begründung

Diese Platzierung wurde gewählt, weil sie:

- den stärksten Intent-Moment nutzt
- den Premium-Wert logisch aus dem personalisierten Plan ableitet
- Free weiterhin erlaubt, aber klar begrenzt
- die Funnel-Reibung gering hält
- technisch und UX-seitig sauberer ist als zusätzliche Exit-Schleifen

## Definition of Done

Ticket 6 gilt als inhaltlich entschieden, weil festgelegt wurde:

- wo die Haupt-Paywall im Funnel erscheint
- in welcher Reihenfolge die Monetization-Sequenz aufgebaut ist
- dass Nutzer nach Kauf direkt in die App gelangen
- dass Nutzer nach Skip direkt in die reduzierte Free-Version gelangen
- dass es keinen zusätzlichen Free-Hinweis-Screen gibt
- dass spätere In-App-Paywalls in V1 nur reaktiv über Locks ausgelöst werden
- dass ein Relaunch-Upsell frühestens in späteren Updates getestet wird


———————————————————

# Ticket 7 – Monetization Analytics ergänzen

## Ergebnis

Für **ayo** wird ein kompaktes, klar fokussiertes Monetization-Tracking definiert, das den Paywall-Funnel, Subscription-Aktionen, Premium-Locks und den Einstieg in Free vs Premium messbar macht.

Ziel ist **nicht** maximal viel Tracking, sondern ein schlankes Set an Events, das echte Produkt- und Monetarisierungsentscheidungen ermöglicht.

## Tracking-Ziel

Mit dem Monetization-Tracking soll später beantwortet werden können:

- wie viele Nutzer die Main Paywall sehen
- wie viele Nutzer die Paywall verlassen
- wie viele Nutzer einen Kauf oder Trial starten
- wie viele Käufe erfolgreich oder fehlgeschlagen sind
- welche Premium-Locks am stärksten in Richtung Paywall drücken
- wie viele Nutzer als Free vs Premium in die App eintreten

## Finale Event-Liste für V1

### Paywall Funnel
- `trial_screen_viewed`
- `main_paywall_viewed`
- `paywall_dismissed`

### Subscription Actions
- `purchase_started`
- `trial_started`
- `purchase_completed`
- `purchase_failed`
- `restore_attempted`
- `restore_succeeded`
- `restore_failed`
- `entitlement_activated`

### Premium Locks
- `premium_lock_tapped`

### Einstieg in die App
- `entered_app_as_free_user`
- `entered_app_as_premium_user`

## Strategische Entscheidung

### Kein separates Event für den Plan-Ready-Bridge-Screen
Der überarbeitete Plan-Ready-Bridge-Screen wird **nicht separat als eigener Monetization-Funnel-Step getrackt**.

Begründung:
- der Funnel für V1 soll bewusst kompakt bleiben
- Trial-Screen und Main Paywall reichen für die erste Monetization-Auswertung
- unnötige zusätzliche Funnel-Stufen werden vorerst vermieden

### Premium-Locks als generisches Event
Für gesperrte Premium-Bereiche wird **ein generisches Event** verwendet:

- `premium_lock_tapped`

Statt mehrere einzelne Lock-Events zu definieren, wird das Event über Properties differenziert.

Begründung:
- sauberere Analytics-Struktur
- weniger Event-Wildwuchs
- leichter erweiterbar
- einfacher für Codex und spätere Auswertung

### Free vs Premium Eintritt separat tracken
Der Eintritt in die App wird getrennt erfasst:

- `entered_app_as_free_user`
- `entered_app_as_premium_user`

Begründung:
- späterer Vergleich von Verhalten und Retention zwischen beiden Gruppen
- bessere Bewertung des Free-Tiers
- bessere Grundlage für Monetization-Learnings

## Event Properties

### `premium_lock_tapped`
Verwendete Properties:
- `lock_type` = rescue / progress / marker / darkmode
- `screen` = rescue / progress / markers / settings

### `main_paywall_viewed`
Verwendete Properties:
- `source` = onboarding / rescue_lock / progress_lock / marker_lock / darkmode_lock

### `purchase_started`
### `trial_started`
### `purchase_completed`
### `purchase_failed`
Verwendete Properties:
- `product_type` = annual / monthly
- `offering` = main
- `source` = onboarding / rescue_lock / progress_lock / marker_lock / darkmode_lock

### `purchase_failed`
Zusätzliche Property, falls verfügbar:
- `reason`

### `restore_attempted`
### `restore_succeeded`
### `restore_failed`
Optional verwendete Properties:
- `source`
- `result`

## Was bewusst nicht getrackt wird

Zum Start wird bewusst **nicht** eingeführt:

- kein separates Monetization-Event für jeden einzelnen Screen der Premium-Sequenz
- keine unnötig feingranularen UI-Events
- kein überladenes Analytics-Setup
- keine komplexe Trial-Lifecycle-Logik über V1 hinaus

## Begründung

Diese Event-Struktur wurde gewählt, weil sie:

- den relevanten Monetization-Funnel messbar macht
- klein genug für V1 bleibt
- technisch einfach umzusetzen ist
- später klare Learnings über Trial, Kauf und Gating ermöglicht
- gut zu der bestehenden reduzierten PostHog-Strategie passt

## Definition of Done

Ticket 7 gilt als inhaltlich entschieden, weil festgelegt wurde:

- welche Monetization-Events in V1 getrackt werden
- dass der Plan-Ready-Bridge-Screen nicht separat getrackt wird
- dass Premium-Locks über ein generisches Event mit Properties erfasst werden
- dass Free- und Premium-Einstieg separat getrackt werden
- welche Kern-Properties für Paywall-, Kauf- und Lock-Events verwendet werden
- dass das Monetization-Tracking bewusst kompakt gehalten wird

———————————————————

# Ticket 8 – Placeholder- und Debug-Cleanup

## Ergebnis

Für **ayo** wird ein strenger Release-Cleanup festgelegt, damit die App im ersten Release vollständig wie ein bewusst fertiges Produkt wirkt.

Die Grundregel lautet:

- alles, was Nutzer oder Apple sehen, muss sauber, final und markenkonsistent wirken
- halbfertige, temporäre oder interne Entwicklungsreste dürfen im Release nicht sichtbar sein
- entfernte V1-Inhalte sollen dokumentiert werden, damit sie später leicht wiedereingeführt werden können

## Strategische Entscheidung

Der Cleanup wird für V1 bewusst streng gehandhabt, damit:

- ayo nicht wie ein MVP-Testbuild wirkt
- keine unfertigen Produktspuren sichtbar bleiben
- die Monetarisierung und Positionierung nicht durch alte Texte oder Logik verwässert werden
- das Produkt vertrauenswürdig und review-tauglich erscheint

## Finale Cleanup-Regeln

### 1. Coming-soon-Elemente
Für V1 werden sichtbare **Coming-soon-Elemente entfernt oder versteckt**.

Es gilt:
- kein sichtbares „coming soon“ im Release
- keine halbfertigen Feature-Hinweise für Nutzer
- keine UI-Bereiche, die unfertig oder nur teilweise vorbereitet wirken

#### Zusatzregel
Alles, was für V1 entfernt oder verborgen wird, soll **sauber dokumentiert** werden, damit eine spätere Wiedereinführung leichter möglich ist.

Das betrifft z. B.:
- spätere Feature-Ideen
- deaktivierte Flows
- vorbereitete, aber noch nicht veröffentlichte Bereiche

---

### 2. Namens- und Brand-Cleanup
User-facing wird die App vollständig auf **Ayo** vereinheitlicht.

Es gilt:
- keine sichtbaren Alt-Namen wie „Nic Free MVP“
- keine alten internen Produktbezeichnungen im Interface
- keine inkonsistenten Titel, Labels oder Meta-Texte

Ziel:
- komplette markenseitige Konsistenz im Release

---

### 3. Debug-Prints und interne Helfer
Debug-Prints und interne technische Helfer müssen **nicht zwangsläufig vollständig aus dem Code verschwinden**, solange sie:

- im Release-Build nicht sichtbar für Nutzer sind
- keine UX beeinträchtigen
- keine Review-Risiken erzeugen
- keine internen Testzustände freilegen

Ziel:
- pragmatisch bleiben
- Release sauber halten
- unnötige technische Sterilität vermeiden

---

### 4. Halbfertige Features
Für V1 gilt grundsätzlich:

- halbfertige Features sollen **nicht halb sichtbar veröffentlicht** werden
- sie sollen entweder:
  - fertig gemacht werden
  - oder vollständig versteckt werden

#### Zusatzregel
Ob ein halbfertiges Feature für V1 **fertig gemacht** oder **versteckt** wird, soll jeweils bewusst entschieden und gemeinsam besprochen werden.

#### Dokumentationsregel
Wenn ein halbfertiges Feature für V1 versteckt wird:
- Status dokumentieren
- Wiedereinführung vereinfachen
- offene Punkte notieren

Ziel:
- kein unfertiger Zwischenzustand im Release
- trotzdem keine unnötige Wegwerf-Arbeit

## Cleanup-Kategorien

### Brand Cleanup
- Ayo überall vereinheitlichen
- alte Benennungen entfernen

### Copy Cleanup
- Placeholder-Texte entfernen
- temporäre Texte entfernen
- inkonsistente Trial-/Premium-Texte korrigieren
- unfertige Erklärtexte entfernen

### Feature-State Cleanup
- unfertige Features nicht sichtbar lassen
- entfernte Features dokumentieren

### Debug Cleanup
- sichtbare Test- oder Debug-Zustände entfernen
- Release-Build auf Nutzerwahrnehmung prüfen

### Visual Cleanup
- UI-Reste bereinigen, die nach Testbuild oder Prototyp wirken
- inkonsistente Buttons, Spacing- oder Wording-Reste beseitigen

## Was bewusst vermieden wird

- keine sichtbaren „coming soon“-Stellen im Release
- keine alten Produktnamen im Interface
- keine halbfertigen Nutzer-Flows
- keine unfertigen Testspuren im sichtbaren Produkt
- keine unnötige interne Perfektionierung, wenn sie keinen Release-Wert bringt

## Begründung

Diese Entscheidung wurde getroffen, weil ein Premium-orientiertes Produkt wie ayo stark von **Vertrauen, Kohärenz und Reifeeindruck** lebt.

Gerade bei:
- Paywall
- Premium-Gating
- Settings
- Auth
- Produkttexten

können kleine sichtbare MVP-Reste den Gesamteindruck stark schwächen.

## Definition of Done

Ticket 8 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass sichtbare Coming-soon-Elemente für V1 entfernt oder versteckt werden
- dass entfernte Inhalte sauber dokumentiert werden sollen
- dass die App user-facing vollständig auf **Ayo** vereinheitlicht wird
- dass Debug-Prints intern pragmatisch behandelt werden dürfen, solange der Release sauber bleibt
- dass halbfertige Features für V1 entweder fertig gemacht oder versteckt werden
- dass diese Entscheidung je Feature bewusst getroffen und dokumentiert wird
- dass sichtbare MVP-/Test-/Placeholder-Reste im Release nicht erlaubt sind

———————————————————

# Ticket 9 – Edge Cases für Kauf und Login testen

## Ergebnis

Für **ayo** wird vor dem Release ein klar definierter Edge-Case-Testumfang für Kauf, Login, Onboarding-Zustände, Premium-Gating und Offline-Verhalten festgelegt.

Die Edge-Case-Tests werden **nicht in P0 / P1 unterteilt**, sondern als zusammenhängender Pflicht-Testblock behandelt.

## Strategische Entscheidung

Vor dem ersten Release sollen alle kritischen Randfälle getestet werden, die:

- Kauf oder Trial betreffen
- Restore betreffen
- Apple- oder Google-Login betreffen
- den Onboarding-Zustand beeinflussen
- Free vs Premium falsch darstellen könnten
- bei fehlender Internetverbindung problematisch werden
- durch verzögerte RevenueCat-/Entitlement-Aktualisierung zu falschen Zuständen führen könnten

Ziel ist:
- keine Dead Ends
- keine falschen Premium-Zustände
- keine kaputten Onboarding-Rückkehrzustände
- keine irreführende Nutzererfahrung bei Fehlern

## Pflicht-Testbereiche

### 1. Purchase / Subscription
Folgende Fälle müssen getestet werden:

- Kauf erfolgreich
- Kauf abgebrochen
- Kauf fehlgeschlagen
- Trial gestartet
- Restore mit aktivem Abo
- Restore ohne aktives Abo
- Restore fehlgeschlagen
- RevenueCat antwortet verzögert
- Entitlement wird verzögert aktualisiert

Ziel:
- Premium muss korrekt aktiviert werden
- Abbrüche oder Fehler dürfen keinen kaputten Zustand erzeugen
- Restore muss verständlich und verlässlich sein

---

### 2. Login / Auth
Folgende Fälle müssen getestet werden:

- Apple Login erfolgreich
- Google Login erfolgreich
- Apple Login fehlgeschlagen
- Google Login fehlgeschlagen
- Login abgebrochen
- Login-Zustand nach App-Neustart
- Sign-out / erneuter Einstieg

Ziel:
- Auth muss stabil sein
- Fehlversuche dürfen keinen Dead End erzeugen
- Rückkehr in die App muss konsistent bleiben

---

### 3. Onboarding-Zustand
Folgende Fälle müssen getestet werden:

- App wird mitten im Onboarding geschlossen
- App wird nach dem personalisierten Plan geschlossen
- App wird nach dem Trial-/Reminder-Screen geschlossen
- App wird nach der Main Paywall geschlossen
- App wird nach Skip geschlossen
- App wird nach Purchase geschlossen

Ziel:
- Nutzer muss in einen sauberen Zustand zurückkehren
- Onboarding darf nicht inkonsistent oder kaputt werden
- Skip und Purchase müssen korrekt persistiert werden

---

### 4. Free vs Premium Gating
Folgende Fälle müssen getestet werden:

- Free-User sieht die korrekten Locks
- Premium-User sieht keine Free-Locks mehr
- Rescue ist genau 1 Mal kostenlos nutzbar
- Rescue ist danach korrekt gesperrt
- Progress-Locks funktionieren korrekt
- Marker-Locks funktionieren korrekt
- Dark Mode ist korrekt Premium
- Tap auf gesperrte Bereiche öffnet korrekt die Main Paywall

Ziel:
- Gating muss logisch, konsistent und technisch korrekt funktionieren
- Premium darf weder zu viel noch zu wenig freischalten
- Free darf nicht versehentlich Premium-Zugriff erhalten

---

### 5. Offline- / Netzwerkverhalten
Offline-Verhalten ist Teil der Pflicht-Tests für V1.

Folgende Fälle müssen getestet werden:

- App-Start ohne Internet
- Login ohne Internet
- Kaufversuch ohne Internet
- Restore ohne Internet

Ziel:
- die App darf nicht kaputt wirken
- Fehlerzustände müssen verständlich sein
- kritische Aktionen dürfen nicht in irreführenden Zuständen enden

---

### 6. RevenueCat Delay / Entitlement Delay
Auch verzögerte Kaufstatus-Aktualisierung wird als Testfall aufgenommen.

Folgende Fälle müssen geprüft werden:

- RevenueCat antwortet langsam
- Entitlement wird nicht sofort in der UI sichtbar
- UI aktualisiert sich nach kurzer Verzögerung korrekt
- Nutzer landet trotz Verzögerung nicht in einem falschen finalen Zustand

Ziel:
- kein falscher Free/Premium-Status
- keine verwirrende Kauf-Erfahrung
- sauberer Übergang auch bei langsamer Backend-Antwort

## Was bewusst nicht gemacht wird

- keine künstliche Trennung in P0- und P1-Testklassen
- keine rein kosmetische Testsammlung ohne strategischen Fokus
- keine unnötige Überladung mit exotischen Randfällen, die für V1 keinen realistischen Release-Wert haben

## Begründung

Dieses Test-Set wurde so gewählt, weil gerade bei **Auth, Paywall, Restore und Gating** kleine Fehler direkt zu großem Vertrauensverlust führen können.

Für ein Premium-orientiertes Produkt wie ayo sind besonders kritisch:

- falscher Premium-Status
- kaputter Kauf- oder Restore-Flow
- inkonsistenter Onboarding-Status
- sichtbare Gating-Fehler
- unverständliches Verhalten ohne Internet

## Definition of Done

Ticket 9 gilt als inhaltlich entschieden, weil festgelegt wurde:

- welche Edge Cases vor Release getestet werden müssen
- dass diese Testfälle nicht in P0 / P1 getrennt werden
- dass Offline-Verhalten Teil der Pflicht-Tests ist
- dass RevenueCat Delay und Entitlement Delay als Testfälle aufgenommen werden
- dass Kauf, Restore, Login, Onboarding-Zustände und Gating vollständig in den Testumfang gehören
- dass das Ziel der Tests ein konsistenter, vertrauenswürdiger Release-Zustand ist

———————————————————

# Ticket 10 – Fehlerzustände UX-fähig machen

## Ergebnis

Für **ayo** werden Fehlerzustände bewusst als ruhige, klare und handlungsfähige UX-Zustände gestaltet.

Fehler sollen nicht wie rohe Systemmeldungen oder unfertige Dev-Alerts wirken, sondern wie bewusst designte Produktzustände, die:

- verständlich sind
- den Nutzer nicht stressen
- die nächste sinnvolle Aktion anbieten
- zur visuellen Qualität von ayo passen

## Strategische Entscheidung

Fehlerzustände in ayo sollen:

- kurz, aber etwas menschlicher formuliert sein
- wenn technisch sinnvoll immer eine klare nächste Aktion anbieten
- sprachlich zwischen **technischem Fehler** und **kein Ergebnis** unterscheiden
- nicht primär als kleine Toasts gedacht werden, sondern bei relevanten Fällen als klar sichtbare, hochwertig gestaltete Zustände

Die UX-Richtung orientiert sich eher an ruhig gestalteten **Sheets / Fokus-Zuständen / eingebetteten Fehlerflächen**, ähnlich zu den gezeigten Referenzscreens.

## Tonalität

Die Fehlersprache soll:

- ruhig
- klar
- knapp
- menschlich
- nicht technisch
- nicht dramatisch

sein.

### Beispiele für die Richtung
- We couldn’t complete that right now.
- Please try again.
- No active purchase was found for this account.
- You appear to be offline.

## Gestaltung der Fehlerzustände

Fehlerzustände sollen für relevante Flows nicht nur als kleine Inline-Meldung erscheinen, sondern als bewusst sichtbare UX-Komponente.

Je nach Kontext sind bevorzugt:

- klar gestaltete Bottom Sheets
- größere eingebettete Error Cards
- dedizierte Fokus-Zustände innerhalb des aktuellen Flows

Nicht gewünscht für wichtige Fehlerfälle:
- rohe Systemalerts
- rein technische Fehlertexte
- winzige, leicht übersehbare Hinweise
- stilles Scheitern ohne Rückmeldung

## CTA-Regel

Wenn technisch sinnvoll, soll ein Fehlerzustand immer eine klare Anschlussaktion anbieten.

Bevorzugte CTAs:
- **Try again**
- **Restore purchases**
- **Close**
- **Back**
- **Continue**

Ziel:
- keine Sackgassen
- kein passiver Frust
- klarer nächster Schritt

## Sprachliche Trennung von Fehlerarten

Ayo unterscheidet bewusst zwischen:

### 1. Technischem Fehler
Beispiel:
- Aktion konnte gerade nicht abgeschlossen werden
- Netzwerkproblem
- Kauf/Restore/Login schlägt fehl

### 2. Kein Ergebnis / kein gültiger Zustand
Beispiel:
- kein aktives Abo gefunden
- kein wiederherstellbarer Kauf vorhanden

Diese beiden Situationen sollen **nicht gleich formuliert** werden.

### Beispiel Restore
#### Kein Ergebnis
- No active purchase was found for this account.

#### Technischer Fehler
- We couldn’t restore your purchase right now.
- Please try again.

## Relevante Fehlerbereiche

### Login / Auth
Fehler bei Apple oder Google Login sollen:
- klar formuliert
- retry-fähig
- nicht technisch roh
sein.

### Kauf / Trial
Fehler beim Starten eines Trials oder Kaufs sollen:
- ruhig formuliert
- mit Retry-Möglichkeit versehen
- ohne falsche Erfolgswirkung dargestellt werden

### Restore
Restore-Fälle müssen UX-seitig besonders sauber unterschieden werden:
- nichts gefunden
- Restore fehlgeschlagen
- offline / keine Verbindung

### Offline / Netzwerk
Fehlende Verbindung soll:
- verständlich
- knapp
- handlungsorientiert
kommuniziert werden

### Entitlement / Status-Aktualisierung
Wenn Premium-Zugriff kurz verzögert sichtbar wird, soll das nicht wie ein Fehler wirken, sondern eher wie ein kurzer Aktualisierungszustand.

Beispielrichtung:
- Your access is updating.
- This should only take a moment.

## Was bewusst vermieden wird

- keine rohen Error Codes im Nutzertext
- keine rein technischen Debug-Meldungen
- keine still scheiternden Buttons
- keine überdramatisierte Sprache
- keine rein kleinen Toasts für wichtige Fehlerfälle
- keine Gleichbehandlung von „Fehler“ und „kein Ergebnis“

## Begründung

Diese Entscheidung wurde getroffen, weil ayo als Premium-orientiertes Produkt stark von **Vertrauen, Ruhe und Reifeeindruck** lebt.

Gerade bei:
- Login
- Kauf
- Trial
- Restore
- Offline
- Premium-Zuständen

wirken billige oder technische Fehlermuster sofort unfertig.

Die Fehler-UX soll deshalb eher wie ein bewusst designter Produktzustand wirken als wie ein Standard-Systemfehler.

## Definition of Done

Ticket 10 gilt als inhaltlich entschieden, weil festgelegt wurde:

- welche Tonalität Fehlerzustände in ayo haben sollen
- dass relevante Fehler klar sichtbarer und hochwertiger gestaltet werden sollen
- dass Retry-CTAs verwendet werden, wenn technisch sinnvoll
- dass technische Fehler und „kein Ergebnis“ sprachlich getrennt werden
- dass wichtige Fehler eher als Sheets / Fokus-Zustände / eingebettete Error Cards gedacht werden
- dass rohe System- oder Debug-Fehlertexte im Release nicht akzeptabel sind

———————————————————

# Ticket 11 – RevenueCat- und State-Sync robuster machen

## Ergebnis

Für **ayo** wird der Premium-Zustand als robuster, zentraler Access-State modelliert, damit Free- und Premium-Zugriff appweit konsistent, ruhig und vertrauenswürdig bleiben.

Ziel ist, dass Nutzer nie in verwirrende oder widersprüchliche Zustände geraten, z. B.:

- Kauf erfolgreich, aber Premium noch nicht sichtbar
- Restore erfolgreich, aber Locks bleiben bestehen
- App-Start zeigt kurz den falschen Free-State
- Onboarding oder Post-Purchase-Zustand springt sichtbar hin und her

## Strategische Entscheidung

Der Subscription-/Entitlement-Status wird **nicht nur als einfacher Bool** behandelt, sondern als klarer mehrstufiger Zustand.

### Finales State-Modell
Der zentrale Premium-State kennt diese Zustände:

- `loading`
- `free`
- `premium`

## Zentrale State-Regel

Es soll **eine zentrale Quelle der Wahrheit** für den Premium-Zustand geben.

Die UI soll den Premium-Zugriff **nicht** aus mehreren verstreuten Stellen ableiten, sondern aus einem zentral verwalteten Access-State.

Ziel:
- weniger Inkonsistenzen
- weniger Race Conditions
- klarere UI-Logik
- leichter testbar

## Verhalten beim App-Start

Beim App-Start soll die App **nicht sofort blind Free oder Premium rendern**, solange der echte Status noch nicht sauber geladen wurde.

### Entscheidung
Beim App-Start wird zunächst ein **schön gestalteter Loading-/Sync-Zustand** gezeigt, bis der echte Subscription-/Entitlement-Status geladen und bestätigt ist.

### Begründung
Da ayo mit klaren Premium-Locks arbeitet, wäre ein kurz falsch gerenderter Free-State oder Premium-State direkt sichtbar und würde das Produkt unfertig wirken lassen.

Deshalb ist für V1 bewusst gewollt:

- lieber kurzer, ruhiger Loading-State
- statt falscher Übergangszustände

## Verhalten nach Onboarding und Kauf

Besonders nach dem Onboarding-Funnel und nach einem erfolgreichen Kauf soll die App ebenfalls nicht in einen unsauberen Zwischenzustand springen.

### Entscheidung
Nach Onboarding + Kauf / Trial-Start wird ebenfalls ein **schöner Loading-/Sync-Screen** verwendet, bis der finale Access-State sicher geladen ist.

Ziel:
- kein sichtbares Hin-und-Her zwischen Free und Premium
- keine widersprüchlichen Locks direkt nach Kauf
- ruhiger Premium-Übergang

## Verhalten nach Restore

Nach erfolgreichem Restore muss die App den Premium-Zustand aktiv neu laden und die UI vollständig darauf aktualisieren.

### Entscheidung
Nach Restore wird der zentrale Access-State neu geladen und die UI entsprechend aktualisiert.

Wenn nötig, darf auch hier kurz ein kontrollierter Sync-/Loading-Zustand verwendet werden, damit kein falscher Zwischenzustand sichtbar wird.

## Verhalten bei langsamer RevenueCat-Antwort

Wenn RevenueCat oder Entitlement-Aktualisierung kurz verzögert reagieren, soll die App das **nicht** als endgültigen Free-State interpretieren.

### Entscheidung
Solange der echte Status noch nicht bestätigt ist, bleibt die App im Zustand:

- `loading`

statt voreilig auf `free` zu wechseln.

## Lokaler Fallback

Ein letzter bekannter lokaler Zustand darf verwendet werden, aber **nicht als finale Wahrheit**.

### Entscheidung
Ein lokal gespeicherter letzter bekannter Premium-Status darf nur als **temporärer Fallback** dienen, um interne Logik zu stützen oder spätere Optimierungen zu ermöglichen.

Er darf jedoch **nicht** den bestätigten RevenueCat-/Entitlement-Status dauerhaft ersetzen.

## Reaktionslogik der UI

Wenn sich der zentrale Access-State auf `premium` ändert, müssen gesperrte Bereiche ohne Neustart korrekt reagieren.

### Entscheidung
Nach erfolgreichem Kauf oder Restore müssen Locks **sofort ohne App-Neustart verschwinden**.

Das betrifft insbesondere:

- Rescue-Locks
- Progress-Locks
- Marker-Locks
- Dark-Mode-Lock
- alle anderen premium-relevanten UI-Bereiche

## UX-Richtung für Loading-/Sync-Zustände

Die Loading-/Sync-Zustände sollen nicht wie rohe Technik-Spinner wirken, sondern wie bewusst designte Produktzustände.

Sie sollen:
- ruhig
- hochwertig
- klar
- markenkonsistent

sein.

Nicht gewünscht:
- rohe Standard-Loader ohne Kontext
- hektische Spinner-Only-Screens
- technisch wirkende „Loading purchase state…“-Texte

## Was bewusst vermieden wird

- kein reiner Bool-State für Premium
- kein blindes Sofort-Rendering von Free/Premium ohne bestätigten Status
- kein falscher Free-State bei noch laufender Synchronisierung
- keine Locks, die nach Kauf oder Restore erst nach App-Neustart verschwinden
- kein lokaler Cache als alleinige Wahrheit

## Begründung

Diese Architekturentscheidung wurde so getroffen, weil ayo stark auf:

- sichtbares Premium-Gating
- Premium-Wahrnehmung
- Vertrauen
- Ruhe
- saubere Übergänge

angewiesen ist.

Gerade in einer App mit klaren Locks und direkter Monetarisierung nach dem Onboarding wirken unsaubere State-Übergänge sofort billig oder kaputt.

Ein bewusst gestalteter Sync-/Loading-Zustand ist daher für V1 die robustere und hochwertigere Lösung.

## Definition of Done

Ticket 11 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass der Premium-Zustand als `loading / free / premium` modelliert wird
- dass es eine zentrale Quelle der Wahrheit für den Access-State geben soll
- dass beim App-Start ein schöner Loading-/Sync-Zustand gezeigt werden darf, bis der Status geladen ist
- dass nach Onboarding und Kauf ebenfalls ein kontrollierter Loading-/Sync-Zustand verwendet werden soll
- dass nach Restore der Status aktiv neu geladen werden muss
- dass Locks nach Kauf oder Restore ohne Neustart verschwinden müssen
- dass ein lokaler letzter bekannter Zustand nur temporärer Fallback sein darf
- dass Loading-/Sync-Zustände markenkonsistent und hochwertig gestaltet werden sollen

———————————————————

# Ticket 12 – Paywall-/Purchase-Fehler und Retry-Flows konkretisieren

## Ergebnis

Für **ayo** werden Paywall-, Kauf- und Restore-Fehler als ruhige, kontrollierte und retry-fähige Zustände innerhalb der bestehenden Monetization-Flows behandelt.

Ziel ist:
- keine Sackgassen
- keine kaputte oder leere Paywall
- keine überdramatisierte Fehler-UX
- klare nächste Schritte bei Kauf- oder Restore-Problemen

## Strategische Entscheidung

Die Kaufstrecke von ayo soll auch dann stabil und vertrauenswürdig wirken, wenn:

- Produkte oder Preise nicht geladen werden
- ein Kauf abgebrochen wird
- ein Kauf fehlschlägt
- Restore nichts findet
- Restore fehlschlägt
- Premium nach erfolgreichem Kauf noch kurz synchronisiert wird

Die Fehlerlogik bleibt dabei **möglichst nah an der bestehenden Paywall**, statt den Nutzer unnötig in separate Flows zu schicken.

## Fehlerlogik nach Fall

### 1. Produkte / Preise laden nicht
Wenn Purchase-Optionen nicht geladen werden können, bleibt die Paywall nicht leer oder kaputt sichtbar.

#### Verhalten
Die Paywall zeigt einen klaren eingebetteten Fehler-/Fallback-Zustand.

#### Erlaubte Aktionen
- **Try again**
- **Restore purchases**
- **Continue with limited access**

#### Ziel
- kein toter Funnel
- Nutzer bleibt handlungsfähig
- Free-Einstieg bleibt möglich

---

### 2. Kauf wird abgebrochen
Ein abgebrochener Kauf gilt **nicht als technischer Fehler**, soll aber für den Nutzer nicht komplett still oder unklar wirken.

#### Verhalten
- der Nutzer bleibt auf der bestehenden Paywall
- es erscheint eine **kleine neutrale Info**
- kein großer Fehlerzustand
- keine dramatische Sprache

#### Ziel
- Kaufabbruch verständlich behandeln
- Nutzer nicht stressen
- Nutzer auf der Paywall halten

---

### 3. Kauf schlägt fehl
Wenn ein Kauf technisch fehlschlägt, bleibt der Nutzer auf derselben Paywall.

#### Verhalten
- integrierter Fehlerzustand direkt auf der Paywall
- keine separate Fehlerseite
- Retry bleibt möglich
- Restore bleibt verfügbar
- Continue with limited access bleibt verfügbar

#### Ziel
- keine unnötige Flow-Unterbrechung
- klare Reaktion ohne Kontextverlust
- keine Sackgasse

---

### 4. Restore findet nichts
Wenn kein aktiver Kauf gefunden wird, wird das **nicht als technischer Fehler**, sondern als Ergebnis behandelt.

#### Verhalten
- direkte integrierte Info auf der Paywall
- kein separates Sheet
- Nutzer bleibt auf der Paywall
- Trial / Kauf / Free-Einstieg bleiben möglich

#### Ziel
- klare Trennung zwischen „nichts gefunden“ und „technischer Fehler“
- verständliche UX
- kein unnötig dramatischer Zustand

---

### 5. Restore schlägt technisch fehl
Wenn Restore aus technischen Gründen nicht funktioniert:

#### Verhalten
- integrierter Fehlerzustand auf der Paywall
- Retry möglich
- Nutzer bleibt handlungsfähig

#### Ziel
- Restore-Probleme klar kommunizieren
- keine Sackgasse
- keine Verwechslung mit „nichts gefunden“

---

### 6. Kauf / Trial erfolgreich, Zugriff aber noch nicht sofort sichtbar
Wenn Kauf oder Trial erfolgreich war, der finale Zugriff aber noch kurz synchronisiert werden muss:

#### Verhalten
- Übergang in den bereits definierten Loading-/Sync-Zustand
- kein Zurück in Free
- keine falschen Locks
- danach sauberer Eintritt in Premium

#### Ziel
- ruhiger Premium-Übergang
- keine widersprüchlichen Zustände direkt nach Kauf

## UX-Regeln für diese Zustände

### Tonalität
Die Sprache bleibt:
- ruhig
- knapp
- leicht menschlich
- nicht technisch
- nicht dramatisch

### Struktur
Fehler- und Info-Zustände sollen möglichst in die bestehende Paywall integriert werden, statt neue unnötige Unterseiten zu erzeugen.

### Handlungsfähigkeit
Wenn technisch sinnvoll, soll ein klarer nächster Schritt angeboten werden.

Bevorzugte CTAs:
- **Try again**
- **Restore purchases**
- **Continue with limited access**

## Was bewusst vermieden wird

- keine leere oder halb kaputte Paywall bei fehlenden Produkten
- keine große Fehlermeldung bei bloßem Kaufabbruch
- keine unnötigen separaten Error-Screens für Standard-Purchase-Probleme
- keine Gleichbehandlung von „Restore findet nichts“ und „Restore ist fehlgeschlagen“
- kein sichtbarer Rücksprung in falsche Free-Zustände nach erfolgreichem Kauf

## Begründung

Diese Entscheidung wurde getroffen, weil die Paywall in ayo ein zentraler Conversion-Punkt ist.  
Wenn sie bei Fehlern instabil, hektisch oder unklar wirkt, schadet das gleichzeitig:

- Vertrauen
- Premium-Wahrnehmung
- Conversion
- Produktreife

Ein integrierter, ruhiger und handlungsfähiger Fehlerzustand ist für ayo die beste Lösung.

## Definition of Done

Ticket 12 gilt als inhaltlich entschieden, weil festgelegt wurde:

- wie die Paywall reagiert, wenn Produkte oder Preise nicht laden
- dass Continue with limited access auch im Fallback sichtbar bleibt
- dass ein Kaufabbruch nur eine kleine neutrale Info auslöst
- dass Kauf-Fehler innerhalb der bestehenden Paywall behandelt werden
- dass Restore-ohne-Ergebnis direkt auf der Paywall als Info behandelt wird
- dass Restore-Fehler ebenfalls handlungsfähig bleiben
- dass erfolgreiche Käufe in einen Sync-/Loading-Zustand übergehen
- dass Paywall-/Purchase-Fehler keine Sackgassen erzeugen dürfen

———————————————————

# Ticket 13 – Auth-Flows für Release reduzieren und finalisieren

## Ergebnis

Für **ayo** wird der Auth-Bereich für den ersten Release bewusst reduziert und auf die stabilsten, klarsten und review-sichersten Wege begrenzt.

## Finale sichtbare Login-Methoden in V1

In V1 sind nur diese Login-Methoden sichtbar:

- **Apple Sign-In**
- **Google Sign-In**

Nicht sichtbar in V1:
- **Email Login**

## Strategische Entscheidung

Die Auth-Logik von ayo soll im ersten Release:

- einfach
- stabil
- klar verständlich
- nicht überladen
- nicht unnötig früh im Nutzerfluss störend

sein.

Ayo soll sich in V1 zuerst wie ein **Quit-Support-Produkt** anfühlen, nicht wie ein Account-Produkt.

## Login-Pflicht in V1

Login ist in V1 **nicht als harte Pflicht vor der ersten Nutzung** vorgesehen.

### Entscheidung
Login ist **optional** und wird erst später bzw. an passenden Stellen im Produkt angeboten.

Das heißt:
- kein harter Login-Zwang vor dem eigentlichen Produktwert
- kein zusätzlicher Reibungspunkt vor Onboarding, Paywall oder Free-Nutzung
- Auth wird nicht zum Hauptzugangshindernis

## Platzierung von Login in V1

Login soll in V1 primär an folgenden Stellen wohnen:

- **Settings / Account-Bereich**
- optional zusätzlich gut zugänglich über ein **Icon oder Entry Point auf der Home-Seite oben rechts**

### Ziel
- Login ist leicht erreichbar
- Login wirkt bewusst integriert
- Login stört aber nicht den Hauptfunnel

## Rolle von Auth in V1

Auth dient in V1 vor allem als:

- Account-Zugang
- Identitätslayer
- Grundlage für spätere Wiederherstellung / Account-Komfort
- Verbindungspunkt zu Subscription-/Restore-Kontexten

Auth soll in V1 **nicht** wie ein zentrales Produktversprechen kommuniziert werden.

## Email Login in V1

Email Login wird für V1 **komplett versteckt**.

### Entscheidung
- kein sichtbares „coming soon“
- kein deaktivierter Button
- kein halbfertiger dritter Login-Weg im UI

### Begründung
Das passt zu den allgemeinen Release-Regeln aus dem Cleanup:
- keine sichtbaren halbfertigen Features
- keine unnötige Verwirrung
- keine zusätzlichen Support-Risiken

## Was bewusst vermieden wird

- kein Login-Zwang vor der ersten Nutzung
- kein überladener Auth-Screen mit zu vielen Optionen
- kein sichtbarer Email-Login in unfertigem Zustand
- keine Login-Barriere im Onboarding-Funnel
- keine Wahrnehmung von ayo als primär account-getriebenes Produkt

## Begründung

Diese Entscheidung wurde getroffen, weil ayo in V1 von:

- ruhiger UX
- geringer Reibung
- klarem Fokus
- stabiler Monetization-Logik
- lokalem Produktwert

lebt.

Ein zu prominenter oder zu früher Auth-Zwang würde:
- Onboarding unnötig verlängern
- Conversion riskieren
- das Produkt schwerer wirken lassen
- zusätzliche Fehlerquellen einführen

Die reduzierte Auth-Strategie hält den Release fokussiert und sauber.

## Definition of Done

Ticket 13 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass in V1 nur Apple und Google Login sichtbar sind
- dass Email Login vollständig versteckt wird
- dass Login in V1 nicht als harte Pflicht vor der ersten Nutzung erscheint
- dass Login primär in Settings / Account und optional auf Home oben rechts zugänglich ist
- dass Auth in V1 unterstützend, aber nicht funnel-dominant eingesetzt wird
- dass unnötige Auth-Komplexität für den ersten Release vermieden wird

———————————————————

# Ticket 14 – Privacy Policy final erstellen und live stellen

## Ergebnis

Für **ayo** wird eine reale, veröffentlichte Privacy Policy für V1 benötigt, die die tatsächliche Datenlogik der App korrekt abbildet und an allen relevanten Stellen eingebunden wird.

Die Privacy Policy soll für den ersten Release **klar und spezifisch genug** sein, ohne unnötig komplex oder überdesignt zu werden.

## Strategische Entscheidung

Die Privacy Policy von ayo soll die **local-first Architektur aktiv erklären**.

Das ist kein Nebendetail, sondern ein wichtiger Vertrauensaspekt der App.

Die Policy soll klar machen:

- dass viele produktrelevante Daten lokal auf dem Gerät gespeichert werden
- dass Drittanbieter nur für bestimmte Funktionen eingesetzt werden
- dass ayo nicht als klassisches zentral datengetriebenes Produkt aufgebaut ist

## Inhaltliche Pflichtbereiche

Die Privacy Policy muss für V1 mindestens folgende Bereiche abdecken:

### 1. Lokal gespeicherte Daten
Die Policy soll erklären, dass ayo lokal auf dem Gerät produktrelevante Daten speichern kann, z. B.:

- Onboarding-Antworten
- Birthday / age-derived context
- Gender, falls erhoben
- Cravings
- Slips
- Progress / streaks
- Settings
- lokale App-Zustände

### 2. Drittanbieter / externe Dienste
Die Privacy Policy soll Drittanbieter **nicht namentlich im Hauptentscheidungsdokument festschreiben**, sondern allgemein und flexibel als externe Dienste / Drittanbieter beschreiben.

Ziel:
- V1 pragmatisch halten
- Text nicht unnötig tool-fragil machen
- spätere Änderungen leichter machen

Trotzdem muss in der finalen Privacy Policy natürlich inhaltlich korrekt beschrieben werden, welche Arten externer Dienste verwendet werden, z. B. für:

- Authentifizierung
- Analytics
- Subscription-/Purchase-Verwaltung
- Hosting / Link-Infrastruktur

### 3. Zwecke der Verarbeitung
Die Policy soll die Zwecke klar benennen, z. B.:

- App-Funktionalität
- Fortschrittsdarstellung
- Personalisierung innerhalb der App
- Login / Authentifizierung
- Analytics / Produktverbesserung
- Subscription- und Restore-Verarbeitung

### 4. Nutzerkontakt / Datenschutzanfragen
Die Privacy Policy soll einen klaren Kontaktpunkt für Datenschutzfragen enthalten.

## Einbindung der Privacy Policy

Die Privacy Policy soll in V1 an folgenden Stellen erreichbar sein:

- **in den Settings**
- **über eine öffentliche URL**
- **in App Store Connect**

Optional kann sie zusätzlich an weiteren relevanten Stellen wie Footer-/Legal-Bereichen eingebunden werden, aber die drei oben genannten Einbindungen sind für V1 gesetzt.

## Veröffentlichungsform in V1

Für V1 reicht **eine simple veröffentlichte Text-/Dokuseite** aus.

Es wird **keine aufwendig designte eigene Privacy-Webseite** als Pflicht für den ersten Release verlangt.

Wichtig ist:
- die Seite ist öffentlich erreichbar
- die URL ist stabil
- der Inhalt ist korrekt
- die Policy wirkt nicht provisorisch oder unvollständig

## Was bewusst vermieden wird

- keine komplett generische Generator-Policy ohne Bezug zur App-Logik
- keine rein versteckte oder schwer erreichbare Policy
- keine unnötig komplizierte, überbaute Privacy-Seite für V1
- keine irreführende Cloud-/Datenspeicher-Erzählung, die nicht zur local-first Architektur passt

## Begründung

Diese Entscheidung wurde getroffen, weil ayo mit:

- lokal gespeicherten Produktdaten
- Login-Funktionen
- Analytics
- Subscriptions
- App-Store-Review-Anforderungen

eine klar nachvollziehbare Datenschutzbasis braucht.

Gerade die local-first Struktur ist dabei ein strategischer Vorteil und soll in der Privacy Policy aktiv erklärt werden, statt im Text unterzugehen.

## Definition of Done

Ticket 14 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ayo eine veröffentlichte Privacy Policy für V1 braucht
- dass die local-first Architektur aktiv erklärt werden soll
- dass die Policy lokal gespeicherte Daten und externe Dienste inhaltlich abdecken muss
- dass die Einbindung über Settings, öffentliche URL und App Store Connect erfolgt
- dass für V1 eine simple veröffentlichte Text-/Dokuseite ausreicht
- dass die Privacy Policy korrekt, erreichbar und nicht provisorisch wirken darf

———————————————————

# Ticket 15 – Terms / Abo-relevante Rechtstexte finalisieren

## Ergebnis

Für **ayo** wird für V1 eine veröffentlichte Terms-Seite benötigt, die die Nutzung der App und die wichtigsten Abo-relevanten Rahmenbedingungen ausreichend abdeckt, ohne unnötig überladen zu sein.

Die Terms sollen für den ersten Release **so knapp wie sinnvoll**, aber **so vollständig wie nötig** sein.

## Strategische Entscheidung

Die Terms von ayo sollen in V1:

- die grundlegende Nutzung der App regeln
- Premium- und Subscription-Nutzung ausreichend abdecken
- keine unnötig lange oder überkomplexe juristische Seite sein
- klar machen, dass ayo kein medizinisches oder therapeutisches Produkt ist

## Inhaltliche Pflichtbereiche

Die Terms müssen für V1 mindestens folgende Bereiche abdecken:

### 1. Nutzung der App
Die Terms sollen die grundlegende Nutzung von ayo als Produkt beschreiben, inklusive:

- allgemeine App-Nutzung
- Free- und Premium-Nutzung
- ggf. Account-/Login-Nutzung, soweit relevant

### 2. Subscription / Premium-Nutzung
Die Terms müssen Abo-relevante Inhalte **ausreichend**, aber nicht übermäßig detailliert abdecken.

Ziel:
- genug Klarheit für V1
- kein unnötig überladener Abo-Text
- keine juristische Überfrachtung

Dazu gehören grundsätzlich:
- dass Premium über In-App-Subscriptions angeboten wird
- dass Subscription-Zugriff an den Store-/Plattform-Mechanismus gebunden ist
- dass Restore grundsätzlich möglich ist
- dass sich Subscription-Details über den jeweiligen App-Store-Kontext verwalten lassen

Die Subscription-Logik soll in den Terms **nicht unnötig tief und technisch ausgeschrieben**, aber ausreichend beschrieben werden.

### 3. Kein medizinisches / therapeutisches Produkt
Die Terms sollen klar festhalten, dass ayo:

- keine medizinische Behandlung ist
- keine Therapie ersetzt
- kein Ersatz für professionelle medizinische oder therapeutische Hilfe ist

Dieser Punkt ist für V1 ausdrücklich gesetzt.

### 4. Haftungsrahmen / Nutzung
Die Terms sollen in sinnvoller Form deutlich machen, dass:

- ayo als Support-/Companion-App genutzt wird
- keine Erfolgs- oder Heilgarantie besteht
- Nutzung im üblichen Rahmen auf eigene Verantwortung erfolgt

### 5. Änderungen / Weiterentwicklung
Die Terms dürfen festhalten, dass sich:

- Funktionen
- Premium-Inhalte
- App-Bestandteile

im Laufe der Weiterentwicklung ändern können.

### 6. Kontaktpunkt
Die Terms sollen einen klaren Kontaktpunkt bzw. eine Betreiber-/Kontaktmöglichkeit enthalten.

## Einbindung der Terms

Die Terms sollen in V1 an folgenden Stellen erreichbar sein:

- **in den Settings**
- **über eine öffentliche URL**
- **an relevanten Stellen rund um Subscription / App Store / Legal-Kontext**

## Veröffentlichungsform in V1

Für V1 reicht **eine simple veröffentlichte Terms-Seite** aus.

Es wird keine aufwendig designte juristische Spezialseite verlangt.

Wichtig ist:
- öffentlich erreichbar
- stabil verlinkt
- inhaltlich korrekt
- nicht provisorisch wirkend

## Was bewusst vermieden wird

- keine unnötig lange oder überladene Abo-Erklärung
- keine juristische Monsterseite für V1
- keine komplett generischen Terms ohne Bezug zu App, Premium und Nutzung
- keine fehlende Klarstellung zum nicht-medizinischen Charakter der App

## Begründung

Diese Entscheidung wurde getroffen, weil ayo mit:

- Premium-Abo
- Trial-Logik
- Restore
- App-Store-Kontext
- sensibler Themenwelt rund um Nicotine Quit Support

eine klare, aber pragmatische rechtliche Basis braucht.

Für V1 sollen die Terms ausreichend professionell und review-tauglich sein, ohne unnötige juristische Überkomplexität zu erzeugen.

## Definition of Done

Ticket 15 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ayo für V1 eine veröffentlichte Terms-Seite braucht
- dass die Terms die Nutzung der App und Premium-Nutzung ausreichend abdecken müssen
- dass die Subscription-Logik nur so ausführlich beschrieben wird, wie es sinnvoll nötig ist
- dass der nicht-medizinische / nicht-therapeutische Charakter der App klar erwähnt werden muss
- dass die Terms über Settings, öffentliche URL und relevante Legal-/Subscription-Stellen erreichbar sein sollen
- dass für V1 eine simple veröffentlichte Seite ausreicht

———————————————————

# Ticket 16 – Health-/Claims-/Store-Sprache absichern

## Ergebnis

Für **ayo** wird eine klare Sprachregel festgelegt, damit die App stark, hilfreich und vertrauenswürdig wirkt, ohne unnötig in einen medizinischen oder therapeutischen Bereich zu rutschen.

## Strategische Entscheidung

Ayo wird sprachlich klar als:

- **support system**
- **companion app**
- **practical quit support**
- **craving support**
- **daily support for quitting nicotine**

positioniert — **nicht** als medizinisches Produkt, therapeutisches System oder Behandlungs-App.

## Grundregel für Produktsprache

Die Sprache von ayo soll in App, Paywall, Store und Onboarding:

- hilfreich
- konkret
- modern
- ruhig
- unterstützend
- nicht klinisch
- nicht überversprechend

sein.

## Was ayo sprachlich aktiv sagen darf

Erlaubte bzw. gewünschte Sprachrichtung:

- support
- help
- guidance
- cravings
- progress
- routine
- stay on track
- nicotine-free
- quit nicotine
- one craving at a time
- build a stronger quit routine
- get through cravings
- practical support
- full support system

Diese Sprache passt zur Produktidentität und zur Positionierung von ayo.

## Was ayo vermeiden soll

Nicht verwendet werden sollen Aussagen, die unnötig medizinisch, therapeutisch oder absolut klingen, z. B.:

- cure addiction
- treat addiction
- therapy
- clinical treatment
- medically proven cure
- guaranteed success
- stop nicotine addiction forever
- scientifically eliminates cravings
- prevents relapse
- replaces professional help

## Regel zu Erfolgs-Claims

Für ayo gilt bewusst:

- keine absoluten Erfolgsversprechen
- keine Garantie-Sprache
- keine Heil-/Behandlungs-Claims
- keine Aussagen, die wie medizinische Wirksamkeitsbehauptungen wirken

## Einordnung des nicht-medizinischen Charakters

Der nicht-medizinische Charakter von ayo soll klar sein, aber **nicht überall im UI penetrant wiederholt werden**.

### Entscheidung
Diese Klarstellung soll vor allem in folgenden Bereichen sauber sichtbar werden:

- **Terms**
- **Privacy / Legal-Kontext**
- **Store-Sprache**
- ggf. relevante Hilfetexte

Im normalen Produkt-UI soll ayo weiterhin wie eine starke, hilfreiche Support-App wirken und nicht wie ein juristisch entschärftes Warnprodukt.

## Claim-Check-Regel für künftige Copy

Für neue Texte in:

- Onboarding
- Paywall
- App Store
- In-App-Copy
- Marketing

gilt künftig eine kleine interne Claim-Prüfung.

Jede neue Copy sollte geprüft werden auf:

- klingt sie medizinisch?
- klingt sie zu absolut?
- klingt sie zu generisch?
- passt sie zur Markenwirkung von ayo?
- ist sie stark, ohne riskant zu werden?

## Begründung

Diese Entscheidung wurde getroffen, weil ayo sich in einem sensiblen Themenbereich bewegt, aber trotzdem nicht wie ein klinisches Produkt wirken soll.

Ziel ist eine Sprache, die:

- Vertrauen schafft
- App-Store-/Review-Risiken reduziert
- Premium-Qualität vermittelt
- die App klar als hilfreiches Produkt positioniert
- gleichzeitig keine unnötigen Health-/Medical-Claims erzeugt

## Definition of Done

Ticket 16 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ayo sprachlich als Support-System / Companion-App positioniert wird
- dass absolute Erfolgs-Claims vermieden werden
- dass medizinische oder therapeutische Sprache nicht Teil der Markenkommunikation sein soll
- dass der nicht-medizinische Charakter vor allem in Legal-/Store-Kontexten klargestellt wird
- dass neue Copy künftig gegen eine kleine Claim-Check-Regel geprüft werden soll

———————————————————

# Ticket 17 – Account-/Data-Transparency ergänzen

## Ergebnis

Für **ayo** wird in V1 ein eigener kleiner Transparenzbereich innerhalb der Settings vorgesehen, damit Nutzer grundlegende Orientierung zu Daten, Login und Premium/Restore erhalten, ohne dass die App übererklärt oder technisch wirkt.

## Strategische Entscheidung

Ayo soll in V1 im Produkt selbst **eine kompakte, bewusste Transparenzfläche** haben, statt Informationen nur verstreut oder ausschließlich über Rechtstexte auffindbar zu machen.

Diese Transparenz soll jedoch:

- knapp bleiben
- nicht technisch wirken
- nicht das Onboarding belasten
- nicht überall im Produkt prominent auftauchen

## Platzierung

Die Transparenz soll primär in den **Settings** stattfinden, idealerweise in einem kleinen Bereich wie:

- **How Ayo works**
- oder einem vergleichbaren Informations-/Erklärbereich

Es wird **nicht** festgelegt, dass diese Erklärungen breit über die ganze App verteilt oder an vielen Stellen wiederholt werden müssen.

## Rolle von Local-First

Die local-first Logik soll in V1 **nicht aktiv stark betont**, sondern eher zurückhaltend und indirekt erklärt werden.

### Entscheidung
Local-first muss nicht als großes Markenversprechen überall hervorgehoben werden, kann aber im Bereich **How Ayo works** oder ähnlichen Info-Kontexten sinnvoll erklärt werden.

Ziel:
- Transparenz schaffen
- ohne die App unnötig technisch wirken zu lassen

## Rolle von Login

Login soll in V1 als **optionaler Account-/Identity-Layer** verstanden werden, nicht als zentrales Cloud-System.

### Entscheidung
Diese Einordnung muss nicht breit im gesamten Produkt auftauchen, sondern kann gezielt im Bereich **How Ayo works** oder in passenden Account-Kontexten erklärt werden.

Ziel:
- Nutzer verstehen, warum Login existiert
- ohne daraus eine zu große oder zu technische Account-Story zu machen

## Rolle von Premium / Restore

In V1 soll auch grob erklärt werden, wie Premium und Restore zusammenhängen.

Das bedeutet:
- Premium-Zugang ist an Subscription-/Store-Kontexte gebunden
- Restore steht zur Verfügung
- Nutzer sollen grundsätzlich verstehen, dass bestehende Käufe wiederhergestellt werden können

Diese Erklärung soll ebenfalls eher knapp und produktnah bleiben.

## Inhaltliche Bausteine für den Transparenzbereich

Der Bereich soll inhaltlich ungefähr folgende Themen abdecken:

- wie Ayo grundsätzlich funktioniert
- dass bestimmte App-Daten lokal bzw. innerhalb des App-Kontexts gespeichert werden
- dass Login optional für Account-/Identity-Zwecke dient
- dass Premium über Subscription-Logik funktioniert
- dass Restore für bestehende Käufe verfügbar ist

Dabei geht es **noch nicht um finalen Wortlaut**, sondern um die inhaltliche Struktur.

## Was bewusst vermieden wird

- keine überladene technische Daten-Erklärseite
- keine übermäßige Betonung von local-first an jeder Stelle
- keine unnötig frühe Erklärung im Onboarding
- keine große Cloud-/Sync-Erzählung, die V1 nicht vollständig einlöst
- keine breit verteilte Produktbelehrung im normalen UI

## Begründung

Diese Entscheidung wurde getroffen, weil ayo zwar lokal-first und technisch relativ schlank aufgebaut ist, Nutzer aber trotzdem verstehen sollten:

- was Login grob bedeutet
- wie Premium / Restore funktionieren
- dass es einen bewussten Umgang mit Daten und Account-Zugriff gibt

Die richtige Lösung für V1 ist deshalb ein **kleiner, klarer Transparenzbereich in Settings**, nicht eine zu große oder zu technische Produkt-Erklärung.

## Definition of Done

Ticket 17 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass es in Settings einen kleinen Transparenz-/How Ayo works-Bereich geben soll
- dass local-first nicht aktiv groß vermarktet, sondern eher indirekt erklärt wird
- dass Login als optionaler Account-/Identity-Layer verstanden und im passenden Kontext erklärt werden soll
- dass Premium / Restore grob und verständlich erklärt werden sollen
- dass diese Transparenz kompakt, ruhig und produktnah bleiben soll

———————————————————

# Ticket 18 – Apple- und Google-Login final reviewen

## Ergebnis

Für **ayo** müssen Apple- und Google-Login vor dem Release als vollwertige, stabile und UX-seitig saubere Login-Optionen geprüft und finalisiert werden.

## Strategische Entscheidung

In V1 werden Apple- und Google-Login als die beiden sichtbaren Auth-Wege angeboten und sollen aus Nutzersicht **möglichst gleichwertig** behandelt werden.

Das bedeutet:
- beide sind klar zugänglich
- beide müssen stabil funktionieren
- keiner darf wie eine Notlösung oder halbfertige Option wirken

Gleichzeitig muss Apple Login auf iOS selbstverständlich sauber, systemkonform und review-sicher integriert sein.

## Umfang des finalen Reviews

Der finale Review für Apple- und Google-Login umfasst **nicht nur Erfolgsfälle**, sondern ausdrücklich auch:

- Cancel
- Fehlversuche
- Offline-Verhalten
- Rückkehrzustände
- UI-/UX-Qualität
- Produktlogik
- Review-/Reifeeindruck

## Funktionale Prüfpunkte

Vor Release müssen für beide Login-Optionen geprüft werden:

- erfolgreicher Login
- abgebrochener Login
- fehlgeschlagener Login
- Login ohne Internet
- Rückkehr nach App-Neustart
- Zustand nach Sign-out / erneutem Einstieg

Ziel:
- kein Dead End
- keine inkonsistenten Account-Zustände
- kein sichtbarer unfertiger Flow

## UX-Anforderungen

Apple- und Google-Login sollen in V1:

- ruhig
- klar
- nicht technisch
- nicht überladen
- handlungsfähig bei Fehlern

sein.

Die Login-Copy soll bewusst **knapp** bleiben und **keine große Cloud-, Sync- oder Account-Geschichte** erzählen, die V1 nicht vollständig einlöst.

## Platzierung

Login bleibt in V1 optional und soll primär an passenden Stellen wohnen, insbesondere:

- **Settings / Account**
- optional zusätzlich auf **Home oben rechts**

Die Login-Wege sollen gut auffindbar sein, aber nicht den Hauptfunnel dominieren.

## Reife-Regel für V1

Wenn sich ein Login-Flow im finalen Review als unfertig, unstabil oder unklar anfühlt, soll er für V1 **nachgeschärft oder notfalls vorübergehend versteckt** werden, statt halb gut live zu gehen.

Ziel:
- keine sichtbare halbfertige Auth-Erfahrung im Release
- Fokus auf Stabilität und Vertrauen

## Was bewusst vermieden wird

- kein sichtbarer Email-Login in V1
- keine überladene Account-Welt
- keine große Cloud-/Sync-Erzählung in der Login-Copy
- keine reine Prüfung nur der Erfolgsfälle
- keine sichtbare Notlösung bei einem schwachen Login-Flow

## Begründung

Diese Entscheidung wurde getroffen, weil Login in ayo zwar **nicht der Hauptfunnel**, aber trotzdem ein sichtbarer Produktbereich ist.

Wenn Apple oder Google Login unfertig, instabil oder unklar wirken, schadet das direkt:

- Vertrauen
- Reifeeindruck
- Account-/Restore-Verständnis
- App-Store-Qualität

Deshalb werden beide sichtbaren Login-Wege bewusst als echte Release-Flows behandelt und nicht als Nebenfunktion.

## Definition of Done

Ticket 18 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass Apple und Google Login in V1 möglichst gleichwertig behandelt werden
- dass der finale Review Erfolgsfälle, Cancel, Fehler und Offline-Verhalten umfasst
- dass Login-Copy bewusst knapp bleiben soll
- dass Login in V1 optional und passend eingebettet bleibt
- dass unfertige Login-Flows für V1 lieber nachgeschärft oder versteckt werden sollen
- dass kein halbfertiger dritter Login-Weg sichtbar wird

———————————————————

# Ticket 19 – Daily Loop final definieren

## Ergebnis

Der Daily Loop von **ayo** wird für V1 klar auf einen **täglichen smoke-free Check-in** als Hauptaktion ausgerichtet.

Ayo soll nicht nur ein passiver Tracker oder reines Rescue-Tool sein, sondern ein Produkt, das Nutzer täglich zurückholt, um ihren rauchfreien Tag bewusst zu bestätigen und ihren Fortschritt aktiv weiterzuführen.

## Strategische Entscheidung

Der wichtigste tägliche Rückkehrgrund in ayo ist:

- den rauchfreien Tag zu bestätigen
- die eigene Streak weiterzuführen
- sichtbar dranzubleiben
- dem eigenen Fortschritt näher zu kommen

Damit wird der Loop stärker auf **Verbindlichkeit, Konsistenz und Identität** aufgebaut und nicht nur auf gelegentliche Craving-Momente.

## Finaler Daily Loop

### Trigger
Der Nutzer kehrt zurück, weil er:

- seinen rauchfreien Tag bestätigen will
- seine Streak nicht verlieren möchte
- sichtbar dranbleiben will
- seinen Fortschritt weiter aufbauen will

### Hauptaktion
Die zentrale tägliche Handlung ist:

- **daily smoke-free check-in**

also die bewusste Bestätigung, dass man an diesem Tag nicht geraucht hat bzw. rauchfrei geblieben ist.

### Verstärkung
Nach dem Check-in soll der Nutzer direkt spüren:

- seine Streak wächst oder bleibt erhalten
- seine Check-in-Historie entwickelt sich weiter
- sein Progress wird konkreter und sichtbarer
- er bleibt seinem Ziel treu

### Sekundäre Produktbestandteile
Zusätzlich können weiterhin relevant sein:

- tägliche Guidance / Fokus
- Rescue bei Cravings
- Progress / Marker / Achievements

Diese sind aber **sekundär zum Hauptloop** und nicht die primäre tägliche Kernhandlung.

## Rolle der Streak

Die Streak wird ein zentraler Wiederkehrmechanismus, aber **nicht als dominantes Hauptelement im großen Hero**.

### Platzierung
Die Streak soll:

- **direkt unter dem großen Hero auf Home**
- klar sichtbar
- präsent
- relevant

platziert werden.

Sie soll wichtig wirken, aber nicht den kompletten visuellen Fokus des Screens übernehmen.

## Streak-Logik

Die Streak soll nicht zu hart oder demotivierend funktionieren.

### Entscheidung
Wenn ein täglicher Check-in einmal ausbleibt, soll die Streak **nicht sofort hart verloren gehen**.

Stattdessen soll sie in einem intelligenteren Zustand behandelt werden, z. B.:

- **on ice**
- pausiert
- gefährdet, aber noch rettbar

Diese Logik soll später zusammen mit Reminder-/Notification-Mechaniken unterstützt werden.

### Ziel
- weniger unnötige Frustration
- mehr Motivation, zurückzukommen
- stärkere Reaktivierung statt harter Bestrafung

## Progress-Bezug

Die täglichen smoke-free Check-ins sollen im Progress-Bereich deutlich mehr Bedeutung bekommen.

### Entscheidung
Check-ins sollen nicht nur im Hintergrund existieren, sondern im Progress klar sichtbar und wertvoll sein, z. B. durch:

- sichtbare Check-in-Historie
- stärkere Verbindung zu Streak
- sichtbarere Konsistenz im Verlauf

Ziel:
- Progress fühlt sich echter und lebendiger an
- der Nutzer sieht nicht nur Zahlen, sondern sein tatsächliches Dranbleiben

## Rolle von Rescue

Rescue bleibt wichtig, ist aber **nicht der Haupt-Daily-Loop**.

### Entscheidung
Rescue ist ein **sekundärer situativer Flow**, der dann relevant wird, wenn ein Craving auftritt.

Der primäre Wiederkehrmechanismus von ayo bleibt der tägliche smoke-free Check-in.

## Free vs Premium im Daily Loop

Free und Premium folgen grundsätzlich demselben Daily Loop, aber Premium wird tiefer und wertvoller.

### Free
- daily smoke-free check-in
- Basis-Streak
- Basis-Progress

### Premium
- tiefere tägliche Guidance
- stärkere Progress-Auswertung
- mehr Unterstützung im Dranbleiben
- weitere Premium-Bestandteile des Support-Systems

## Future Direction

Eine zukünftige Erweiterung soll als Produktidee dokumentiert werden:

### Ziel-/Belohnungs-System
Der Nutzer kann ein persönliches Ziel oder eine Belohnung festlegen, auf die er hinarbeitet, z. B.:

- „Wie willst du dich belohnen?“
- persönliches Ziel nach einer rauchfreien Zeit
- empfohlene Mindestdauer bis zur Belohnung
- unterstützende Erinnerung durch einen assistant-/coach-artigen Mechanismus

Diese Idee wird **noch nicht als V1-Kernfeature festgelegt**, aber bewusst als starke spätere Richtung dokumentiert.

## Was bewusst vermieden wird

- kein rein passiver Daily Loop ohne Handlung
- kein Rescue-first-Modell als Haupt-Rückkehrgrund
- keine rein dekorative Streak ohne funktionale Bedeutung
- keine sofort brutal gebrochene Streak bei jedem verpassten Check-in
- keine Daily Loop-Logik, die nur auf Zahlen und nicht auf Verhalten basiert

## Begründung

Diese Entscheidung wurde getroffen, weil ayo einen stärkeren und verbindlicheren Wiederkehrgrund braucht als nur:

- App öffnen und schauen
- bei Bedarf Rescue starten
- gelegentlich Progress ansehen

Der tägliche smoke-free Check-in ist dafür der stärkste Kern, weil er:

- bewusstes Dranbleiben fördert
- die Identität des Nutzers stärkt
- die Streak sinnvoll auflädt
- Progress lebendiger macht
- gut mit späteren Reminder-, Goal- und Assistant-Features kombinierbar ist

## Definition of Done

Ticket 19 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass der tägliche smoke-free check-in die Hauptaktion des Daily Loops ist
- dass die Streak ein zentraler Wiederkehrmechanismus wird
- dass die Streak sichtbar unter dem Hero auf Home platziert wird
- dass die Streak nicht sofort hart gebrochen, sondern intelligenter behandelt werden soll
- dass Check-ins im Progress deutlich mehr Bedeutung bekommen sollen
- dass Rescue ein sekundärer situativer Flow bleibt
- dass Free und Premium demselben Grundloop folgen, Premium aber tiefer ist
- dass die Ziel-/Belohnungs-Idee als Future Direction dokumentiert wird

———————————————————

# Ticket 20 – Home auf 1 tägliche Hauptaktion zuspitzen

## Ergebnis

Die Home-Seite von **ayo** wird klar auf **eine tägliche Hauptaktion** ausgerichtet.

Diese Hauptaktion ist:

**Mark today as smoke-free**

Home soll nicht mehr wie eine Sammlung gleichgewichteter Bereiche wirken, sondern den Nutzer klar zu seiner wichtigsten täglichen Handlung führen.

## Strategische Entscheidung

Die Home-Seite dient in V1 als täglicher Führungsbildschirm.

Ihre Aufgabe ist:

- den aktuellen Status sichtbar zu machen
- zur täglichen Hauptaktion zu führen
- die Streak präsent zu halten
- Progress als Verstärkung zu zeigen
- Rescue erreichbar, aber sekundär zu halten

## Primäre tägliche Aktion

Die stärkste tägliche Handlung auf Home ist:

**Mark today as smoke-free**

Diese Aktion soll im Hero-/Primary-Bereich die klar dominierende CTA sein.

Ziel:
- bewusste tägliche Bestätigung
- stärkere Verbindlichkeit
- klarer Daily Loop
- weniger passive Nutzung

## Verhalten nach dem Check-in

Nach dem täglichen Check-in soll nicht nur ein stilles Häkchen gesetzt werden, sondern eine spürbare Verstärkung stattfinden.

### Entscheidung
Nach dem Check-in soll Home direkt Folgendes verstärken:

- aktualisierte Streak
- relevante Progress-Signale
- kleines Marker-/Momentum-Feedback

Ziel:
- tägliche Handlung fühlt sich bedeutend an
- Progress wird lebendiger
- Nutzer spürt direkt, dass Dranbleiben etwas auslöst

## Rolle des Hero

Der Hero bleibt ein zentraler visueller Anker, soll aber funktional klarer werden.

Er dient dazu:

- den Status des Nutzers zu zeigen
- den Tageskontext zu setzen
- zur täglichen Hauptaktion zu führen

Der Hero ist also nicht nur emotionaler Kontext, sondern Startpunkt der wichtigsten Handlung.

## Rolle der Streak

Die Streak bleibt wichtig, aber wird **nicht der dominante Hero selbst**.

### Platzierung
Die Streak soll:

- direkt unter dem großen Hero
- sichtbar
- präsent
- relevant

platziert werden.

Sie soll ein klarer Wiederkehrmechanismus sein, ohne die gesamte Home-Seite zu dominieren.

## Rolle von Rescue auf Home

Rescue bleibt auf Home sichtbar und gut erreichbar, ist aber **klar sekundär** zur täglichen Check-in-Aktion.

### Entscheidung
Rescue ist:
- ein klarer sekundärer Entry
- kein gleichwertiger Hauptfokus

Ziel:
- Home bleibt täglicher Führungsbildschirm
- Rescue bleibt verfügbar für situative Unterstützung

## Rolle von Progress auf Home

Progress auf Home soll die tägliche Handlung unterstützen und verstärken, nicht den Screen dominieren.

Home soll deshalb eher mit:

- kompakten Progress-Signalen
- sichtbarer Kontinuität
- stärkerem Check-in-Bezug

arbeiten, statt viele gleich starke Karten nebeneinander zu stellen.

## Free vs Premium auf Home

Free und Premium sollen grundsätzlich **dieselbe Home-Struktur** haben, damit das Produkt konsistent bleibt.

### Entscheidung
- Home sieht in Free und Premium grundsätzlich ähnlich aus
- Premium bietet jedoch **mehr Tiefe**
- Free zeigt einige Bereiche reduzierter
- Premium-Locks können sichtbar sein
- bestimmte Inhalte / Guidance / Tiefe bleiben Premium

Ziel:
- Konsistenz im Produktgefühl
- Premium wird sichtbar wertvoller
- Free wirkt nicht wie eine völlig andere App

## Finale Home-Hierarchie

Die Home-Seite soll künftig ungefähr dieser Logik folgen:

1. **Hero + Hauptaktion**
   - Status
   - tägliche CTA: **Mark today as smoke-free**

2. **Streak-Bereich direkt darunter**
   - sichtbar
   - relevant
   - motivierend

3. **kompakte Progress-Verstärkung**
   - days nicotine-free
   - money saved
   - Check-in-/Momentum-Signale
   - kleine Marker-/Status-Rückmeldung

4. **Rescue Entry**
   - sichtbar
   - klar sekundär

5. **weitere Inhalte / Premium-Tiefe**
   - zusätzliche Guidance
   - tiefere Hinweise
   - Premium-Locks / reduzierte Bereiche

## Was bewusst vermieden wird

- keine mehreren gleich starken Hauptaktionen auf Home
- kein Rescue-first-Home
- keine rein passive Übersicht ohne klare tägliche Handlung
- keine völlig getrennte Free- und Premium-Home-Struktur
- keine überladene Kartenlandschaft ohne Fokus

## Begründung

Diese Entscheidung wurde getroffen, weil der Daily Loop von ayo auf einer klaren, verbindlichen Handlung beruhen soll.

Home muss deshalb die Frage beantworten:

**Was ist heute meine wichtigste Aktion?**

Die Antwort ist:
**Mark today as smoke-free**

Alles andere auf Home soll diese Handlung unterstützen, verstärken oder ergänzen.

## Definition of Done

Ticket 20 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass Home auf eine tägliche Hauptaktion zugespitzt wird
- dass diese Hauptaktion „Mark today as smoke-free“ ist
- dass nach dem Check-in Streak, Progress und Marker-/Momentum-Signale verstärkt werden
- dass die Streak direkt unter dem Hero präsent platziert wird
- dass Rescue auf Home sekundär bleibt
- dass Free und Premium dieselbe Home-Grundstruktur haben, Premium aber tiefer ist
- dass Home künftig eine klare visuelle und funktionale Hierarchie haben soll

———————————————————

# Ticket 21 – Lokale Notifications einbauen

## Ergebnis

Für **ayo** werden in V1 lokale Notifications als gezielter Re-Engagement-Mechanismus eingeführt, um den Daily Loop zu stützen, die Streak intelligenter zu schützen und den Trial fair zu begleiten.

## Strategische Entscheidung

Notifications in ayo sollen:

- den täglichen smoke-free Check-in unterstützen
- die Streak nicht nur bestrafen, sondern aktiv retten helfen
- Trial-Kommunikation fair einlösen
- ruhig, hilfreich und markenkonform wirken
- nicht wie aggressive Growth-Hacks erscheinen

## Notification-Typen in V1

Für V1 werden genau diese drei Notification-Typen festgelegt:

### 1. Daily Check-in Reminder
Ziel:
- Nutzer an den täglichen smoke-free Check-in erinnern
- den Daily Loop stabilisieren
- tägliche Wiederkehr fördern

### 2. Streak on ice / recovery reminder
Ziel:
- wenn ein Check-in ausbleibt, die Streak nicht sofort brutal brechen
- Nutzer aktiv zurückholen
- die „on ice“-Logik unterstützen

Diese Notification ist ausdrücklich Teil des Konzepts.

### 3. Trial reminder
Ziel:
- die Trial-Kommunikation aus der Paywall fair einlösen
- Nutzer rechtzeitig vor dem Ende des Premium-Trials erinnern

## Rolle der Streak-Reminder

Die Streak-Reminder sollen ausdrücklich die intelligentere „on ice“-Logik unterstützen.

### Entscheidung
Wenn ein täglicher Check-in ausbleibt, soll die App nicht sofort nur Verlust signalisieren, sondern einen Recovery-/Save-Moment schaffen.

Die Notification soll den Nutzer dabei ruhig und konstruktiv zurückholen.

## Permission-Zeitpunkt

Die Notification-Permission wird in V1 **früh im Onboarding** angefragt.

### Entscheidung
Der Permission-Flow ist Teil des frühen Produktaufbaus und wird nicht erst weit später im Produkt platziert.

Wichtig ist dabei:
- nicht einfach nur roher System-Prompt
- sondern ein sinnvoller Kontext, warum Notifications für Daily Check-ins und Streak-Schutz hilfreich sind

## Einstellbarkeit in V1

V1 erhält eine begrenzte, aber sinnvolle Notification-Steuerung.

### Entscheidung
Nutzer sollen in V1 mindestens steuern können:

- globale Notifications an/aus
- Daily Reminder separat an/aus

Es wird für V1 **noch keine komplexe Zeitwahl oder fein granulare Notification-Welt** als Pflicht festgelegt.

## Tonalität

Notifications in ayo sollen:

- ruhig
- knapp
- hilfreich
- nicht belehrend
- nicht pushy
- nicht dramatisch

sein.

Sie sollen zum restlichen Produkt passen und nicht wie generische Growth-Nudges wirken.

## Was bewusst vermieden wird

- keine ständigen Motivationssprüche ohne klaren Anlass
- keine aggressiven Verlust- oder Druckbotschaften
- keine spammy Premium-/Monetization-Notifications
- keine zu komplexe Notification-Architektur in V1
- keine Notification-Flut mit vielen konkurrierenden Typen

## Inhaltliche Richtung

Die Notifications sollen inhaltlich unterstützen:

- täglichen Check-in
- Streak-Erhalt / Streak-Rettung
- fairen Trial-Hinweis

Sie sollen nicht als künstliche Push-Maschinerie wirken, sondern als sinnvoller Produktbestandteil des Daily Loops.

## Begründung

Diese Entscheidung wurde getroffen, weil ayo mit dem Daily smoke-free Check-in und der wichtigeren Streak nun einen klaren Wiederkehrmechanismus hat.

Lokale Notifications sind dafür ein sinnvoller V1-Baustein, wenn sie:

- fokussiert bleiben
- den Daily Loop stützen
- fair und hochwertig kommuniziert werden
- nicht in zu viele Typen oder Regeln ausufern

## Definition of Done

Ticket 21 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass V1 drei Notification-Typen enthält
- dass Daily Check-in Reminder Teil von V1 sind
- dass Streak on ice / recovery Reminder Teil von V1 sind
- dass Trial-Reminder Teil von V1 sind
- dass die Streak-Notification ausdrücklich die on-ice-Logik unterstützt
- dass die Permission früh im Onboarding gefragt wird
- dass V1 globale Notifications und Daily Reminder separat steuerbar macht
- dass Notifications ruhig, hilfreich und nicht aggressiv klingen sollen

———————————————————

# Ticket 22 – Onboarding-Finish verbessern

## Ergebnis

Der Abschluss des Onboardings von **ayo** soll deutlich intelligenter, glaubwürdiger und personalisierter wirken.

Insbesondere der Screen zur Plan-Erstellung soll nicht mehr wie ein einfacher linearer Fortschrittsbalken wirken, sondern wie ein kurzer, bewusst inszenierter Verarbeitungsprozess, bei dem aus den Antworten des Nutzers tatsächlich ein individueller Plan abgeleitet wird.

## Strategische Entscheidung

Der Plan-Erstellungs-Screen soll in V1 den Eindruck vermitteln, dass:

- Antworten verarbeitet werden
- Muster erkannt werden
- ein personalisierter Support-Ansatz entsteht
- über den Nutzer ernsthaft „nachgedacht“ wurde

Er soll nicht technisch oder übertrieben wirken, sondern hochwertig, ruhig und glaubwürdig.

## Rolle des Plan-Erstellungs-Screens

Der Screen dient nicht nur als Übergangs-Loader, sondern als psychologisch wichtiger Abschluss des Onboardings.

Seine Aufgabe ist:

- dem Nutzer das Gefühl zu geben, dass sein Input relevant war
- den personalisierten Plan wertiger erscheinen zu lassen
- den Übergang zur Monetization logischer zu machen
- das Produkt intelligenter und durchdachter wirken zu lassen

## Fortschrittslogik

Der Fortschritt soll **nicht mehr einfach gleichmäßig von 0 auf 100 laufen**.

### Entscheidung
Der Screen soll in **mehreren Phasen / Steps** arbeiten, ähnlich wie ein intelligenter System- oder KI-gestützter Verarbeitungsprozess.

Das bedeutet:

- Fortschritt steigt nicht linear
- verschiedene Phasen laufen in unterschiedlichem Tempo
- es entsteht das Gefühl, dass Teilaufgaben nacheinander abgearbeitet werden
- der Nutzer sieht, dass „etwas passiert“

## Wahrnehmung des Prozesses

Der Screen soll bewusst so gestaltet werden, dass er wirkt wie:

- Auswertung der Antworten
- Erkennen von Gewohnheiten / Mustern
- Ableiten eines passenden Support-Starts
- Zusammenstellen eines persönlichen Programms

Wichtig ist dabei:
- es soll **wenig echte Details** preisgeben
- aber deutlich vermitteln, dass etwas Personalisiertes erstellt wurde

## Personalisierungsgefühl

Die Wirkung des Onboarding-Finishs soll eine **Mischung aus emotional und funktional** sein.

### Entscheidung
Der Nutzer soll klar spüren:

- etwas Persönliches wurde erstellt
- die App hat seine Antworten ernst genommen
- jetzt beginnt ein individueller Support-Weg

Es soll also nicht nur warm oder motivierend wirken, sondern auch intelligent und konkret genug, um glaubwürdig zu sein.

## Übergang zur Paywall / zum nächsten Schritt

Der Übergang vom Plan-Erstellungs-Screen in den nächsten Monetization-/Plan-Screen soll:

- ruhig
- hochwertig
- conversion-fähig
- nicht mechanisch

sein.

### Entscheidung
Der Abschluss soll eine **Mischung aus ruhigem Flow und klarer Conversion-Logik** haben.

Das heißt:
- nicht hektisch oder zu pushy
- aber auch nicht zu weich oder folgenlos

## Ergebnisdarstellung nach dem Processing

Nach dem Processing soll der Nutzer das Gefühl haben:

- sein Plan ist fertig
- der Plan wurde wirklich aus seinen Antworten abgeleitet
- die nächsten Schritte bauen logisch darauf auf

### Entscheidung
Das Finish soll personalisierter und greifbarer wirken, aber **ohne zu viele konkrete Detailpunkte** auszubreiten.

Die App soll eher den Eindruck erzeugen:
- „wir haben dein Muster verstanden“
- „wir haben deinen Start vorbereitet“

statt eine große, komplizierte Detailauswertung anzuzeigen.

## UX-Richtung des Processing-Screens

Der Processing-Screen soll sich eher an intelligent wirkenden Step-/Analyse-Screens orientieren als an einfachen Standard-Loadings.

Wichtige Merkmale:

- Fortschritt in Etappen
- unterschiedliche Geschwindigkeiten
- sichtbare Teilprozesse / Substeps
- Gefühl von laufender Verarbeitung
- klare, hochwertige visuelle Ruhe

Er soll sich eher an einem „personalized program is being prepared“-Gefühl orientieren als an einem simplen Ladebalken.

## Was bewusst vermieden wird

- kein stumpfer linearer 0–100 Fortschritt
- kein generischer Loading-Screen ohne Persönlichkeit
- keine übertechnische Pseudo-KI-Inszenierung
- keine zu detaillierte Analyse-Ausgabe, die zu viel verspricht
- kein mechanischer oder billiger Übergang in die Paywall

## Begründung

Diese Entscheidung wurde getroffen, weil der Plan-Erstellungs-Screen einer der wichtigsten psychologischen Punkte im gesamten Funnel ist.

Wenn dieser Moment billig oder generisch wirkt, verliert der personalisierte Plan an Wert.

Wenn er dagegen intelligent, ruhig und glaubwürdig inszeniert wird, dann:

- wirkt der Plan persönlicher
- wirkt die App hochwertiger
- wird der Übergang in Premium logischer
- steigt die wahrgenommene Substanz des Produkts

## Definition of Done

Ticket 22 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass der Plan-Erstellungs-Screen intelligenter und personalisierter wirken soll
- dass der Fortschritt nicht linear, sondern in Phasen / Steps verlaufen soll
- dass der Nutzer das Gefühl bekommen soll, es wurde ernsthaft etwas Personalisiertes erstellt
- dass der Abschluss eine Mischung aus emotionalem und funktionalem Eindruck haben soll
- dass der Übergang zum nächsten Schritt ruhig, hochwertig und conversion-fähig bleiben soll
- dass die Personalisierung eher angedeutet als überdetailliert erklärt werden soll

———————————————————

# Ticket 23 – Notification-Permission-Screen sinnvoll platzieren und gestalten

## Ergebnis

Für **ayo** wird die Notification-Permission in V1 über einen bewusst gestalteten **Pre-Prompt** eingeführt, der den Wert der Erinnerungen erklärt, bevor das iOS-System-Popup erscheint.

Die Permission soll im Onboarding **nicht roh und ohne Kontext**, sondern als sinnvoller Teil des Support-Setups erscheinen.

## Strategische Entscheidung

Der Notification-Permission-Moment soll in ayo so wirken, als würde er den Nutzer beim Dranbleiben unterstützen — nicht als technischer Systemwunsch oder aggressiver Growth-Prompt.

Die Begründung für Notifications basiert in V1 primär auf:

- dem **daily smoke-free check-in**
- der täglichen Rückkehr
- dem Schutz der Streak als Verstärkung

## Kernlogik des Permission-Screens

Der Permission-Screen soll zuerst den **Daily Check-in** in den Vordergrund stellen.

### Entscheidung
Die Hauptbotschaft der Notification-Permission ist:

- den täglichen smoke-free check-in nicht zu verpassen

Die Streak ist dabei wichtig, aber eher **sekundäre Verstärkung**, nicht die primäre Hauptbegründung.

## Nutzerkontrolle

Der Nutzer soll die Möglichkeit haben, die Notification-Permission **noch nicht** zu aktivieren.

### Entscheidung
Der Pre-Prompt enthält eine faire sekundäre Option wie z. B.:

- **Not now**

Ziel:
- weniger Druck
- höherwertiger Eindruck
- mehr Vertrauen
- weniger erzwungene Permission-Dynamik

## Platzierung im Onboarding

Der Notification-Permission-Screen wird im Onboarding-Finish-Bereich platziert.

### Entscheidung
Er erscheint:

- **nach dem Plan-Processing / Plan-Ready-Moment**
- aber **vor Trial-/Paywall-Finish**

Damit liegt der Screen noch im Onboarding, aber erst an einer Stelle, an der der Nutzer den Wert des Produkts schon besser versteht.

## UX-Ablauf

Der gewünschte Ablauf ist:

### 1. Ayo Pre-Prompt
Ein ruhig gestalteter Screen erklärt den Nutzen von Erinnerungen.

### 2. iOS System Permission
Nur wenn der Nutzer zustimmt, wird die native iOS-Permission angefragt.

### 3. Danach
- bei Zustimmung: normaler Weiterfluss
- bei Ablehnung: kein Drama, normal weiter

## Verhalten bei Ablehnung

Wenn der Nutzer Notifications zunächst ablehnt, wird der Flow **nicht blockiert**.

### Entscheidung
Die App geht ruhig weiter.

Zusätzlich soll die App den Permission-Wunsch **später bei einem nächsten passenden Check-in-Moment erneut aufgreifen können**.

Wichtig:
- nicht aggressiv
- nicht sofort wieder
- sondern in einem sinnvollen späteren Kontext

Außerdem bleibt die Notification-Steuerung natürlich über Settings erreichbar.

## Tonalität

Der Pre-Prompt soll:

- ruhig
- klar
- knapp
- produktnah
- hilfreich

sein.

Nicht gewünscht:
- technische Formulierungen
- manipulative Sprache
- übertriebene Dringlichkeit
- generisches „stay updated“

## Inhaltliche Richtung

Der Permission-Screen soll inhaltlich ungefähr diese Logik vermitteln:

- bleib bei deinem täglichen Check-in dran
- verpasse deinen smoke-free Moment nicht
- lass dich im richtigen Moment erinnern

Die Streak kann dabei als zusätzliche Verstärkung erscheinen, aber nicht als alleinige Hauptbegründung.

## Was bewusst vermieden wird

- kein rohes iOS-Popup ohne Pre-Prompt
- keine zu frühe Permission-Anfrage mitten in einem noch unklaren Onboarding
- keine aggressive Überredung bei Ablehnung
- keine technische oder generische Notification-Kommunikation
- keine Push-Mechanik ohne erkennbaren Daily-Loop-Bezug

## Begründung

Diese Entscheidung wurde getroffen, weil Notifications in ayo den Daily Loop unterstützen sollen — nicht einfach nur Aktivität erzeugen.

Die Notification-Permission ist dann am stärksten, wenn der Nutzer schon verstanden hat:

- dass tägliches Dranbleiben wichtig ist
- dass der Check-in eine zentrale Handlung ist
- dass Erinnerungen ihm dabei konkret helfen können

Der Platz nach dem Plan-/Processing-Moment ist dafür der beste Kompromiss aus frühem Funnel-Einbau und bereits verständlichem Produktwert.

## Definition of Done

Ticket 23 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ein Ayo Pre-Prompt vor dem iOS-Popup verwendet wird
- dass der Daily Check-in die Hauptbegründung für Notifications ist
- dass die Streak nur sekundär verstärkt
- dass der Nutzer „Not now“ wählen kann
- dass der Screen nach Plan-Processing / Plan-Ready und vor Trial-/Paywall-Finish erscheint
- dass Ablehnung den Flow nicht blockiert
- dass die App bei einem späteren passenden Check-in-Moment erneut fragen darf
- dass die Notification-Kommunikation ruhig und wertorientiert bleiben soll

———————————————————

# Ticket 24 – Trial-Reminder und Notification-Copy festlegen

## Ergebnis

Für **ayo** wird eine klare Notification-Copy-Richtung festgelegt, die ruhig, hochwertig und markenkonform bleibt, aber in den richtigen Momenten auch etwas antreibender wirken darf.

Die Notifications sollen nicht generisch, technisch oder spammy klingen, sondern wie ein echter Bestandteil des Produkts.

## Strategische Entscheidung

Die Notification-Sprache von ayo ist eine **Mischung aus ruhiger, menschlicher Unterstützung und leicht coachender Energie**.

Das bedeutet:

- nicht kalt oder nur sachlich
- nicht übertrieben motivierend oder künstlich
- nicht aggressiv pushy
- aber auch nicht zu weich oder folgenlos

Die App darf in Notifications etwas Zug und Momentum haben, solange sie nicht in Druck, Schuld oder billige Growth-Sprache kippt.

## Grundton der Notification-Copy

Die Notification-Copy soll:

- kurz
- ruhig
- konkret
- leicht aktivierend
- hochwertig
- modern

sein.

### Nicht gewünscht
- manipulative Verlustsprache
- generische „stay updated“-Texte
- salesige Push-Copy
- übertriebene Motivationssprüche
- technische Formulierungen

## Daily Reminder

Der Daily Reminder soll direkt an die zentrale Hauptaktion von Home gekoppelt sein.

### Entscheidung
Die bevorzugte Richtung für den Daily Reminder ist:

**Mark today as smoke-free**

Diese Formulierung ist in V1 die stärkste, weil sie direkt mit der täglichen Kernhandlung von ayo übereinstimmt.

### Ziel
- tägliche Rückkehr stärken
- klare Handlung auslösen
- Produktlogik sauber spiegeln

## Streak-on-ice Reminder

Die Streak-Reminder sollen den intelligenteren Streak-Ansatz von ayo unterstützen.

### Entscheidung
Der Begriff **“on ice”** wird direkt verwendet.

Damit kann die App einen klaren, eigenen Status kommunizieren, der weder brutal noch belanglos wirkt.

### Ziel
- Nutzer ruhig zurückholen
- Streak-Rettung statt harter Bestrafung
- markanter Produktbegriff mit Wiedererkennungswert

## Trial Reminder

Der Trial Reminder soll eine **Mischung aus Klarheit und Wertbezug** sein, mit **Schwerpunkt auf Klarheit**.

### Entscheidung
Der Reminder soll primär klar machen, dass der Trial endet, und sekundär den Wert des Supports / Plans mitschwingen lassen.

Ziel:
- fairer Hinweis
- nicht billig oder druckvoll
- kein aggressiver Sales-Ton

## Inhaltliche Richtungen

### Daily Reminder
Die Notification soll in Richtung der zentralen Handlung formuliert sein, z. B.:

- Mark today as smoke-free

### Streak-on-ice Reminder
Die Notification soll ruhig, aber aktivierend sein und den On-ice-Zustand klar benennen.

Sie soll signalisieren:
- dein Fortschritt ist noch rettbar
- du kannst zurückkommen
- es ist noch nicht verloren

### Trial Reminder
Die Notification soll klar, fair und ruhig sein und ungefähr diese Logik transportieren:

- dein Trial endet bald
- prüfe deinen Support / Plan rechtzeitig
- behalte den Wert deines Setups im Blick

## Copy-Stilregel für V1

Jede Notification-Copy soll intern gegen diese Fragen geprüft werden:

- ist sie kurz genug?
- ist sie markenkonform?
- klingt sie ruhig, aber nicht kraftlos?
- klingt sie leicht aktivierend, aber nicht pushy?
- vermeidet sie Schuld, Druck und billige Sales-Sprache?

## Was bewusst vermieden wird

- keine billige Trial-Urgency à la „last chance“
- keine überharten Streak-Verlust-Botschaften
- keine generischen Daily Reminder ohne klare Handlung
- keine zu weiche Sprache ohne Zug
- keine Motivations- oder Sales-Copy, die nicht zu ayo passt

## Begründung

Diese Entscheidung wurde getroffen, weil Notifications bei ayo gleichzeitig:

- Daily Loop
- Streak-Rettung
- Trial-Fairness
- Markenwahrnehmung

beeinflussen.

Die richtige Lösung ist deshalb eine Sprache, die nicht rein sachlich bleibt, aber auch nicht in manipulative App-Growth-Muster kippt.

## Definition of Done

Ticket 24 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die Notification-Copy eine Mischung aus ruhiger Unterstützung und leicht coachender Energie sein soll
- dass Trial-Reminder Klarheit mit leichtem Wertbezug kombinieren, mit Schwerpunkt auf Klarheit
- dass der Daily Reminder auf „Mark today as smoke-free“ ausgerichtet wird
- dass der Begriff „on ice“ direkt für den Streak-Reminder verwendet wird
- dass Notification-Copy kurz, hochwertig und nicht pushy sein soll

———————————————————

# Ticket 25 – Progress stärker an Check-ins koppeln

## Ergebnis

Der Progress-Bereich von **ayo** wird stärker an den täglichen smoke-free Check-ins ausgerichtet, damit Progress nicht nur aus statischen Kennzahlen besteht, sondern das tatsächliche Dranbleiben des Nutzers sichtbar macht.

## Strategische Entscheidung

Progress soll in ayo künftig stärker zeigen:

- wie konsistent der Nutzer drangeblieben ist
- an welchen Tagen er eingecheckt hat
- wie sich seine Streak entwickelt
- ob seine Kontinuität aktiv, on ice oder wieder stabilisiert ist

Progress soll dadurch spürbarer, lebendiger und bedeutungsvoller werden.

## Grundausrichtung des Progress-Bereichs

Die Progress-Seite soll **primär als Verlaufserlebnis** funktionieren, aber **sekundär weiterhin Dashboard-Elemente** enthalten.

### Entscheidung
Progress ist also:

- **mehr Verlauf / Kontinuität**
- aber **nicht ohne Statistik-/Dashboard-Aspekte**

Das bedeutet:
- nicht nur isolierte Zahlenblöcke
- aber auch nicht ausschließlich Timeline ohne Kennzahlen

## Rolle der Check-ins

Die täglichen smoke-free Check-ins werden ein zentraler Bestandteil des Progress-Bereichs.

### Entscheidung
Die Check-in-Historie soll im Progress **klar sichtbar** sein und nicht nur im Hintergrund existieren.

Ziel:
- der Nutzer sieht sein tatsächliches Dranbleiben
- tägliche Bestätigungen fühlen sich relevant an
- Progress wird zu einem Beweis von Kontinuität, nicht nur zu einem Zahlen-Screen

## Rolle von „on ice“

Der Streak-Zustand **on ice** soll auch im Progress sichtbar werden.

### Entscheidung
„On ice“ wird jedoch **nicht als riesiges eigenes Hauptmodul**, sondern eher als **integrierter Aspekt innerhalb anderer Progress-Elemente** gedacht.

Das kann z. B. in folgende Bereiche einfließen:

- Streak-Status
- Check-in-Verlauf
- Konsistenzdarstellung
- Verlauf / Recovery-Signale

Ziel:
- realistischer Fortschritt
- intelligenter Streak-Verlauf
- kein überladener Sonderstatus-Bereich

## Gewichtung der Progress-Bestandteile

Im Progress-Bereich sollen Check-ins und Kontinuität künftig wichtiger werden als rein passive Zahlen wie „money saved“.

### Entscheidung
Check-ins / Verlauf / Konsistenz haben künftig mehr strategisches Gewicht als money saved.

Money saved bleibt relevant, ist aber nicht mehr der stärkste Bedeutungsträger im Progress.

## Struktur des Progress-Bereichs

Der Progress-Bereich soll künftig stärker folgende Ebenen kombinieren:

### 1. Kernwerte
- nicotine-free days
- money saved
- ggf. weitere Basismetriken

### 2. Check-in-Verlauf
- sichtbare Bestätigungstage
- Kontinuität
- Dranbleiben über Zeit

### 3. Streak-Zustand
- active
- on ice
- maintained / recovered

### 4. Premium-Tiefe
- mehr Verlauf
- tiefere Muster
- stärkere Auswertung
- reichere History-Ansichten

## Free vs Premium

Der Progress-Bereich bleibt auch hier in derselben Grundstruktur erkennbar, wird aber in Premium deutlich tiefer.

### Free
- Basis-Metriken
- einfache Kontinuitätsanzeige
- grundlegender Check-in-Bezug

### Premium
- tiefere History
- stärkere Mustererkennung
- richer progress cards
- klarere Auswertung von Verhalten und Konsistenz

## Was bewusst vermieden wird

- kein rein statischer Zahlen-Screen
- keine Progress-Logik, die Check-ins nur im Hintergrund nutzt
- kein Progress, der nur wie ein Sparrechner wirkt
- kein übergroßes separates On-ice-Modul, das den Bereich aufbläht
- kein Verlust des Dashboard-Charakters komplett zugunsten einer reinen Timeline

## Begründung

Diese Entscheidung wurde getroffen, weil der Daily Loop von ayo nun auf dem täglichen smoke-free Check-in basiert.

Wenn dieser Check-in im Progress nicht sichtbar und bedeutungsvoll wird, verliert er einen Teil seiner psychologischen Kraft.

Progress soll deshalb künftig stärker zeigen:

- dass der Nutzer wirklich da war
- dass er drangeblieben ist
- dass seine Kontinuität sichtbar ist
- dass auch Recovery und On-ice-Zustände Teil eines realistischen Verlaufs sind

## Definition of Done

Ticket 25 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass Progress stärker an Check-ins gekoppelt wird
- dass Progress primär Verlauf, aber weiterhin auch Dashboard sein soll
- dass die Check-in-Historie ein zentraler Bestandteil des Progress wird
- dass on ice im Progress sichtbar sein soll, aber eher integriert als Nebenaspekt
- dass Check-ins und Kontinuität wichtiger werden als money saved
- dass Free und Premium dieselbe Grundlogik teilen, Premium aber deutlich tiefer wird

———————————————————

# Ticket 26 – Streak-System und On-Ice-Logik final definieren

## Ergebnis

Für **ayo** wird ein intelligenteres Streak-System definiert, das nicht sofort hart bestraft, wenn ein täglicher Check-in ausbleibt.

Die Streak soll motivieren, Rückkehr fördern und den Nutzer stärker an den Daily Loop binden, ohne sich wie ein toxisches oder unnötig brutales Standard-Streak-System anzufühlen.

## Strategische Entscheidung

Die Streak ist in ayo ein zentraler Wiederkehrmechanismus und soll:

- sichtbar wichtig sein
- Dranbleiben verstärken
- Rückkehr fördern
- nicht sofort brutal brechen
- psychologisch eher motivierend als bestrafend wirken

## Finale Streak-Zustände

Die Streak kennt in V1 drei Zustände:

- **active**
- **on ice**
- **lost**

### Bedeutung
- **active** = der Nutzer ist im normalen aktiven Streak-Verlauf
- **on ice** = der Check-in wurde verpasst, die Streak ist gefährdet, aber noch rettbar
- **lost** = die Rettungsphase wurde verpasst, die Streak ist wirklich gebrochen

## On-Ice-Logik

Wenn ein täglicher smoke-free Check-in ausbleibt, soll die Streak **nicht sofort verloren gehen**.

### Entscheidung
Die Streak geht zunächst in den Zustand:

- **on ice**

Damit bekommt der Nutzer eine echte Rückkehrchance.

## Dauer der Rettungsphase

Die Rettungsphase der Streak soll in V1 **weicher / länger** sein und nicht zu kurz ausfallen.

### Entscheidung
Die On-Ice-Phase bleibt bewusst länger und großzügiger, damit die Streak nicht zu hart wirkt.

Ziel:
- weniger unnötige Frustration
- stärkere Rückkehrchance
- bessere Balance aus Verbindlichkeit und Fairness

Die genaue technische Länge kann in der Umsetzung konkretisiert werden, aber die Produktregel lautet:

- On-Ice soll **spürbar rettbar**
- aber nicht grenzenlos offen
sein.

## Rettung der Streak

Die Streak soll in V1 **ohne komplizierte Sondermechanik** gerettet werden können.

### Entscheidung
Der Nutzer rettet seine Streak einfach durch:

- den nächsten smoke-free Check-in

Es wird in V1 **keine spezielle Save-Streak-Aktion** als eigener Mini-Flow eingeführt.

## Sichtbarkeit von „on ice“

Der Zustand **on ice** soll in der App klar sichtbar sein.

### Entscheidung
On-Ice soll in folgenden Bereichen sichtbar werden:

- Home
- Progress
- Notifications

Es handelt sich also nicht um einen rein versteckten Hintergrundstatus.

## Visuelle / emotionale Wirkung von „on ice“

Der On-Ice-Zustand soll sich deutlich anders anfühlen als eine normale aktive Streak, aber **noch nicht wie endgültiger Verlust**.

### Entscheidung
On-Ice soll wirken wie:

- **klar gefährdet**
- **aber noch rettbar**
- **nicht tot**
- **aber auch nicht völlig normal**

Das ist die gewünschte emotionale Positionierung des Zustands.

## Rolle der Streak im Produkt

Die Streak bleibt ein wichtiger Teil des Daily Loops, aber nicht als aggressives Bestrafungssystem.

Sie soll:

- Rückkehr motivieren
- tägliche Bestätigung aufladen
- Check-ins bedeutungsvoller machen
- Progress emotional verstärken

## Zusammenhang mit Notifications

Die On-Ice-Logik soll direkt durch Notifications unterstützt werden.

Das bedeutet:
- verpasster Check-in führt nicht sofort zu Verlust
- Nutzer kann per Notification zurückgeholt werden
- die App kommuniziert, dass der Fortschritt noch gerettet werden kann

## Zusammenhang mit Progress

Der On-Ice-Zustand soll auch im Progress sichtbar werden, aber eher integriert und nicht als riesiger Sonderbereich.

Er kann z. B. in:
- Streak-Status
- Kontinuitätsdarstellung
- Verlauf / Check-in-Historie

einfließen.

## Was bewusst vermieden wird

- keine sofort brutal gebrochene Streak bei einem verpassten Check-in
- kein rein dekoratives Streak-Label ohne Konsequenz
- kein kompliziertes Save-Streak-Minispiel in V1
- kein unsichtbarer On-Ice-Zustand, den Nutzer nicht verstehen
- keine völlig folgenlose Streak ohne Verbindlichkeit

## Begründung

Diese Entscheidung wurde getroffen, weil klassische Streak-Systeme oft unnötig hart und demotivierend sind.

Ayo braucht stattdessen ein System, das:

- den Daily Loop stärkt
- Rückkehr fördert
- psychologisch fairer wirkt
- trotzdem Konsequenz und Kontinuität spürbar macht

Die On-Ice-Logik ist dafür die passende Balance.

## Definition of Done

Ticket 26 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die Streak die Zustände active / on ice / lost kennt
- dass ein verpasster Check-in nicht sofort zum Verlust führt
- dass die On-Ice-Phase bewusst weicher / länger sein soll
- dass die Streak durch den nächsten smoke-free Check-in gerettet werden kann
- dass on ice in Home, Progress und Notifications sichtbar wird
- dass on ice sich klar gefährdet, aber noch rettbar anfühlen soll
- dass V1 kein kompliziertes Save-Streak-Sondersystem braucht


———————————————————


# Ticket 27 – Goal-/Belohnungssystem als Future Direction sauber abgrenzen

## Ergebnis

Für **ayo** wird ein zukünftiges **Goal-/Reward-System mit möglicher Assistant-Erweiterung** als dokumentierte Produkt-Richtung festgehalten.

Dieses System ist **ausdrücklich nicht Teil von V1** und soll aktuell **nicht umgesetzt**, sondern nur sauber als spätere Ausbauidee dokumentiert werden.

## Strategische Entscheidung

Die Idee wird als späteres Produkt-Cluster verstanden, das drei Ebenen verbinden kann:

- **Goal-System**
- **Reward-System**
- **später möglicher Assistant-/AI-Layer**

Damit soll ayo langfristig nicht nur auf Check-ins, Streaks und Progress basieren, sondern zusätzlich einen persönlicheren Motivationsanker bekommen.

## Kernidee

Der Nutzer arbeitet nicht nur abstrakt auf „mehr rauchfreie Tage“ hin, sondern auf etwas Konkretes, z. B.:

- ein persönliches Ziel
- eine Belohnung
- einen greifbaren Motivationsanker

Beispielhafte Richtung:
- „Worauf arbeitest du hin?“
- „Wie willst du dich belohnen?“
- „Was möchtest du dir nach einer bestimmten rauchfreien Zeit ermöglichen?“

## Produktlogik der Future Direction

Die spätere Logik dieses Systems könnte so aussehen:

### 1. Ziel / Belohnung festlegen
Der Nutzer definiert ein persönliches Ziel oder eine Belohnung.

### 2. Ayo unterstützt die Zielgröße
Die App oder ein späterer Assistant-/AI-Layer könnte eine sinnvolle Mindestdauer oder Zielmarke vorschlagen.

### 3. Daily Loop wird daran gekoppelt
Jeder tägliche smoke-free Check-in bringt den Nutzer sichtbar näher an sein Ziel.

### 4. Assistant-/Coach-Layer
In einer späteren Ausbaustufe könnte ein intelligenter Assistant:
- an das Ziel erinnern
- motivierende, aber konkrete Hinweise geben
- Zwischenetappen oder sinnvolle Zeiträume unterstützen

## Positionierung dieser Idee

Die Future Direction wird nicht nur als „Belohnungsfeature“, sondern breiter als:

**Goal + Reward + später Assistant-Layer**

verstanden.

Das ist die bewusst gesetzte Richtung.

## Rolle im Produkt

Diese spätere Idee soll langfristig:

- den Daily Loop emotional aufladen
- Check-ins bedeutungsvoller machen
- Streak und Progress persönlicher machen
- eine motivierende Zukunftsperspektive ergänzen
- über generische Motivation hinausgehen

## Emotionale vs funktionale Ausrichtung

Die spätere Umsetzung soll eine **Mischung aus emotionalem Motivationsanker und funktionalem Zielsystem** sein.

### Entscheidung
- nicht nur verspielt oder emotional
- nicht nur wie ein trockenes Ziel-Tool
- sondern emotional zugänglich mit klarer funktionaler Logik

## Rolle eines späteren Assistant-/AI-Layers

Die Assistant-/AI-Idee soll ausdrücklich als mögliche spätere Richtung dokumentiert werden.

### Mögliche spätere Aufgaben des Assistant-Layers
- sinnvolle Zielmarken vorschlagen
- an persönliche Belohnungen erinnern
- Motivation konkreter machen
- helfen, das Ziel mit dem Daily Loop zu verknüpfen

Wichtig:
Diese Idee ist aktuell **nur dokumentiert**, nicht umgesetzt.

## Klare Abgrenzung zu V1

Dieses gesamte System ist **nicht Teil von V1**.

### Entscheidung
Für den aktuellen Produktstand gilt ausdrücklich:

- keine Umsetzung jetzt
- keine teilweise Vorab-Umsetzung
- keine versteckte Mini-Version in V1
- keine zusätzliche Scope-Ausweitung im aktuellen Build

Es wird ausschließlich als **klare Dokumentation für spätere Produktentwicklung** festgehalten.

## Was bewusst vermieden wird

- keine aktuelle Umsetzung im V1-Release
- keine Vermischung mit dem bestehenden Daily Loop in der aktuellen Build-Phase
- keine Scope-Ausweitung durch zu frühes Future-Feature-Bauen
- keine halbfertige Mini-Version dieses Systems
- keine unklare Vermarktung, als wäre es schon Teil der jetzigen App

## Begründung

Diese Entscheidung wurde getroffen, weil die Idee produktstrategisch stark ist, aber aktuell noch:

- nicht final UX-definiert
- nicht final logisch ausgearbeitet
- nicht sinnvoll in V1-Scope integrierbar

Für ayo ist es klüger, zuerst den Kern sauber zu bauen:

- Daily check-in
- Streak
- Progress
- Rescue
- Notifications
- Premium-System

Das Goal-/Reward-/Assistant-System bleibt deshalb bewusst eine **spätere, dokumentierte Ausbau-Richtung**.

## Definition of Done

Ticket 27 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ein zukünftiges Goal-/Reward-System dokumentiert wird
- dass dieses später mit einem Assistant-/AI-Layer verbunden werden könnte
- dass die Idee als Mischung aus emotionalem Motivationsanker und funktionalem Zielsystem verstanden wird
- dass diese Richtung ausdrücklich nur dokumentiert und nicht jetzt umgesetzt wird
- dass keine teilweise Umsetzung in V1 erfolgen soll

———————————————————

# Ticket 28 – App-Store-Positionierung finalisieren

## Ergebnis

Für **ayo** wird eine klare App-Store-Positionierung festgelegt, die die App als Quit-Nicotine-Produkt mit täglicher Begleitung und sichtbarem Fortschritt darstellt.

Die Außenpositionierung soll klar verständlich, marktfähig und differenziert sein, ohne ayo auf einen reinen Tracker oder eine reine Wellness-App zu reduzieren.

## Strategische Entscheidung

Im App Store wird ayo primär als App zum **Quitten von Nikotin** positioniert.

Cravings bleiben ein wichtiger Bestandteil des Produkts, sind aber in der Außenkommunikation **nicht der erste Einstiegspunkt**, sondern ein starker Unterstützungsaspekt innerhalb des Gesamtversprechens.

## Kernpositionierung für den Store

Die App-Store-Positionierung von ayo soll folgende Logik transportieren:

- **quit nicotine** ist das Hauptziel
- **daily smoke-free check-ins** sind Teil des täglichen Systems
- **real progress** ist sichtbar und motivierend
- **craving support** ist ein wichtiger Unterstützungsbereich, aber nicht die alleinige Hauptüberschrift des Produkts

## Finaler Positionierungsrahmen

Ayo soll im Store nicht wie eines der folgenden Dinge wirken:

- reiner Quit-Tracker
- reine Wellness-App
- medizinische Behandlungs-App
- generisches Habit Tool

Stattdessen soll ayo wie ein fokussiertes, modernes Support-Produkt erscheinen, das hilft:

- mit Nikotin aufzuhören
- täglich dranzubleiben
- Fortschritt sichtbar zu machen
- auch schwierige Momente besser zu bewältigen

## Gewichtung der Kernpfeiler

Für die App-Store-Außenwirkung werden diese inhaltlichen Schwerpunkte gesetzt:

### 1. Quit nicotine
Das Kernziel der App ist klar und direkt.

### 2. Daily smoke-free check-ins
Der Daily Loop ist Teil der Außenpositionierung und nicht nur interne Produktmechanik.

### 3. Real progress
Sichtbarer Fortschritt ist ein zentraler Produktwert und soll auch im Store klar vorkommen.

### 4. Craving support
Craving support bleibt Teil der Positionierung, aber eher als unterstützender Differenzierungsaspekt innerhalb des Gesamtprodukts.

## Sprachentscheidung

Im App Store soll sprachlich klar **„quit nicotine“** dominieren, nicht primär „smoke-free“.

### Begründung
„Quit nicotine“ ist breiter, verständlicher und besser passend für das Gesamtprodukt, besonders auch im Hinblick auf unterschiedliche Nikotin-Nutzungsformen.

## Rolle von Daily Check-ins

Daily smoke-free check-ins sollen in der Store-Positionierung ausdrücklich vorkommen.

### Entscheidung
Daily check-ins sind nicht nur ein internes Produktdetail, sondern ein echter Teil des Produktversprechens.

Sie tragen:
- Wiederkehr
- Struktur
- Daily Loop
- wahrnehmbaren Nutzen

## Rolle von Progress

Progress soll im Store als sichtbarer, echter Fortschritt vorkommen.

### Entscheidung
„Real progress“ bzw. sichtbarer Fortschritt gehört klar zur Außenpositionierung von ayo.

Ziel:
- App nicht nur wie Motivation, sondern wie ein greifbares System wirken lassen
- Tracking und Fortschritt emotional und funktional aufladen

## Rolle von Cravings

Craving support bleibt ein wichtiger inhaltlicher Bestandteil, wird aber im Store **nicht als alleiniger Haupteinstieg** verwendet.

### Entscheidung
Die App soll eher so wirken:

- quitting nicotine ist das Hauptversprechen
- craving support ist ein zentraler Teil, wie ayo dabei hilft

## Was bewusst vermieden wird

- keine zu breite oder generische Positionierung
- keine Reduktion auf reines Tracking
- keine Store-Wirkung wie eine reine Wellness- oder Meditations-App
- keine medizinische oder therapeutische Außenpositionierung
- kein zu enger Fokus nur auf Cravings, der Daily Loop und Progress verdrängt

## Begründung

Diese Entscheidung wurde getroffen, weil ayo im Store klar als Produkt zum Aufhören mit Nikotin verstanden werden soll.

Gleichzeitig sollen die Dinge sichtbar werden, die das Produkt stärker machen als einen generischen Tracker:

- tägliche Check-ins
- echte Fortschrittswahrnehmung
- Unterstützung bei Cravings
- strukturierte Begleitung

Der Store-Fokus startet deshalb bei **quit nicotine**, nicht bei **cravings**, aber integriert Craving-Support als wichtigen Teil des Systems.

## Definition of Done

Ticket 28 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ayo im Store primär als Quit-Nicotine-App positioniert wird
- dass Daily smoke-free check-ins Teil der Außenpositionierung sind
- dass real progress ein klarer Store-Pfeiler ist
- dass craving support Teil der Positionierung bleibt, aber nicht allein dominierend ist
- dass im Store sprachlich „quit nicotine“ stärker als „smoke-free“ gewichtet wird
- dass ayo nicht wie reine Wellness-, Tracking- oder Medical-App wirken soll


———————————————————

# Ticket 29 – App Store Screenshots planen

## Ergebnis

Für **ayo** wird eine klare Screenshot-Story für den App Store festgelegt, die das Produkt als modernes Quit-Nicotine-Support-System zeigt und nicht wie einen generischen Tracker, eine Wellness-App oder eine laute Self-Help-App wirken lässt.

Die Screenshots sollen nicht einfach einzelne Features zeigen, sondern in einer klaren Reihenfolge erklären, was ayo ist und warum es wertvoll ist.

## Strategische Entscheidung

Die App-Store-Screenshots von ayo sollen eine **Mischung aus funktionaler Klarheit und emotionaler Wirkung** haben.

Das bedeutet:

- klar verständlich
- visuell ruhig
- modern
- hochwertig
- mit starker Headline pro Screen
- aber nicht überladen, laut oder billig

Ayo soll sich damit bewusst von Konkurrenz-Screenshots abheben, die oft:

- zu laut
- zu generisch
- zu tracker-lastig
- zu health-claim-heavy
- oder zu verspielt / billig gamifiziert

wirken.

## Grundregel für die Screenshot-Story

Jeder Screenshot soll:

- genau **eine Hauptbotschaft**
- eine große klare Headline
- eine unterstützende UI-Visualisierung
- eine starke, leicht erfassbare Nutzenebene

haben.

Die UI dient als **Beweis** für die Headline, nicht als überladene Featurewand.

## Anzahl der Hauptscreenshots

Für V1 wird eine Kernstory mit **6 Hauptscreenshots** festgelegt.

Diese Anzahl ist groß genug, um eine vollständige Geschichte zu erzählen, ohne die Store-Präsentation unnötig breit oder unklar zu machen.

## Screenshot-Storyline für ayo

### Screenshot 1 – Hauptversprechen
**Quit nicotine with daily support**

Ziel:
- sofort klar machen, worum es bei ayo geht
- das Hauptziel des Produkts sichtbar machen
- ayo nicht wie einen beliebigen Tracker erscheinen lassen

### Screenshot 2 – tägliche Hauptaktion
**Mark each day smoke-free**

Ziel:
- den Daily Loop sichtbar machen
- den täglichen Check-in als Kernhandlung des Produkts zeigen
- ayo als aktives Dranbleib-System positionieren

### Screenshot 3 – sichtbarer Fortschritt
**See real progress build over time**

Ziel:
- Fortschritt nicht nur als Zahl, sondern als sichtbaren Verlauf zeigen
- Streak, Check-ins und Konsistenz spürbar machen
- ayo vom reinen Spar- oder Zahlenrechner abheben

### Screenshot 4 – Craving Support
**Get support when cravings hit**

Ziel:
- Rescue / Craving-Support als starken Differenzierer zeigen
- klar machen, dass ayo auch in schwierigen Momenten hilft
- diesen Bereich sichtbar machen, ohne ihn zur einzigen Hauptstory zu machen

### Screenshot 5 – Streak / Kontinuität
**Protect your streak and stay on track**

Ziel:
- Streak als Wiederkehrmechanismus zeigen
- Dranbleiben, Kontinuität und Rückkehr verstärken
- die intelligentere Streak-Logik von ayo andeuten

### Screenshot 6 – volle Systemtiefe
**Unlock the full support system**

Ziel:
- Premium-/Systemtiefe andeuten
- zeigen, dass ayo mehr als nur ein Basistracker ist
- den Eindruck eines größeren, hochwertigeren Support-Systems erzeugen

Dieser Screenshot soll **subtil** wirken und nicht wie ein reiner Paywall-/Sales-Screen.

## Rolle des Daily Check-ins

Der tägliche smoke-free Check-in ist so wichtig, dass er bereits in Screenshot 2 sichtbar werden soll.

### Entscheidung
Daily Check-in ist Teil der Store-Story und nicht nur ein internes Produktdetail.

Das unterstreicht:
- den Daily Loop
- die Wiederkehrlogik
- die Struktur der App
- den aktiven Charakter von ayo

## Rolle von Progress

Progress wird als eigener, starker Screenshot-Baustein behandelt.

### Entscheidung
Fortschritt soll als **real progress** erscheinen und nicht nur als:
- Sparwert
- Tageszähler
- statische Statistik

Gezeigt werden sollen eher:
- sichtbare Entwicklung
- Check-in-Kontinuität
- Streak-Logik
- tatsächliches Dranbleiben

## Rolle von Craving Support

Craving Support ist ein wichtiger Differenzierer und bekommt einen eigenen Screenshot, aber **nicht den ersten**.

### Entscheidung
Ayo wird im Store **nicht primär als Craving-App**, sondern als Quit-Nicotine-App mit täglicher Unterstützung und zusätzlichem Craving-Support gezeigt.

## Rolle von Premium / Full Support

Die tiefere Ebene des Produkts darf im letzten Screenshot angedeutet werden.

### Entscheidung
Ein letzter Screenshot darf klar machen, dass es ein **full support system** gibt, ohne plump wie ein Werbe-Sales-Screen zu wirken.

## Was von der Konkurrenz bewusst nicht übernommen wird

Die Screenshot-Strategie von ayo soll bewusst vermeiden:

- übertriebene „für immer“-Claims
- medizinische / pseudomedizinische Health-Claims
- zu viele Botschaften pro Screenshot
- billig wirkende Erfolgs- oder Gamification-Überladung
- Screenshots, die nur wie Statistik- oder Excel-Dashboards wirken
- zu schwere, textlastige Store-Kommunikation
- zu laute oder aggressive Konkurrenz-Ästhetik

## Was ayo besser machen soll als die Konkurrenz

Ayo soll im Store:

- ruhiger
- klarer
- hochwertiger
- strategischer
- weniger generisch
- weniger laut
- stärker daily-loop-orientiert

wirken.

Die Story soll nicht wie eine Featureliste aussehen, sondern wie ein bewusst aufgebautes Produktversprechen.

## Begründung

Diese Entscheidung wurde getroffen, weil Konkurrenz-Screenshots im Quit-/Habit-Bereich oft eines von drei Problemen haben:

- sie sind zu laut und billig
- sie sind zu generisch und austauschbar
- sie zeigen zwar Features, aber keine klare Produktstory

Ayo soll sich stattdessen durch eine klar geführte Store-Story differenzieren, die:

- quit nicotine als Hauptziel
- daily check-ins als Kernmechanik
- real progress als Beweis
- craving support als Differenzierer
- full support system als Tiefe

sichtbar macht.

## Definition of Done

Ticket 29 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die App-Store-Screenshots eine Mischung aus funktionaler Klarheit und emotionaler Wirkung haben sollen
- dass für V1 eine Story mit 6 Hauptscreenshots geplant wird
- dass Daily Check-in bereits Screenshot 2 wird
- dass Progress als sichtbarer echter Fortschritt Teil der Story ist
- dass Craving Support einen eigenen Screenshot bekommt, aber nicht die erste Hauptbotschaft ist
- dass ein letzter Screenshot die volle Systemtiefe / Premium-Ebene subtil andeuten darf
- dass ayo sich visuell und strategisch bewusst von lauter, generischer Konkurrenz absetzen soll

———————————————————

# Ticket 30 – App Store Listing Copy strukturieren

## Ergebnis

Für **ayo** wird eine klare Struktur für die App-Store-Listing-Copy festgelegt, die das Produkt verständlich, fokussiert und hochwertig darstellt, ohne in generische Marketing-Sprache oder reine Feature-Aufzählung abzurutschen.

## Strategische Entscheidung

Die Listing-Copy von ayo soll eine **Mischung aus Nutzenorientierung und ausgewählten starken Produktbestandteilen** sein.

Das bedeutet:

- nicht nur abstrakte Benefits
- nicht zu viele Features auf einmal
- klare, gut priorisierte Produktlogik
- hochwertiger, ruhiger Ton mit etwas Zug

## Kernlogik der Listing-Copy

Die Listing-Copy soll nach außen vor allem vermitteln:

- ayo hilft beim **Quitten von Nikotin**
- ayo funktioniert über **tägliche smoke-free check-ins**
- ayo macht **realen Fortschritt sichtbar**
- ayo unterstützt auch in **Craving-Momenten**
- ayo ist mehr als ein einfacher Tracker

## Priorisierte Botschaften

Die inhaltlichen Schwerpunkte der Listing-Copy sind in dieser Reihenfolge gedacht:

### 1. Quit nicotine
Das Hauptziel der App steht klar im Vordergrund.

### 2. Daily smoke-free check-ins
Der Daily Loop ist Teil des Kernversprechens und gehört sichtbar in die Listing-Copy.

### 3. Real progress
Fortschritt soll als echter, sichtbarer Produktwert erscheinen.

### 4. Craving support
Craving support bleibt ein wichtiger Produktteil, wird aber in der Listing-Copy nach dem Hauptziel und dem Daily Loop eingeordnet.

### 5. Stay on track / streak / consistency
Diese Aspekte können als Verstärkung vorkommen, müssen aber nicht die primäre erste Ebene dominieren.

## Rolle von Premium im Listing

Premium soll in der Listing-Copy für V1 **nicht aktiv hervorgehoben** werden.

### Entscheidung
Die Listing-Copy fokussiert sich auf das Produktversprechen und den Nutzen des Systems, nicht auf Premium-Tiefe oder Abo-Struktur.

Ziel:
- kein zu früher Monetization-Eindruck
- klare Nutzenkommunikation zuerst
- Premium bleibt eher im Produkt und über Screenshots / tiefere App-Erfahrung verständlich

## Einstieg der Description

Die Description soll mit der **Lösung / dem Nutzen** eröffnen, nicht mit einer Problem-Einleitung.

### Entscheidung
Die App-Store-Copy startet in der Logik:

- ayo helps you quit nicotine...

statt zuerst ein Problem-Setup wie:
- quitting nicotine is hard...

Ziel:
- stärkere, klarere Außenwirkung
- direkterer Nutzen
- weniger generisches Problem-Marketing

## Tonalität

Die Listing-Copy soll eine **Mischung aus ruhiger, hochwertiger Sprache und etwas markanterem Zug** haben.

### Entscheidung
Ayo soll im Listing nicht kalt oder zu sachlich klingen, aber auch nicht aggressiv, laut oder billig-marktschreierisch.

Die Tonalität soll daher sein:

- ruhig
- klar
- modern
- hochwertig
- leicht markant
- nicht überdreht

## Struktureller Aufbau des Listings

Die Listing-Copy soll grob auf vier Ebenen aufgebaut sein:

### 1. Core Promise
Ein klarer Eröffnungssatz, der das Produkt unmittelbar verständlich macht.

### 2. Main Benefits
Die wichtigsten Wirkungen / Nutzen der App.

### 3. Product Logic
Kurze, klare Erklärung, wie ayo funktioniert.

### 4. Supporting Depth
Verstärkende Produktpunkte, ohne das Listing zu überladen.

## Inhaltliche Struktur

Die App-Store-Copy von ayo soll ungefähr diese Logik transportieren:

### Opening
Ayo hilft beim Quitten von Nikotin mit täglichem Dranbleiben, sichtbarem Fortschritt und Unterstützung in schwierigen Momenten.

### Benefit-Ebene
- täglich dranbleiben
- smoke-free Tage markieren
- Fortschritt wirklich sehen
- bei Cravings Unterstützung bekommen

### Product-Ebene
- Daily check-ins
- Fortschritt / Verlauf
- Streak / Konsistenz
- Craving support

### Supporting Layer
- weitere Unterstützung / tiefere Produktstruktur
- ohne Premium direkt in den Vordergrund zu stellen

## Was bewusst vermieden wird

- keine reine Feature-Liste
- keine zu generische Motivationssprache
- keine zu aggressive Store-Copy
- kein starker Premium-/Abo-Fokus im Listing
- keine medizinische oder therapeutische Claims-Sprache
- kein Problem-Opener als Hauptlogik

## Begründung

Diese Entscheidung wurde getroffen, weil ayo im App Store klar verständlich sein muss, aber gleichzeitig mehr Substanz haben soll als ein generischer Quit-Tracker.

Die beste Balance ist deshalb:

- nutzenorientiert
- klar strukturiert
- mit ausgewählten starken Produktbestandteilen
- ohne den Fokus zu verlieren

## Definition of Done

Ticket 30 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die Listing-Copy eine Mischung aus Nutzen und ausgewählten Produktbestandteilen sein soll
- dass Premium im Listing für V1 nicht aktiv hervorgehoben wird
- dass die Description mit der Lösung / dem Nutzen eröffnet
- dass die Tonalität eine Mischung aus ruhig, hochwertig und leicht markant sein soll
- dass quit nicotine, daily check-ins, real progress und craving support die Kerninhalte der Listing-Copy bilden


———————————————————

# Ticket 31 – Preview-Video / App Preview Entscheidung treffen

## Ergebnis

Für **ayo** wird zum ersten Release **kein App Preview als Pflichtbestandteil** eingeplant.

Die Store-Präsentation in V1 soll sich auf:

- starke Screenshots
- klare Listing-Copy
- saubere Produktreife
- hochwertigen Release-Finish

konzentrieren.

## Strategische Entscheidung

Ein App Preview wird für V1 bewusst weggelassen.

### Begründung
Für den aktuellen Release-Stand bringt ein Preview-Video nicht genug zusätzlichen Nutzen, um den Aufwand und das Risiko zu rechtfertigen.

Die wichtigsten Gründe:

- ayo kann über gute Screenshots und starke Copy bereits klar erklärt werden
- der aktuelle Fokus sollte auf Produktreife, Monetarisierung, Gating, Daily Loop und Release-Sauberkeit liegen
- ein mittelmäßiges Preview würde eher schaden als helfen
- ein App Preview ist für V1 weniger wichtig als ein hochwertiger Screenshot-/Listing-Auftritt

## Rolle eines späteren App Previews

Ein App Preview bleibt als **spätere Store-Optimierung** dokumentiert.

### Entscheidung
Das Thema wird **nicht verworfen**, sondern bewusst auf eine spätere Phase verschoben.

Ein späteres Preview kann sinnvoll werden, wenn:

- die finalen Flows vollständig polished sind
- das Produktgefühl in Bewegung noch stärker gezeigt werden soll
- die App-Store-Optimierung in einer späteren Iteration vertieft wird

## Fokus eines späteren App Previews

Wenn später ein App Preview erstellt wird, soll der Schwerpunkt **nicht** auf reiner Feature-Erklärung liegen.

### Entscheidung
Ein späteres Preview soll vor allem das **Flow- und Produktgefühl** zeigen, insbesondere:

- Daily Check-in
- ruhige Home-Interaktion
- Progress-/Streak-Wirkung
- Rescue-Moment
- hochwertiges, lebendiges Produktgefühl

Ziel:
- das Erleben der App transportieren
- nicht einfach nur einzelne Features trocken erklären

## Qualitätsregel

Für ayo gilt ausdrücklich:

- **ein mittelmäßiges Preview ist schlechter als gar keins**

### Bedeutung
Es wird kein Preview nur deshalb erstellt, damit „auch eins da ist“.

Ein Preview soll nur dann kommen, wenn es:
- hochwertig
- klar
- ruhig
- markenkonform
- professionell genug

ist, um den App-Store-Auftritt wirklich zu verbessern.

## Was bewusst vermieden wird

- kein halbgutes Pflicht-Preview für V1
- kein zeitintensiver Zusatzaufwand, der wichtigere Release-Arbeit verdrängt
- keine featurelastige Demo ohne klare emotionale Wirkung
- kein App Preview, das schwächer wirkt als die Screenshots

## Begründung

Diese Entscheidung wurde getroffen, weil ayo im ersten Release mehr davon profitiert, wenn:

- die App intern sauber steht
- die Store-Screenshots stark sind
- die Positionierung klar ist
- die Produktlogik stabil ist

Ein gutes App Preview kann später wertvoll sein, aber V1 soll nicht durch unnötigen zusätzlichen Asset-Aufwand ausgebremst werden.

## Definition of Done

Ticket 31 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass ayo in V1 kein App Preview als Pflicht erhält
- dass ein Preview später als Store-Optimierung dokumentiert bleibt
- dass ein späteres Preview auf Flow und Produktgefühl statt auf reine Feature-Erklärung fokussieren soll
- dass für ayo ein mittelmäßiges Preview ausdrücklich schlechter als gar keins ist

———————————————————

# Ticket 32 – App Icon finalisieren

## Ergebnis

Für **ayo** wird das App Icon für V1 als **brand-first Icon** finalisiert.

Das Icon soll nicht primär das Thema „quit smoking“ wörtlich erklären, sondern wie ein ruhiges, hochwertiges und wiedererkennbares Premium-Produkt wirken.

## Strategische Entscheidung

Das App Icon von ayo soll:

- **markenorientiert**
- **reduziert**
- **ruhig**
- **hochwertig**
- **klar lesbar**
- **im kleinen Maßstab stark**

sein.

Es soll bewusst **nicht** wie ein klassisches Stop-Smoking-, Medical- oder Utility-App-Icon wirken.

## Richtung des finalen Icons

### Entscheidung
Das Icon soll **rein brand-/symbolorientiert** sein.

Das bedeutet:
- kein direktes Raucher-/Verbotssymbol
- keine plakative Zigarette
- keine medizinisch wirkenden Symbole
- keine zu wörtliche Erklärgrafik

Ziel:
- Ayo als echte Marke stärken
- hochwertiger und moderner wirken
- sich von generischen Konkurrenz-Icons abheben

## Designcharakter

Das Icon soll für V1 klar **reduziert / minimal** gehalten werden.

### Entscheidung
- eher minimal als illustrativ
- eher klar als verspielt
- eher präzise als überladen

Das passt zur Produktwirkung von ayo und zur ruhigen Premium-Ästhetik der App.

## Vorrang bei der Entscheidung

Wenn sich ein schöneres / markigeres Icon und ein erklärenderes Icon gegenüberstehen, soll für ayo das **schönere, markigere** Icon gewinnen.

### Entscheidung
Wichtiger als direkte Thema-Erklärung ist:
- Wiedererkennbarkeit
- Brand-Fokus
- Premium-Eindruck
- visuelle Qualität

## Qualitätsprüfung des finalen Icons

Das Icon muss vor Finalisierung explizit in mehreren realen Kontexten geprüft werden.

### Pflichtprüfung
- auf kleinem Maßstab / Homescreen-Größe
- im App-Store-Raster
- im Vergleich zu Konkurrenz-Icons
- auf Klarheit, Kontrast und Wiedererkennbarkeit

### Ziel
Das Icon soll:
- klein klar bleiben
- nicht matschig wirken
- nicht zu fein oder kompliziert sein
- sich im Store behaupten können

## Umgang mit dem aktuellen Icon

Für V1 soll das derzeitige Icon **überarbeitet** und nicht komplett in eine völlig neue Richtung ersetzt werden.

### Entscheidung
Das bestehende Icon wird als Ausgangsbasis genutzt und in Richtung:

- stärkerer Brand-Fokus
- mehr Ruhe
- mehr Premium-Wirkung
- klarerer Ayo-Charakter

weiterentwickelt.

## Rolle von „Ayo“ als Marke

Der Markenname **Ayo** soll insgesamt stärker in den Fokus rücken.

### Entscheidung
Das Icon selbst bleibt brand-first und nicht erklärlastig.

Zusätzlich soll geprüft werden, wie **Ayo** in den App-Store-Screens / Screenshot-Kompositionen sichtbar werden kann, jedoch:

- subtiler
- ruhiger
- weniger laut
- stärker integriert

als bisherige lautere Branding-Ansätze.

Das bedeutet:
- Ayo darf in einzelnen Store-Screens vorkommen
- aber nicht dominant, plakativ oder überinszeniert
- eher als ruhiger Markenträger innerhalb eines hochwertigen Screenshot-Systems

## Was bewusst vermieden wird

- keine plakative Anti-Smoking-Bildsprache
- keine medizinisch wirkende Ikonografie
- keine zu laute oder billige Utility-App-Optik
- kein überladenes Icon mit zu vielen Bedeutungen
- kein Logo-/Markeneinsatz in den Store-Screens, der zu dominant oder aufdringlich wirkt

## Begründung

Diese Entscheidung wurde getroffen, weil ayo im Store und auf dem Homescreen eher wie ein modernes, hochwertiges Consumer-Produkt wirken soll als wie eine klassische Stop-Smoking- oder Health-Utility-App.

Ein markigeres, ruhigeres und reduzierteres Icon unterstützt:

- Wiedererkennbarkeit
- Vertrauen
- Premium-Wirkung
- bessere Differenzierung zur Konkurrenz

## Definition of Done

Ticket 32 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass das App Icon brand-first und nicht thematisch erklärlastig sein soll
- dass das Icon reduziert / minimal gehalten werden soll
- dass im Zweifel das schönere und markigere Icon gewinnt
- dass das bestehende Icon überarbeitet statt komplett neu gedacht wird
- dass das finale Icon auf kleinem Maßstab und gegen Konkurrenz geprüft werden muss
- dass der Markenname Ayo zusätzlich subtiler in die Store-Screens integriert werden darf, ohne zu laut zu werden


———————————————————

# Ticket 33 – App Store Connect Setup final vorbereiten

## Ergebnis

Für **ayo** wird das App Store Connect Setup für V1 als klarer Release-Block definiert.  
Ziel ist ein vollständiges, konsistentes und review-sicheres Setup für einen ersten **englischsprachigen Launch**.

## Strategische Entscheidung

App Store Connect soll für V1 so vorbereitet werden, dass:

- Branding konsistent ist
- Legal- und Store-Grundlagen stehen
- Subscription-Setup sauber passt
- Availability bewusst gewählt ist
- der Release nicht an fehlenden Pflichtfeldern oder inkonsistenten Metadaten scheitert

Dabei wird zwischen:

- **Pflicht-Setup für V1**
- und **späterem ASO-/Listing-Feinschliff**

klar unterschieden.

## Launch-Ausrichtung

Der Erstlaunch wird als **englischsprachiger Regionen-Launch** gedacht.

### Entscheidung
V1 ist auf:

- **USA**
- und **ausgewählte englischsprachige Märkte**

ausgerichtet.

Die App soll **nicht sofort breit für alle Regionen / Sprachen** ausgerollt werden.

### Spätere Richtung
Weitere Sprachen und Regionen können später bewusst ergänzt werden, sobald:

- Copy
- Screenshots
- Store-Assets
- Lokalisierung
- Produktqualität

dafür sauber vorbereitet sind.

## Pflichtblöcke im App Store Connect Setup

### 1. Branding & Identity
Vor Release müssen in App Store Connect konsistent vorbereitet sein:

- finaler App-Name
- Bundle / App-Zuordnung
- App-Icon
- konsistente Markenidentität
- keine alten Produktnamen oder MVP-Spuren

### 2. Store Listing Grundstruktur
Die strukturellen Listing-Bestandteile müssen vorbereitet werden, darunter:

- Subtitle
- Description
- Keywords
- Screenshots
- Kategorie / Store-Einordnung

Wichtig:
Diese Bereiche müssen im Setup vorgesehen und konsistent vorbereitet werden.

### 3. Legal
Vor Release müssen vorhanden und korrekt verknüpft sein:

- Privacy Policy URL
- Terms URL
- Support URL

Diese URLs sind Pflichtbestandteile des Setups und gelten als Release-Blocker.

### 4. Monetization / Subscription Setup
App Store Connect muss für das Subscription-Modell sauber vorbereitet sein, insbesondere:

- Monthly Produkt
- Annual Produkt
- Trial-Konfiguration passend zur Produktentscheidung
- konsistente Verbindung zur RevenueCat-Logik
- keine widersprüchliche Trial-/Abo-Konfiguration

### 5. App Privacy / Review-relevante Angaben
Die Angaben zu Privacy / Datennutzung / Produktbeschreibung müssen in App Store Connect so vorbereitet werden, dass sie zur tatsächlichen App-Logik passen.

Ziel:
- keine offensichtlichen Widersprüche
- keine unvollständigen Pflichtangaben
- review-sicherer Gesamteindruck

### 6. Submission Readiness
Vor Release müssen außerdem die üblichen Einreichungsbestandteile vollständig vorbereitet sein, z. B.:

- Availability
- Altersfreigabe
- Build-Zuordnung
- finale Release-Basis
- ggf. relevante Review-Notizen

## Noch nicht final in Ticket 33

Bestimmte Listing-Bestandteile werden in Ticket 33 **noch nicht endgültig finalisiert**, sondern später gezielt optimiert.

### Entscheidung
Folgende Bereiche gelten in diesem Ticket noch **nicht als inhaltlich final**:

- Description
- Keywords
- ggf. Feinschliff von Subtitle / ASO-Texten

### Begründung
Diese Bereiche sollen später mit zusätzlicher Tool-/ASO-Unterstützung optimiert werden.

Ticket 33 stellt deshalb sicher, dass App Store Connect dafür strukturell vorbereitet ist, aber nicht, dass alle Listing-Texte schon endgültig festgezurrt sind.

## Qualitätsstandard für V1

Für V1 gilt:

- lieber **einfach, vollständig und sauber**
- statt früh komplex, breit und halb final

Das betrifft insbesondere:
- Regionen
- Sprachen
- Listing-Komplexität
- Release-Setup

## Was bewusst vermieden wird

- kein breiter globaler Erstlaunch ohne klare Sprach-/Regionenstrategie
- keine vorzeitig finalisierten ASO-Texte, obwohl noch Optimierung geplant ist
- kein inkonsistentes Setup zwischen App, RevenueCat, Legal und Store
- keine fehlenden Legal-URLs
- keine halb vorbereitete Store-Einreichung

## Begründung

Diese Entscheidung wurde getroffen, weil ayo für V1 vor allem einen:

- sauberen
- fokussierten
- englischsprachigen
- review-sicheren
- monetär konsistenten

Erstlaunch braucht.

App Store Connect soll dafür vollständig vorbereitet sein, während ASO-/Text-Optimierungen gezielt später verfeinert werden können.

## Definition of Done

Ticket 33 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass App Store Connect für V1 vollständig und konsistent vorbereitet werden muss
- dass der Erstlaunch als englischsprachiger Regionen-Launch gedacht wird
- dass der Fokus auf USA und ausgewählten englischsprachigen Märkten liegt
- dass Branding, Legal, Subscription-Setup, Privacy-Angaben und Submission-Grundlagen Pflichtbestandteile sind
- dass Description, Keywords und ASO-Feinschliff noch nicht final, sondern später optimiert werden
- dass Legal-URLs, Subscription-Setup und strukturelle Store-Vorbereitung als Release-Blocker gelten


———————————————————


# Ticket 34 – Device QA Matrix abarbeiten

## Ergebnis

Für **ayo** wird vor dem Release eine kompakte, aber aussagekräftige Device-QA-Matrix festgelegt, damit der erste Release nicht nur auf einem Einzelgerät gut aussieht, sondern auf den wichtigsten iPhone-Größen sauber funktioniert.

## Strategische Entscheidung

Die Device-QA für V1 wird **nach Gerätekategorien** und nicht primär nach langen Modelllisten strukturiert.

### Gerätekategorien
Die verpflichtende QA-Matrix umfasst:

- **kleines iPhone**
- **mittleres Standard-iPhone**
- **großes iPhone**

Diese Struktur ist für V1 die beste Balance aus:

- realistischer Abdeckung
- klarer Prüflogik
- vertretbarem Aufwand
- hoher Relevanz für Layout und Kernflows

## Pflichtbereiche auf jedem Gerät

Die folgenden Produktbereiche und Flows müssen **auf jeder der drei iPhone-Kategorien** geprüft werden.

### 1. Onboarding & Monetization Flow
Auf jedem Gerät zu prüfen:

- kompletter Onboarding-Flow
- Plan-Processing-Screen
- Plan-Ready-Bridge
- Notification Pre-Prompt
- Trial-/Reminder-Screen
- Main Paywall
- Skip in reduzierte Free-Version
- Purchase / Trial-Start

Ziel:
- keine Layout-Brüche
- klare CTA-Erreichbarkeit
- keine kaputten Übergänge
- kein inkonsistentes Paywall-Verhalten

### 2. Home / Daily Loop
Auf jedem Gerät zu prüfen:

- Hero
- primäre CTA: **Mark today as smoke-free**
- Streak-Bereich unter dem Hero
- Progress-Verstärkung
- Rescue Entry
- reduzierte vs Premium-Tiefe
- Locks / Premium-Hinweise auf Home

Ziel:
- Home bleibt klar geführt
- Daily Loop funktioniert visuell und logisch
- keine Überlagerungen, abgeschnittenen Elemente oder zu schwache Hierarchie

### 3. Progress / Markers / Settings
Auf jedem Gerät zu prüfen:

- Progress mit Check-in-Bezug
- Check-in-/Kontinuitätsdarstellung
- Marker-/Achievement-Locks
- Dark Mode Lock
- Settings / Account / How Ayo works
- Legal-Zugänge / Info-Bereiche

Ziel:
- keine kaputten Listen / Cards / States
- Gating korrekt sichtbar
- Info- und Account-Bereiche sauber bedienbar

### 4. Auth / Restore / Premium-Zustände
Auf jedem Gerät zu prüfen:

- Apple Login
- Google Login
- Restore
- Premium-Freischaltung
- Rückkehr in korrekte Zustände
- Locks verschwinden korrekt
- Free / Premium Rendering konsistent

Ziel:
- keine Dead Ends
- keine falschen Premium-Zustände
- keine Auth- oder Restore-Probleme durch Gerätekontext

### 5. Notifications / Permission
Auf jedem Gerät zu prüfen:

- Notification Pre-Prompt
- Übergang zum iOS Permission Dialog
- Verhalten bei Zustimmung
- Verhalten bei Ablehnung
- spätere Reminder-Logik soweit testbar
- Settings-Steuerung für Notifications

Ziel:
- keine kaputte Permission-Integration
- kein verwirrender Flow
- konsistente UX rund um Reminder und Check-in-Logik

## Release-Blocker-Regel

Ein Device-QA-Problem gilt als **Release-Blocker**, wenn:

- zentrale Flows brechen
- Paywall / Purchase / Login / Restore kaputt sind
- ein zentrales Layout auf einer Hauptgeräteklasse klar beschädigt ist
- wichtige CTA nicht sauber erreichbar oder bedienbar sind
- Premium-Gating sichtbar inkonsistent ist
- Notification-/Permission-Flow grob falsch funktioniert

## Nicht automatisch Release-Blocker

Nicht jeder Unterschied oder kleine Schönheitsfehler blockiert den Release.

### Entscheidung
Kleine visuelle Unterschiede zwischen Gerätekategorien sind in V1 akzeptabel, solange:

- die Kernhierarchie intakt bleibt
- die wichtigsten CTA funktionieren
- keine Verwirrung entsteht
- die App insgesamt hochwertig und konsistent wirkt

Damit wird V1 bewusst pragmatisch, aber nicht schlampig behandelt.

## Fokus auf Paywall und Gating

Paywall- und Gating-Flows sind ausdrücklich Teil der Pflicht-QA **auf jedem Gerät**.

### Entscheidung
Diese Bereiche werden nicht nur allgemein, sondern in jeder Geräteklasse gezielt geprüft.

Begründung:
- Monetization ist Kern des Produkts
- Gating ist zentral für Free vs Premium
- kleine Geräte- oder Layoutfehler können hier direkt Umsatz und Vertrauen kosten

## Was bewusst vermieden wird

- keine QA nur auf einem Hauptgerät
- keine zu große Modell-Matrix für V1
- keine Vernachlässigung von Paywall- oder Gating-Flows
- kein Anspruch auf absolute Pixelperfektion, wenn der Kern sauber funktioniert
- keine Release-Entscheidung allein nach kosmetischen Mini-Unterschieden

## Begründung

Diese Entscheidung wurde getroffen, weil ayo stark von klarer Hierarchie, sauberer Monetization-Logik, guter Layout-Wirkung und konsistenter Daily-Loop-UX lebt.

Gerade die Kombination aus:

- Onboarding
- Plan-Processing
- Paywall
- Home-Hero
- Streak
- Progress
- Gating
- Login / Restore
- Notifications

macht Geräteprüfung für ayo besonders wichtig.

Eine kompakte 3-Klassen-Matrix ist dafür die sinnvollste V1-Lösung.

## Definition of Done

Ticket 34 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die Device-QA für V1 über die Kategorien kleines / mittleres / großes iPhone läuft
- dass alle Kernflows auf jeder Geräteklasse geprüft werden müssen
- dass Paywall- und Gating-Flows auf jedem Gerät Pflicht sind
- was als Release-Blocker gilt
- dass kleine visuelle Unterschiede akzeptabel sind, solange der Kern sauber bleibt
- dass die QA-Matrix bewusst kompakt, aber strategisch vollständig bleibt



———————————————————


# Ticket 35 – TestFlight Soft Launch / internen Test sauber aufsetzen

## Ergebnis

Für **ayo** wird vor dem Release ein kleiner, kontrollierter **TestFlight Soft Launch** mit internen Testern festgelegt.

Die Testphase soll nicht als große offene Beta verstanden werden, sondern als gezielter Realitätscheck mit:

- eigener intensiver Nutzung
- wenigen engen, vertrauenswürdigen Testpersonen
- Fokus auf Kernflows, Produktwahrnehmung und letzte Release-Schwächen

## Strategische Entscheidung

Die TestFlight-Phase von ayo wird als **kleiner interner Soft-Test** aufgesetzt.

### Testgruppe
Die App wird vor dem Release getestet von:

- dir selbst intensiv
- wenigen engen Personen / vertrauenswürdigen Testern

Es wird **keine große öffentliche Beta** für V1 angestrebt.

## Ziel der TestFlight-Phase

Die TestFlight-Phase soll für ayo zwei Dinge gleichzeitig leisten:

- technische QA absichern
- echte Produktwahrnehmung prüfen

### Schwerpunkt
Beides ist wichtig, aber der Fokus liegt besonders auf:

- Produktwahrnehmung
- Vertrauensgefühl
- Verständlichkeit
- Reifeeindruck
- letzten Monetization-/Daily-Loop-Schwächen

## Fester Testfokus

Für TestFlight wird ein klarer Fokus definiert.

### Pflichtbereiche
Die Tester sollen besonders auf diese Bereiche achten:

- Onboarding
- Plan-Processing / Plan-Ready-Finish
- Trial-/Reminder-Screen
- Main Paywall
- Free vs Premium Wirkung
- Home / Daily Loop
- Daily smoke-free check-in
- Streak / on-ice-Logik
- Notifications
- Auth / Restore
- allgemeiner Reifeeindruck

## Qualitätsregel vor TestFlight

Ein TestFlight-Build soll nur dann in diese Soft-Phase gehen, wenn die großen Kernbereiche bereits **grundsätzlich releasewürdig** wirken.

### Entscheidung
TestFlight ist in V1 **nicht** dafür gedacht, einen offensichtlich halbfertigen Produktstand erst einmal „irgendwie mit anderen“ auszuprobieren.

Ziel:
- fokussierter Feinschliff
- reale Nutzungserkenntnisse
- letzte Schwächen finden
- kein chaotischer Beta-Ersatz für fehlende Grundqualität

## Rolle von TestFlight

TestFlight soll für ayo ausdrücklich **nicht nur Bugs** finden.

### Entscheidung
Die Testphase soll auch sichtbar machen:

- wirkt das Produkt verstanden?
- fühlt sich der Daily Loop stark genug an?
- wirkt die Paywall logisch und hochwertig?
- fühlt sich Free vs Premium richtig an?
- sieht die App nach echtem Produkt oder noch nach Build aus?
- gibt es Vertrauensprobleme oder Reibung?

## Testdauer / Nutzungstiefe

Die TestFlight-Phase soll nicht nur aus kurzem Anklicken bestehen.

### Ziel
Die App soll über mehrere Nutzungsmomente erlebt werden, z. B.:

- erstes Onboarding
- erster Daily Check-in
- wiederholte Rückkehr
- Notification-Wirkung
- Interaktion mit Locks
- Auth / Restore
- Premium-/Free-Eindruck

Es geht also um **echte Nutzung** und nicht nur um oberflächliches Durchklicken.

## Was bewusst vermieden wird

- keine große offene Beta für V1
- kein TestFlight nur als Bugliste ohne Produktblick
- keine Freigabe eines klar unreifen Builds in TestFlight
- keine überladene Testgruppe mit zu vielen schwachen Signalen
- keine reine Einmalnutzung ohne Alltagseindruck

## Begründung

Diese Entscheidung wurde getroffen, weil ayo vor dem Release vor allem einen:

- realistischen
- ehrlichen
- kleinen
- qualitativen

Test braucht.

Mit dir selbst und einigen engen Personen lassen sich die wichtigsten letzten Fragen oft besser klären als mit einer großen, ungerichteten Beta:

- versteht man die App?
- fühlt sie sich stark an?
- wirkt sie fertig?
- ist der Kernloop wirklich überzeugend?

## Definition of Done

Ticket 35 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass TestFlight für V1 als kleiner interner Soft-Test aufgesetzt wird
- dass du selbst und wenige enge Personen testen sollen
- dass technische QA und Produktwahrnehmung beide geprüft werden, mit Fokus auf Produktwahrnehmung
- dass es einen festen Testfokus auf Kernbereiche geben soll
- dass TestFlight nur mit grundsätzlich releasewürdigem Build startet
- dass TestFlight ausdrücklich auch letzte Vertrauens- und Produktprobleme finden soll


———————————————————


# Ticket 36 – High-severity Bugs fixen / Release-Blocker-Regel finalisieren

## Ergebnis

Für **ayo** wird eine klare Release-Blocker-Regel festgelegt, damit vor dem ersten Release nicht mit echten Vertrauens-, Funnel- oder Kernfunktionsbrüchen live gegangen wird.

## Strategische Entscheidung

Für ayo gilt:

- **lieber etwas später releasen als mit kaputtem Vertrauen**

Die App soll zum Start nicht perfekt in jedem Detail sein, aber in allen Kernbereichen **stabil, konsistent und vertrauenswürdig** wirken.

## Bug-Schweregrade

Für den Release werden Bugs in drei Schweregrade gedacht:

### 1. Release-Blocker
Müssen vor Release gefixt werden.

### 2. High Priority
Sollten möglichst noch vor Release behoben werden, können im Ausnahmefall aber in ein sehr frühes Update verschoben werden.

### 3. Nice-to-fix
Kleinere Unsauberkeiten, die den Release nicht aufhalten müssen.

## Release-Blocker-Regel

Ein einzelner schwerer Bug in einem Kernflow reicht aus, um den Release zu stoppen.

### Entscheidung
Es braucht **nicht mehrere Probleme gleichzeitig**, damit ein Release gestoppt wird.

Wenn ein einzelner Fehler einen zentralen Produkt- oder Vertrauensbereich ernsthaft beschädigt, gilt er als Release-Blocker.

## Besonders kritische Kernbereiche

Für ayo gelten Bugs in den folgenden Bereichen ausdrücklich als besonders kritisch:

- Onboarding
- Plan-Processing / Plan-Ready-Finish
- Paywall
- Trial / Purchase / Restore
- Daily smoke-free check-in
- Streak / on-ice-Logik
- Free vs Premium Gating
- Login / Auth
- zentrale Error States
- Notification-Permission / Reminder-Logik

## Typische Release-Blocker für ayo

### Funnel / Monetization
- Onboarding bricht
- Paywall ist nicht nutzbar
- Trial / Purchase / Restore funktionieren nicht sauber
- falscher Premium-Status
- Locks verhalten sich widersprüchlich
- Nutzer gelangt nach Kauf nicht korrekt in Premium

### Daily Loop
- täglicher Check-in funktioniert nicht zuverlässig
- Streak-Logik ist sichtbar falsch
- on-ice-Zustände funktionieren nicht wie vorgesehen
- Home-Hauptaktion ist kaputt oder unklar bedienbar

### Vertrauen / Reife
- sichtbare alte Namen / MVP-Reste
- große visuelle Brüche in Hauptscreens
- Login wirkt unfertig oder bricht
- Error States erzeugen Sackgassen
- App wirkt in Kernbereichen sichtbar unfertig

### Notification / Reminder
- Notification-Permission ist falsch eingebunden
- wichtige Reminder verhalten sich logisch falsch
- Ablehnung / Zustimmung führt in verwirrende Zustände

## High Priority, aber nicht automatisch Release-Blocker

Folgende Dinge sind wichtig, aber nicht zwingend sofort release-stoppend, solange der Kern stabil bleibt:

- leicht verzögerte State-Updates, die sich korrekt heilen
- kleinere Layoutabweichungen auf einzelnen Geräten
- kleinere Copy-Unsauberkeiten
- schwächerer Feinschliff auf sekundären Screens
- kleinere Spacing-/Visual-Polish-Themen

## Was den Release nicht alleine stoppen soll

Kleinere visuelle Unsauberkeiten stoppen den Release **nicht automatisch**, solange:

- die Kernflows sauber funktionieren
- die App insgesamt hochwertig wirkt
- keine Verwirrung entsteht
- keine zentrale Nutzerhandlung kaputt ist

### Entscheidung
Nicht jede kleine optische Unschärfe ist ein Blocker.

Ayo soll zwar hochwertig wirken, aber V1 darf pragmatisch bleiben, solange Vertrauen und Funktion nicht brechen.

## Was bewusst vermieden wird

- kein Release mit kaputtem Kernfunnel
- keine Monetization mit instabilem Premium-/Restore-Verhalten
- kein Daily Loop mit unzuverlässigem Check-in oder Streak-System
- kein Upload trotz sichtbarer Vertrauensbrüche in zentralen Flows
- keine künstliche Perfektionierung wegen kleiner kosmetischer Details

## Begründung

Diese Entscheidung wurde getroffen, weil ayo besonders stark von:

- Vertrauen
- Produktreife
- ruhiger UX
- konsistenter Monetization
- funktionierendem Daily Loop
- sauberem Gating

lebt.

Ein kaputter Kernflow würde bei ayo deutlich schwerer wiegen als kleinere optische Restarbeiten.

## Definition of Done

Ticket 36 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass lieber etwas später releast wird als mit kaputtem Vertrauen
- dass ein einzelner schwerer Bug in einem Kernflow bereits Release-Blocker sein kann
- dass Bugs in Onboarding, Paywall, Check-in, Streak, Free/Premium Gating und Auth besonders kritisch sind
- dass es eine klare Trennung zwischen Blockern und kleineren Unsauberkeiten gibt
- dass kleinere visuelle Unsauberkeiten den Release nicht alleine stoppen sollen, solange der Kern stark bleibt


———————————————————


# Ticket 37 – Release Candidate Build finalisieren

## Ergebnis

Für **ayo** wird der Release Candidate als echter beinahe-finaler Produktbuild definiert und nicht als weiterer normaler Entwicklungsstand.

Ein Release Candidate soll bereits wie ein echtes Produkt wirken — nicht wie ein „fast-fertig“-Build.

## Strategische Entscheidung

Der Release Candidate markiert den Punkt, ab dem ayo funktional und visuell im Kern fertig sein muss.

Ab diesem Zeitpunkt sollen keine neuen Features mehr in den Build aufgenommen werden.

### Entscheidung
Ab Release Candidate gilt:

- **keine neuen Features mehr**
- nur noch:
  - Release-Blocker-Fixes
  - High-severity Fixes
  - kleine release-relevante Korrekturen

## Rolle des Release Candidates

Der Release Candidate ist der Build, auf dem:

- letzte interne Tests / TestFlight-Prüfung sinnvoll stattfinden
- die Kernflows stabil bewertet werden
- nur noch finale Korrekturen vor dem Upload gemacht werden
- keine neue Produktlogik mehr eingeführt wird

## Produktanforderungen an den Release Candidate

Vor Erstellung des Release Candidates müssen die großen Produktbereiche in ihrem V1-Zustand stehen, insbesondere:

- Onboarding
- Plan-Processing / Plan-Ready-Finish
- Trial-/Reminder-Screen
- Main Paywall
- Premium-Gating
- Daily smoke-free check-in
- Streak / on-ice-Logik
- Home
- Progress
- Markers
- Settings
- Notifications
- Auth / Restore
- Error-/Loading-/Sync-Zustände

## Reifeanforderungen an den Release Candidate

Ein Release Candidate darf keine offensichtlichen sichtbaren Entwicklungsreste mehr enthalten.

Das bedeutet insbesondere:

- keine alten Produktnamen
- keine sichtbaren Placeholder-Texte
- keine sichtbaren „coming soon“-Reste
- keine sichtbaren internen Test-Einstiege
- kein klarer MVP-/Prototyp-Eindruck in Kernbereichen

## Monetization-Anforderungen

Der Release Candidate muss die Monetization-Logik in ihrem echten V1-Zustand enthalten, insbesondere:

- RevenueCat Production-Logik
- korrektes Entitlement / Offering
- Annual / Monthly-Struktur
- Trial-Logik
- Purchase / Restore in prüfbarem Zustand
- Free vs Premium Gating korrekt

## Legal-/Store-Voraussetzungen

Der Release Candidate soll nicht losgelöst von den restlichen Release-Bausteinen entstehen.

### Entscheidung
Ein Release Candidate wird erst dann als sinnvoller echter RC betrachtet, wenn auch die sichtbaren Store-/Legal-Grundlagen bereits stehen, insbesondere:

- Privacy Policy
- Terms
- Support URL
- strukturelles App Store Connect Setup
- englischsprachige Launch-Ausrichtung

Ziel:
- kein isolierter App-Build ohne reale Release-Basis
- keine Trennung zwischen fast fertiger App und halbfertigem Store-/Legal-Kontext

## Änderungsregel nach Release Candidate

Nach dem Release Candidate sind nur noch folgende Änderungen erlaubt:

- Blocker-Fixes
- High-severity Bugfixes
- kleine release-notwendige Korrekturen

### Nicht mehr vorgesehen
- neue Features
- neue Produktideen
- größere neue UX-Richtungen
- zusätzliche Scope-Ausweitungen
- neue Systeme oder Nebenprojekte

## Was bewusst vermieden wird

- kein RC als weiterer normaler Dev-Build
- keine „noch schnell mit rein“-Feature-Logik
- keine sichtbare Halbfertigkeit im RC
- keine Trennung zwischen fast fertiger App und unfertigen Release-Grundlagen
- kein Moving Target kurz vor dem Upload

## Begründung

Diese Entscheidung wurde getroffen, weil ayo vor dem Upload eine klare Phase braucht, in der:

- Stabilität vor Neuerung geht
- Vertrauen vor Scope-Wachstum geht
- reale Produktqualität bewertet werden kann
- keine unnötige neue Komplexität mehr entsteht

Ein sauber definierter Release Candidate reduziert das Risiko, kurz vor Release durch neue Änderungen erneut Instabilität einzubauen.

## Definition of Done

Ticket 37 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass der Release Candidate ein echter beinahe-finaler Produktbuild sein muss
- dass ab Release Candidate keine neuen Features mehr in den Build aufgenommen werden
- dass danach nur noch Blocker-, High-severity- und kleine Release-Fixes erlaubt sind
- dass die großen Produktbereiche in ihrem V1-Zustand stehen müssen
- dass sichtbare MVP-/Placeholder-/Coming-soon-Reste nicht mehr im RC enthalten sein dürfen
- dass auch Store-/Legal-Grundlagen bereits stehen müssen
- dass der Release Candidate bereits wie ein echtes Produkt wirken muss


———————————————————


# Ticket 38 – Release Day Checklist / Submission-Ablauf festlegen

## Ergebnis

Für **ayo** wird der Release Day als **harte letzte Kontrollschranke** definiert.

Der Submission-Tag soll kein formaler Upload-Moment sein, sondern ein bewusst strukturierter Go/No-Go-Prozess, in dem noch einmal alle kritischen Release-Bausteine geprüft werden.

## Strategische Entscheidung

Der Release von ayo findet **nicht** statt, wenn noch offene Release-Blocker bestehen.

### Entscheidung
Am Release Day gilt ausdrücklich:

- offene Blocker = **kein Upload**
- keine „wir submitten trotzdem mal“
- keine bewusste Inkaufnahme kaputter Kernflows

## Rolle des Release Day

Der Release Day ist der Punkt, an dem geprüft wird, ob:

- der richtige finale Build ausgewählt ist
- Monetization und Gating konsistent sind
- Legal / Store / Review-Bausteine live und korrekt sind
- keine offenen kritischen Probleme mehr existieren
- die App in ihrer finalen Startregion wirklich releasefähig ist

## Struktur der Release-Day-Checklist

Die Release-Day-Checklist soll **detailliert** sein und nicht nur aus wenigen groben Punkten bestehen.

### Entscheidung
Für ayo wird bewusst eine **detailliertere Release-Day-Checkliste** angestrebt, weil der Produktlaunch mehrere sensible Bereiche umfasst, insbesondere:

- Paywall
- RevenueCat
- Trial
- Free vs Premium
- Auth / Restore
- Notifications
- Store-/Legal-Konsistenz

Ziel:
- nichts Wesentliches vergessen
- Submission nicht dem Zufall überlassen

## Pflichtblöcke am Release Day

### 1. Produkt & Build
Vor Submission prüfen:

- richtiger finaler Build ausgewählt
- Version und Buildnummer korrekt
- keine sichtbaren Debug-/Test-Reste
- keine alten Produktnamen
- keine sichtbaren Placeholder
- finale Icon-/Branding-Fassung aktiv

### 2. Monetization
Vor Submission prüfen:

- RevenueCat Setup korrekt
- Offering / Entitlement korrekt
- Trial-Logik korrekt
- Annual / Monthly korrekt
- Free vs Premium korrekt
- Purchase / Restore plausibel und konsistent

### 3. Legal & Review
Vor Submission prüfen:

- Privacy Policy URL live
- Terms URL live
- Support URL live
- App Privacy / Review-Angaben konsistent
- Store-Sprache claims-sicher und passend zur Produktrealität

### 4. Store Assets / App Store Connect
Vor Submission prüfen:

- Screenshots final
- Store-Assets in finaler V1-Fassung
- relevante Texte vorhanden
- Kategorien / Availability korrekt
- englischsprachige Startregionen korrekt gesetzt

### 5. QA-Go/No-Go
Vor Submission prüfen:

- keine offenen Release-Blocker
- Kernflows in funktionsfähigem Zustand
- Onboarding / Paywall / Check-in / Gating / Auth / Restore konsistent

### 6. Submission-Ablauf
Vor Submission prüfen:

- alle Pflichtfelder in App Store Connect vollständig
- Build korrekt zugeordnet
- finale Freigabe bewusst entschieden
- Review-Notizen, falls nötig, vorbereitet

## Letzter Device-Sanity-Check

Am Release Day soll zusätzlich ein **letzter echter Device-Sanity-Check** auf dem finalen Build stattfinden.

### Entscheidung
Vor dem Upload wird der finale Build noch einmal auf einem echten Gerät in einem kurzen realen Check geprüft.

Ziel:
- keine Überraschung direkt vor Submission
- letzter Blick auf:
  - App-Start
  - Home
  - Check-in
  - Paywall
  - zentrale Navigation
  - sichtbare Reife

## Go/No-Go-Regel

Der Release Day ist keine reine Verwaltungsaufgabe, sondern ein echter Entscheidungszeitpunkt.

### Go
Submission nur, wenn:
- der Build final konsistent ist
- keine offenen Blocker bestehen
- Store-/Legal-/Monetization-Bausteine stimmig sind

### No-Go
Keine Submission, wenn:
- ein Kernflow kaputt ist
- Monetization unsauber ist
- Legal-/Store-Bausteine fehlen
- der finale Device-Sanity-Check ernsthafte Probleme zeigt

## Was bewusst vermieden wird

- kein chaotischer Last-Minute-Upload
- kein Release trotz bekannter Blocker
- keine rein formale Submission ohne letzte Produktprüfung
- keine zu kurze Minimal-Checklist für ein Produkt mit vielen beweglichen Teilen

## Begründung

Diese Entscheidung wurde getroffen, weil ayo zum Launch mehrere sensible Release-Bereiche gleichzeitig sauber zusammenbringen muss:

- Produktreife
- Monetization
- Gating
- Legal
- App Store Connect
- Auth / Restore
- Notifications
- Regionenstrategie

Eine detaillierte Release-Day-Checkliste reduziert das Risiko, kurz vor dem Ziel durch vermeidbare Auslassungen oder Inkonsistenzen zu scheitern.

## Definition of Done

Ticket 38 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass der Release Day für ayo eine harte letzte Kontrollschranke ist
- dass der Release nicht stattfindet, wenn noch Blocker offen sind
- dass die Release-Day-Checklist bewusst detailliert sein soll
- welche Pflichtblöcke am Release Day geprüft werden müssen
- dass ein letzter echter Device-Sanity-Check auf dem finalen Build stattfindet
- dass Submission erst nach bewusstem Go/No-Go-Entscheid erfolgt



———————————————————


# Ticket 39 – Post-Launch Monitoring / First 48 Hours definieren

## Ergebnis

Für **ayo** wird ein klarer Monitoring-Fokus für die ersten 48 Stunden nach Launch definiert.

Dieser Fokus umfasst nicht nur technische Stabilität, sondern ausdrücklich auch:

- Produktverständnis
- Funnel-Verhalten
- Monetization
- Gating
- qualitative Rückmeldungen
- schnelle Reaktion auf Kernprobleme

## Strategische Entscheidung

Die ersten 48 Stunden nach Launch werden für ayo als aktives Beobachtungsfenster verstanden.

Ziel ist:
- offensichtliche Kernprobleme schnell erkennen
- Monetization- und Gating-Schwächen früh sehen
- Daily-Loop-Signale bewerten
- erste Vertrauens- oder Reifeprobleme nicht zu lange unbemerkt lassen

## Monitoring-Fokus

Das Monitoring für die ersten 48 Stunden besteht aus einer Mischung aus:

- technischem Monitoring
- Produkt-/Funnel-Monitoring
- qualitativer Beobachtung / Rückmeldung

Ayo soll also nach Launch **nicht nur auf Bugs**, sondern auch auf tatsächliche Produktwirkung hin beobachtet werden.

## Rolle von PostHog

Die relevanten Monitoring-Dashboards in **PostHog** müssen für diesen Launch-Fokus bewusst vorbereitet werden.

### Entscheidung
Das Ticket hält ausdrücklich fest, dass die Monitoring-Grundlage in PostHog **noch sauber eingerichtet** werden muss.

Das betrifft insbesondere Dashboards / Ansichten für:

- Monetization-Funnel
- Paywall-Nutzung
- Trial / Purchase / Restore
- Premium-Lock-Interaktionen
- Free vs Premium Einstieg
- ggf. zentrale Daily-Loop-Signale, soweit in V1 bereits messbar

Ziel:
- kein Launch „ins Blaue“
- keine Roh-Events ohne sinnvolle Übersicht
- klare Sicht auf die wichtigsten Signale in den ersten 48 Stunden

## Fokusbereiche in den ersten 48 Stunden

### 1. Produkt- und Funnel-Wirkung
Zu beobachten sind insbesondere:

- Trial-/Paywall-Nutzung
- ob Nutzer den Monetization-Funnel überhaupt sinnvoll durchlaufen
- ob Free vs Premium logisch wirkt
- ob zentrale Produktmomente verstanden werden

### 2. Monetization und Gating
Monetization und Gating sind ein besonders wichtiger Teil des Launch-Monitorings, aber nicht der einzige Fokus.

### Entscheidung
Der Fokus liegt auf einer **Mischung** aus:

- Monetization / Gating
- allgemeiner Produktstabilität
- Kernflow-Funktionalität

Das bedeutet:
- Trial, Kauf, Restore und Locks sind hoch relevant
- gleichzeitig dürfen offensichtliche Probleme in Daily Loop, Auth oder Produktverständnis nicht übersehen werden

### 3. Qualitatives Feedback / erste Reaktionen
Erste qualitative Rückmeldungen sind explizit Teil dieses Tickets.

Dazu gehören:
- erste direkte Nutzerreaktionen
- Rückmeldungen von Testern / engen Personen
- erste App-Store-Reviews
- Hinweise auf Unklarheit, Vertrauensprobleme oder Friktion

### 4. Technische / operative Beobachtung
Auch klassische Launch-Risiken müssen beobachtet werden, z. B.:

- Kauf-/Restore-Probleme
- Login-Probleme
- Fehlerhäufungen
- grobe UX-/Flow-Brüche
- falsch wirkende Premium-Zustände

## Wichtige Event-/Signalbereiche

Für die ersten 48 Stunden sollen insbesondere diese Signale beobachtet werden:

### Monetization
- `trial_screen_viewed`
- `main_paywall_viewed`
- `paywall_dismissed`
- `trial_started`
- `purchase_started`
- `purchase_completed`
- `purchase_failed`
- `restore_attempted`
- `restore_succeeded`
- `restore_failed`
- `entitlement_activated`

### Free vs Premium / Locks
- `premium_lock_tapped`
- `entered_app_as_free_user`
- `entered_app_as_premium_user`

### Weitere relevante Launch-Signale
Soweit in V1 vorhanden oder sinnvoll beobachtbar:
- Check-in-Nutzung
- Reaktion auf Notification-/Reminder-Logik
- Auffälligkeiten im Daily Loop

## Hotfix-Bereitschaft

Für die ersten 48 Stunden nach Launch soll ausdrücklich die Möglichkeit bestehen, **schnelle Hotfix-Entscheidungen** vorzubereiten.

### Entscheidung
Wenn in diesem Zeitraum echte Kernprobleme sichtbar werden, dürfen schnelle Folgeentscheidungen für:

- Hotfixes
- kleine kritische Korrekturen
- kurzfristige Nachbesserungen

aktiv vorbereitet werden.

Ziel:
- echte Launch-Probleme nicht aussitzen
- Vertrauen schützen
- V1 in der frühen Phase stabilisieren

## Was bewusst vermieden wird

- kein Launch ohne vorbereitetes Monitoring-Setup
- kein Fokus nur auf technische Fehler
- kein Ignorieren von Funnel-, Gating- oder Vertrauenssignalen
- keine passive Haltung in den ersten 48 Stunden
- kein Rohdaten-Chaos ohne saubere Dashboard-Struktur

## Begründung

Diese Entscheidung wurde getroffen, weil ayo nach dem Launch in mehreren sensiblen Bereichen gleichzeitig funktionieren muss:

- Produktverständnis
- Daily Loop
- Monetization
- Gating
- Auth / Restore
- Markenvertrauen

Die ersten 48 Stunden sind deshalb kein bloß technischer Nachlauf, sondern ein entscheidendes Beobachtungsfenster für die reale Produktwirkung.

## Definition of Done

Ticket 39 gilt als inhaltlich entschieden, weil festgelegt wurde:

- dass die ersten 48 Stunden aktiv beobachtet werden sollen
- dass das Monitoring technische, produktseitige und qualitative Aspekte umfasst
- dass PostHog-Dashboards dafür bewusst vorbereitet werden müssen
- dass Monetization und Gating besonders wichtig sind, aber nicht der einzige Fokus
- dass erste Reviews und qualitative Rückmeldungen ausdrücklich beobachtet werden sollen
- dass bei echten Kernproblemen schnelle Hotfix-Entscheidungen vorbereitet werden dürfen



———————————————————


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



———————————————————
