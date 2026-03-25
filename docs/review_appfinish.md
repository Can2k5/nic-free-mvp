Master-Roadmap bis 100% Release-Reife
Phase 0 — Produktentscheidung festzurren
Ziel: Bevor du Code polierst, muss klar sein, was verkauft wird.
0.1 Monetarisierungsmodell final definieren
Status: Launch-Blocker Aufwand: Kurz: 1–2h
Tickets:
	•	Entscheide: Free + Premium oder Trial + sofort bezahlte Vollversion
	•	Lege fest:
	◦	monatlicher Preis
	◦	jährlicher Preis
	◦	Trial-Länge
	◦	ob Annual standardmäßig hervorgehoben wird
	•	Definiere schriftlich:
	◦	Welche Features sind Free?
	◦	Welche Features sind Premium?
Empfehlung für ayo:
	•	Free: Basis-Home, 1–2 Rescue-Tools, einfacher Progress, begrenzte Marker
	•	Premium: volle Rescue-Library, kompletter Progress, alle Marker/Achievements, tieferer Daily Support
Warum zuerst: Ohne das kannst du weder die Paywall noch das Gating noch die App-Store-Message sauber bauen.

0.2 Produktpositionierung in einem Satz festlegen
Status: Launch-Blocker Aufwand: Kurz: 30–60 min
Ticket:
	•	Schreibe 3 Varianten für den Kernsatz von ayo
	•	Wähle 1 finale Produktbotschaft für:
	◦	Paywall
	◦	App Store Subtitle
	◦	Hero-Screenshots
	◦	Onboarding-Ton
Empfohlene Richtung:
“ayo helps you get through cravings in the moment and stay nicotine-free with calm daily support.”
Nicht mehr als “quit tracker”. Deine stärkste Waffe ist Craving Rescue + emotional guidance, nicht nur Tracking.

Phase 1 — Commercial & Monetization
Ziel: Aus einem schönen Produkt ein messbares, kaufbares System machen.
1.1 RevenueCat produktionsreif machen
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	Test-Konfiguration prüfen und auf Production-Setup umstellen
	•	Entitlement-Namen final prüfen
	•	Offerings sauber benennen
	•	Trial-Darstellung mit echten Produkten abgleichen
	•	Restore-Flow einmal komplett auf realem Gerät testen
Definition of done:
	•	Products kommen sauber von RevenueCat
	•	Keine Test-/Dummy-Konfiguration mehr in Release-Build
	•	Kauf, Restore, Cancel, Failure verhalten sich korrekt

1.2 Paywall neu konzipieren
Status: Launch-Blocker Aufwand: Mittel bis Groß: 1–2 Tage
Tickets:
	•	Neue Paywall-Hierarchie definieren:
	◦	klare Headline
	◦	3 echte Nutzenpunkte
	◦	Preisanker
	◦	Trial-Transparenz
	◦	Vertrauen/Cancel-Hinweis
	•	Jährliches Abo visuell bevorzugen
	•	CTA klar formulieren
	•	“Not now” / Skip-Logik bewusst gestalten
	•	Restore sichtbar, aber sekundär
	•	Trial-Text an echten Store-Status anpassen
Für ayo sollte die Paywall nicht “allgemein motivierend”, sondern situativ nützlich verkaufen:
	•	get through cravings
	•	stay grounded
	•	track real progress
	•	build a quit routine

1.3 Premium-Gating systematisch einbauen
Status: Launch-Blocker Aufwand: Groß: 1–3 Tage
Tickets:
	•	Zentrale Liste aller premium-relevanten Features erstellen
	•	Jedes betroffene View/Flow mit isProUser sauber absichern
	•	Definieren:
	◦	harte Sperre
	◦	Vorschau mit Lock
	◦	Upsell-Moment
	•	Gating nicht nur optisch, sondern funktional umsetzen
Empfohlene Gating-Punkte für ayo:
	•	zusätzliche Rescue-Flows
	•	tiefere Progress-Ansichten
	•	bestimmte Marker/Achievements
	•	erweiterte Daily Guidance
	•	evtl. historische Insights
Definition of done:
	•	Free-User kann die App sinnvoll nutzen
	•	Premium-Nutzen ist klar spürbar
	•	Kein verwirrendes “eigentlich ist alles frei”

1.4 Paywall-Platzierung final entscheiden
Status: Launch-Blocker Aufwand: Kurz bis Mittel: 2–4h
Tickets:
	•	Entscheiden, ob die Paywall:
	◦	am Ende des Onboardings bleibt
	◦	oder erst nach dem ersten echten Value-Moment erscheint
	•	Falls am Ende des Onboardings:
	◦	Free-Pfad explizit sauber gestalten
	•	Falls später:
	◦	Onboarding um 1 klaren “aha”-Moment ergänzen
