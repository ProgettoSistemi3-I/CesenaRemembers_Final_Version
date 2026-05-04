# Report di Audit Tecnico – CesenaRemembers

Data audit: 2026-05-04
Scope: repository completo, con focus su `lib/`.

## 1) Executive summary

Il progetto mostra una base architetturale buona (separazione Domain/Data/Presentation, DI via `get_it`, entità e use case dedicati), ma non è ancora pienamente allineato a DDD + SRP + Clean Code in modo rigoroso.

Punti forti:
- Stratificazione applicativa leggibile in `lib/domain`, `lib/data`, `lib/presentation`.
- Presenza di repository astratti in domain e implementazioni in data.
- Theme centralizzato (`AppPalette`) con supporto light/dark.
- Mappa scomposta in più parti (`part`) con responsabilità tecniche distinte.

Criticità principali:
- Presenza di marker temporanei/commenti di debug e TODO lasciati in produzione.
- Endpoint backend hardcoded e dipendenza da ngrok in repository dati.
- Alcune classi UI fanno troppe cose (view + orchestration + business flow di dettaglio).
- Test automatizzati praticamente assenti (solo smoke/widget test standard).
- README non documenta l’architettura reale né setup runtime.

## 2) Architettura (DDD/SRP/Clean)

### 2.1 Struttura a layer
Valutazione: **Buona, ma non completa**.

Evidenze positive:
- Contratti nel dominio (`IUserRepository`, `IPoiRepository`, `IQuizRepository`) e use case dedicati.
- Implementazioni concrete in data (`UserRepositoryImpl`, `PoiRepositoryImpl`, `QuizRepositoryImpl`).
- Controller in presentation separati per feature (profilo, social, quiz, impostazioni).

Gap:
- Alcuni servizi e controller in presentation includono logica applicativa non banale che potrebbe migrare in use case dedicati per ridurre accoppiamento UI.
- La composizione DI in un singolo file tende a diventare “god file” con crescita feature.

### 2.2 SRP (Single Responsibility)
Valutazione: **Parzialmente rispettato**.

Osservazioni:
- `MapPage` gestisce cache tile, lifecycle, stato GPS, caricamento POI, stato tour, parte UI e controllo mappa: responsabilità molto ampia.
- `ProfilePage` contiene logica UI + validazioni + orchestrazione salvataggi + modali social; utile estrarre coordinator/service di pagina o view-model più granulari.

### 2.3 Clean Code
Valutazione: **Discreto con problemi di rifinitura**.

Problemi rilevanti:
- Commenti temporanei/annotazioni operative in codice (`AGGIUNTO`, `FIX`, note operative), da rimuovere prima di release.
- Uso di `print` in catch (logging non strutturato).
- TODO operativo su URL ngrok in repository produzione.
- README boilerplate non coerente con il livello reale del progetto.

## 3) Logica applicativa

### 3.1 Autenticazione e bootstrap
- Bootstrap ordinato (`Firebase.initializeApp`, init DI, init tema, avvio app).
- Avvio via `SplashScreen` coerente con flow di gate iniziale.

Rischio:
- Nessuna evidenza qui di fallback robusti in caso di init Firebase fallita (da verificare nei path non ispezionati runtime).

### 3.2 Quiz/Backend integration
Criticità alta:
- `QuizRepositoryImpl` usa URL ngrok hardcoded e TODO esplicito.
- In caso errore API ritorna una domanda “fittizia”: utile per UX offline, ma può mascherare failure sistemiche se non tracciate.
- Mancano timeout/retry policy esplicite e logging osservabile.

### 3.3 Stato social/profilo
- Buona intenzione con controller separati e use case dedicati.
- Presenza di fix commentati indica evoluzione correttiva recente: utile consolidare con test unitari regressione.

## 4) Coerenza grafica/UI tra pagine
Valutazione: **Buona ma con deviazioni**.

Coerenze:
- Palette centralizzata in `AppPalette` con toni coerenti (olive/tan).
- Pattern UI moderni coerenti in diverse pagine (bottom sheet arrotondate, superfici M3).

Incoerenze:
- `LoginPage` usa palette locale duplicata (costanti colore locali) invece di appoggiarsi direttamente al tema centralizzato; rischio drift cromatico futuro.
- Alcune pagine seguono più strettamente il `Theme.of(context)`, altre hanno stili hardcoded più “art direction”.

Raccomandazione:
- Portare i token colore/spaziature/typography in design system unico (theme extensions o constants dedicate) e ridurre hardcode locale.

## 5) Parti inutili / debito tecnico

Possibili elementi da ripulire:
- Commenti temporanei in italiano con indicatori editoriali (`🔴`, `AGGIUNTO`, “Togli import…”).
- README generico Flutter non informativo rispetto al progetto.
- Asset e configurazioni sembrano in ordine, ma non è stato eseguito audit binari deduplicazione (out of scope statico testuale).

## 6) Test, qualità e osservabilità

Stato attuale:
- Non è stato possibile eseguire `flutter analyze`/test nel container perché Flutter SDK non installato.
- Presente `test/widget_test.dart` standard, insufficiente per copertura regressioni reali.

Priorità suggerite:
1. Aggiungere unit test per use case domain (profilo/social/progress).
2. Aggiungere test repository con mock client HTTP/Firebase.
3. Aggiungere test widget per login/profile/settings/map states principali.
4. Introdurre linter severi e CI quality gate.

## 7) Piano azioni prioritizzato

### Alta priorità (bloccanti qualità)
1. Rimuovere endpoint ngrok hardcoded e spostare base URL in configurazione ambiente.
2. Eliminare commenti temporanei e debug markers dal codice.
3. Sostituire `print` con logging strutturato + error reporting.
4. Copertura test minima su flow auth/profile/social/quiz.

### Media priorità
1. Ridurre responsabilità di `MapPage` (estrazione coordinatori/stato).
2. Uniformare token UI nel tema centralizzato (evitare palette locali duplicate).
3. Migliorare README con architettura reale e setup dev/prod.

### Bassa priorità
1. Rifattorizzare file DI in moduli per feature.
2. Definire checklist release (lint/test/remove debug comments).

## 8) Giudizio finale

Il repository è **funzionalmente promettente e ben impostato**, ma **non ancora “production-clean”** secondo standard rigorosi DDD/SRP/Clean Code a causa di configurazioni temporanee, debito di rifinitura e coverage test insufficiente.

Valutazione sintetica:
- Architettura: 7/10
- SRP: 6/10
- Clean code: 6/10
- Coerenza UI: 7/10
- Robustezza logica/testabilità: 5.5/10