Empfehlung:
	•	Für echten Monetarisierungstest ist Onboarding-Ende okay, aber nur wenn der Free-Pfad klar und bewusst ist.

1.5 Monetization Analytics ergänzen
Status: Launch-Blocker Aufwand: Mittel: 0.5 Tag
Tickets:
	•	Events ergänzen:
	◦	paywall_dismissed
	◦	trial_started
	◦	restore_attempted
	◦	restore_succeeded
	◦	purchase_failed
	◦	entitlement_activated
	•	Event-Properties ergänzen:
	◦	source
	◦	offering_id
	◦	package_type
	◦	screen_context
Damit kannst du später wirklich lernen, ob das Geschäftsmodell funktioniert.

Phase 2 — Technical Hardening & Code-Quality
Ziel: Release-Build ohne peinliche MVP-Spuren.
2.1 Placeholder-/Debug-Cleanup
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	Alle Placeholder-Texte entfernen
	•	“coming soon” bewusst prüfen
	•	Debug-Ausgaben bereinigen
	•	interne Test-Entrypoints entfernen
	•	Namensinkonsistenzen beheben
	◦	Ayo
	◦	Nic Free MVP
	◦	sonstige Altspuren
Definition of done:
	•	Kein Screen fühlt sich intern/unfertig an
	•	Kein Text wirkt nach Testbuild

2.2 Edge-Case-Audit und Fehlerzustände
Status: Launch-Blocker Aufwand: Groß: 1–2 Tage
Tickets:
	•	Kauf abbrechen
	•	Kauf fehlgeschlagen
	•	Restore ohne Abo
	•	Restore mit Abo
	•	App ohne Internet
	•	Google/Apple Login Fehler
	•	App-Restart mitten im Onboarding
	•	App-Restart nach Kauf
	•	App-Neuinstallation / lokale Datenlage
Jeder Fall braucht:
	•	technische Korrektheit
	•	verständliche User Message
	•	kein Dead End

2.3 Architektur-Härtung
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	Persistenz-Pfade prüfen
	•	AppState-Verantwortlichkeiten bereinigen
	•	Onboarding-Abschlusszustand robust machen
	•	Subscription-Status beim App-Start zuverlässig refreshen
	•	Fail-safe definieren, wenn RevenueCat nicht sofort antwortet

2.4 Logging / QA-Schalter für Release
Status: Launch-Bonus Aufwand: Kurz: 1–2h
Tickets:
	•	Logging-Level für Debug vs Release trennen
	•	interne Test-Hooks entfernen oder absichern
	•	ggf. Feature-Flags grob dokumentieren

Phase 3 — Legal & Compliance
Ziel: Kein vermeidbares Review-Risiko.
3.1 Privacy Policy und Terms final live stellen
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	finale Privacy Policy erstellen
	•	finale Terms erstellen
	•	echte URLs veröffentlichen
	•	In-App-Links testen
	•	App Store Connect URLs ebenfalls hinterlegen
Wichtig, weil deine App Auth, Analytics und Subscription nutzt. Das muss sauber sichtbar sein. Das Architekturpapier zeigt klar, dass Auth über Firebase und Analytics über PostHog läuft; das gehört konsistent in die Rechtstexte.

3.2 Health-/Addiction-Messaging absichern
Status: Launch-Blocker Aufwand: Kurz bis Mittel: 2–4h
Tickets:
	•	Copy prüfen auf unzulässige medizinische Versprechen
	•	App Store Beschreibung so formulieren, dass ayo als Support-/Companion-App erscheint
	•	Disclaimer festlegen:
	◦	keine medizinische Behandlung
	◦	kein Ersatz für professionelle Hilfe

3.3 Account-/Data-Transparency prüfen
Status: Launch-Blocker Aufwand: Mittel: 0.5 Tag
Tickets:
	•	In Settings klar sagen:
	◦	welche Daten lokal gespeichert werden
	◦	welche Drittanbieter genutzt werden
	◦	was Login bedeutet
	•	ggf. Delete-account / sign-out / data-reset sauber führen

3.4 Sign in with Apple / Google final Review-Check
Status: Launch-Blocker Aufwand: Kurz: 1–2h
Tickets:
	•	Apple-Login real testen
	•	Google-Login real testen
	•	Copy & Button-Reihenfolge reviewen
	•	Email-Link weiter verborgen lassen, wenn nicht final geprüft

Phase 4 — User Retention & Engagement
Ziel: ayo darf nicht nur gut aussehen, sondern wieder geöffnet werden.
4.1 Daily Loop final definieren
Status: Launch-Blocker Aufwand: Mittel: 0.5 Tag
Tickets:
	•	Den täglichen Kernloop schriftlich fixieren:
	◦	Trigger
	◦	Handlung
	◦	Belohnung
	•	Für ayo empfehle ich:
	◦	open app
	◦	daily check-in / focus
	◦	optional rescue
	◦	visible progress reinforcement
Ohne diesen Schritt wird jedes Engagement-Feature zufällig.

4.2 Home klarer auf tägliche Handlung ausrichten
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	genau 1 primäre Tagesaktion definieren
	•	sekundäre Aktionen visuell abwerten
	•	Home so anpassen, dass der User sofort weiß:
	◦	Was heute tun?
	◦	Was bringt’s?
	◦	Was ist mein Status?

4.3 Notifications / local reminders einbauen
Status: Launch-Blocker Aufwand: Groß: 1–2 Tage
Tickets:
	•	lokale Notifications implementieren
	•	Permission-Request sinnvoll timen
	•	2–3 Reminder-Arten definieren:
	◦	daily check-in reminder
	◦	encouragement after onboarding
	◦	re-entry after inactivity
	•	Settings-Toggle einbauen
	•	Reminder-Copy markenkonform schreiben
Für V1 reicht local notifications. Push brauchst du noch nicht.

4.4 Onboarding-Finish stärker machen
Status: Launch-Bonus Aufwand: Mittel: 0.5 Tag
Tickets:
	•	letzter Onboarding-Moment klarer emotionaler Abschluss
	•	Übergang zu Home sauberer
	•	nach Kauf / ohne Kauf jeweils eigener saubere Landing-Zustand

4.5 Progress-Reinforcement verbessern
Status: Launch-Bonus Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	Milestones sichtbarer machen
	•	erste kleine Erfolge schneller spürbar machen
	•	Marker/Achievements an tägliche Nutzung koppeln

Phase 5 — Store Readiness
Ziel: Ein Listing, das Vertrauen und Downloads erzeugt.
5.1 App-Store-Positionierung festlegen
Status: Launch-Blocker Aufwand: Mittel: 0.5 Tag
Tickets:
	•	finalen App Name bestätigen
	•	Subtitle schreiben
	•	3 Value-Pillars definieren
	•	Kategorie festlegen
	•	englisch-only vs später mehrsprachig bewusst entscheiden
Da die App aktuell englisch ist, ist ein internationaler Erstlaunch grundsätzlich möglich. Aber entscheide es bewusst, nicht zufällig.

5.2 Screenshots & App Preview erstellen
Status: Launch-Blocker Aufwand: Groß: 1–2 Tage
Tickets:
	•	Screenshot-Storyline definieren
	•	5–7 Kernscreens auswählen
	•	kurze Benefit-Headlines je Screenshot schreiben
	•	Paywall nicht als Hauptmotiv verwenden
	•	Rescue als Differenzierungsmerkmal stark zeigen
Empfohlene Reihenfolge:
	1	calm quit support
	2	get through cravings
	3	stay on track daily
	4	see real progress
	5	reflect and recover from slips
	6	private, local-first feel
	7	optional premium support

5.3 App Description, Keywords, Promo Text
Status: Launch-Blocker Aufwand: Mittel: 0.5 Tag
Tickets:
	•	Kurzbeschreibung schreiben
	•	Langbeschreibung schreiben
	•	Keywords definieren
	•	Review-sichere Health-Sprache verwenden

5.4 App Icon finalisieren
Status: Launch-Blocker Aufwand: Kurz bis Mittel: 2–4h
Tickets:
	•	finalen Icon-Stand auswählen
	•	Kontrast / Klarheit auf kleinem Maßstab prüfen
	•	gegen Apple-UI-Kontext testen

5.5 App Store Connect Setup
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	App anlegen / Bundle prüfen
	•	Preise & Availability setzen
	•	Subscription-Produkte verbinden
	•	Privacy-Daten ausfüllen
	•	Support URL
	•	Privacy URL
	•	Terms URL
	•	Altersfreigabe
	•	Export Compliance prüfen

Phase 6 — Final QA & Deployment
Ziel: Der Build muss sich wie ein fertiges Produkt verhalten.
6.1 Device QA Matrix
Status: Launch-Blocker Aufwand: Groß: 1–2 Tage
Tickets:
	•	Test auf mindestens:
	◦	kleines iPhone
	◦	mittleres iPhone
	◦	großes iPhone
	•	Testfälle:
	◦	kompletter Onboarding-Flow
	◦	Kauf
	◦	Restore
	◦	Login Apple
	◦	Login Google
	◦	Notification permission
	◦	Free-User-Nutzung
	◦	Premium-User-Nutzung
	◦	Offline-Reaktion

6.2 TestFlight Soft Pass
Status: Launch-Blocker Aufwand: Mittel: 0.5–1 Tag
Tickets:
	•	internen TestFlight-Build erstellen
	•	1–3 Tage nur reale Nutzung simulieren
	•	letzte Copy-/Spacing-/Logic-Bugs sammeln
	•	High-severity Bugs fixen

6.3 Release Candidate bauen
Status: Launch-Blocker Aufwand: Kurz: 1–2h
Tickets:
	•	Versionsnummer setzen
	•	Build-Nummer setzen
	•	Release Notes vorbereiten
	•	letzten Archive-Build erzeugen

Empfohlene Umsetzungsreihenfolge als Sprints
Sprint 1 — Geschäftsmodell schließen
Dauer: 2–4 Tage
	•	0.1 Monetarisierungsmodell
	•	0.2 Positionierung
	•	1.1 RevenueCat Production
	•	1.2 neue Paywall
	•	1.3 echtes Gating
	•	1.4 Paywall-Platzierung
	•	1.5 Monetization Analytics
Sprint 2 — Release-Härtung
Dauer: 2–4 Tage
	•	2.1 Cleanup
	•	2.2 Edge Cases
	•	2.3 Architektur-Härtung
	•	3.1 Privacy/Terms live
	•	3.2 Health-Messaging
	•	3.3 Data-Transparency
	•	3.4 Auth Review
Sprint 3 — Retention + Store
Dauer: 2–4 Tage
	•	4.1 Daily Loop
	•	4.2 Home-Fokus
	•	4.3 Notifications
	•	4.4 Onboarding-Finish
	•	4.5 Progress-Reinforcement
	•	5.1 Positionierung Store
	•	5.2 Screenshots
	•	5.3 Description/Keywords
	•	5.4 Icon
	•	5.5 App Store Connect
Sprint 4 — Final QA
Dauer: 1–3 Tage
	•	6.1 Device QA
	•	6.2 TestFlight
	•	6.3 Release Candidate
Launch-Blocker vs Launch-Bonus Übersicht
Launch-Blocker
	•	Pricing/Freemium-Modell final
	•	Paywall final
	•	Feature-Gating final
	•	RevenueCat production-ready
	•	echte Privacy Policy/Terms URLs
	•	Health-/Claims-Copy absichern
	•	Reminder-System mindestens lokal
	•	Daily Loop definieren
	•	Store Listing final
	•	Device QA + TestFlight
	•	Placeholder/Debug-Reste entfernen
Launch-Bonus
	•	stärkeres Onboarding-Finish
	•	schönere Progress-Reinforcement
	•	Email-Link-Login aktivieren
	•	tiefere Marker/Achievements
	•	erweiterte Analytics nach Launch
	•	mehrsprachige Version
Checkliste für den Tag des Release
Produkt & Build
	•	Versionsnummer final
	•	Buildnummer final
	•	Release-Build ohne Debug-Reste
	•	App Name überall konsistent als Ayo
	•	keine Placeholder-Texte mehr
	•	kein interner Test-Entry mehr sichtbar
Monetarisierung
	•	RevenueCat live geprüft
	•	richtige Offering-Zuordnung
	•	Preise in App Store Connect korrekt
	•	Trial stimmt mit UI-Text überein
	•	Kauf auf echtem Gerät getestet
	•	Restore auf echtem Gerät getestet
	•	Free/Premium-Zugriff korrekt
Legal & Compliance
	•	Privacy Policy URL live
	•	Terms URL live
	•	Support URL live
	•	App Privacy Angaben in App Store Connect ausgefüllt
	•	keine problematischen Health Claims
	•	Sign in with Apple funktioniert
Retention
	•	lokale Notifications funktionieren
	•	Permission-Flow getestet
	•	Reminder Settings funktionieren
	•	Daily Loop im Home klar sichtbar
Store Assets
	•	finales Icon
	•	alle Screenshot-Größen
	•	Subtitle final
	•	Description final
	•	Keywords final
	•	Kategorie final
	•	Altersfreigabe geprüft
QA
	•	kompletter Onboarding-Flow getestet
	•	Login Apple getestet
	•	Login Google getestet
	•	Offline-Verhalten getestet
	•	App-Neustart während kritischer Flows getestet
	•	keine Blocker-Crashes
Analytics
	•	paywall_viewed feuert
	•	trial_started feuert
	•	purchase_completed feuert
	•	craving_rescue_started/completed feuert
	•	onboarding_completed feuert
	•	home_viewed feuert
Der klügste nächste Schritt ist jetzt, diese Roadmap in ein konkretes Ticket-Board mit Priorität P0/P1/P2 umzuwandeln, damit du sie direkt abarbeiten kannst.
