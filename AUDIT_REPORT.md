# Report di Audit Tecnico — CesenaRemembers

Data audit: **14 aprile 2026**  
Ambito: revisione dell'intero repository, con focus principale su `lib/` (architettura, DDD, SRP, Clean Code, coerenza grafica e logica applicativa).

---

## 1) Executive summary

Il progetto mostra una base solida: separazione a layer (`domain`/`data`/`presentation`), uso di use case, tema centralizzato, e diverse scelte corrette lato UX (feedback utente, stream realtime, fallback su geolocalizzazione).

Tuttavia, in audit approfondito emergono criticità strutturali che impattano **DDD/SRP**, correttezza logica e manutenibilità:

- **Violazioni architetturali** (Firebase usato direttamente nel presentation layer, service locator dentro widget/controller invece di dependency injection esplicita).
- **Classi “God object”** (pagine molto grandi con responsabilità miste: UI + stato + business + integrazione servizi).
- **Bug logico di navigazione** (apertura impostazioni da mappa punta alla tab sbagliata).
- **Rischi di correttezza dati** (ricerca username non coerente con il campo normalizzato).
- **Problemi di sicurezza/configurazione** (chiavi/API hardcoded nel codice client).
- **Incoerenze visuali tra pagine** (login page con palette/stile separato dal design system usato nel resto dell'app).

Valutazione complessiva:

- **Qualità generale:** discreta (6.5/10)
- **Aderenza DDD/Clean:** parziale (5.5/10)
- **SRP e modularità UI:** insufficiente in più punti critici (4.5/10)
- **Coerenza grafica cross-page:** buona ma non uniforme (6/10)
- **Rischio manutenzione medio periodo:** medio-alto

---

## 2) Cosa funziona bene

### 2.1 Layering di base presente
- Presenza di entità, repository interface e use case nel domain (`lib/domain/*`).
- Implementazioni concrete nel data layer (`lib/data/*`).
- Controller e pagine separati in presentation (`lib/presentation/*`).

### 2.2 Logica di tour e scoring ben incapsulata
- Routing nearest-neighbor separato (`TourRoutePlanner`).
- Scoring separato (`TourScoringService`) con breakdown esplicito.

### 2.3 Buona attenzione all'esperienza utente
- Snackbar contestuali, fallback di geolocalizzazione, stati di loading.
- Gestione stream profilo e leaderboard con controller dedicati.

---

## 3) Criticità architetturali (DDD, SRP, Clean Code)

## 3.1 Violazioni del confine Presentation ↔ Data/Infrastructure

### Evidenze
- Uso diretto di `FirebaseAuth.instance` in presentation:
  - `settings_controller.dart`
  - `theme_controller.dart`
  - `map_page.dart`
- Uso diretto di `FirebaseFirestore.instance` in `auth_gate.dart`.

### Impatto
- Rompe il principio di inversione delle dipendenze (DIP).
- Rende più difficile testare UI/controller senza Firebase reale.
- Sposta responsabilità infrastrutturali dove dovrebbe esserci solo orchestrazione UI.

### Raccomandazione
- Esporre tutto via use case/repository (es. `GetCurrentUserUseCase`, `WatchUserProfileUseCase`), eliminando riferimenti diretti a Firebase da `presentation/*`.

---

## 3.2 Service locator usato “ovunque” (anti-pattern se abusato)

### Evidenze
- Molti widget e pagine fanno lookup diretto con `sl<...>()`.
- `SocialController` è registrato come **factory**, ma viene richiesto in più punti UI (social page, profile page, public profile page), creando istanze multiple con stream propri.

### Impatto
- Stato potenzialmente incoerente tra pagine.
- Maggior rischio di leak/eventi duplicati (più listener classifica contemporanei).
- Difficoltà nel ragionare sul lifecycle dello stato.

### Raccomandazione
- Per controller con stato condiviso: registrazione singleton/lazySingleton o provider scoped unico per shell.
- Injection tramite costruttori invece di chiamare `sl` dentro i widget.

---

## 3.3 SRP: classi troppo grandi e multi-responsabilità

### Evidenze (dimensioni indicative)
- `map_page.dart` ~822 linee.
- `settings_page.dart` ~743 linee.
- `poi_bottom_sheet.dart` ~711 linee.
- `public_profile_page.dart` ~606 linee.
- `user_repository_impl.dart` ~463 linee.

### Impatto
- Bassa leggibilità e alta complessità cognitiva.
- Regressioni più probabili.
- Testabilità ridotta.

### Raccomandazione
- Scomporre per feature/use case/UI component.
- Spostare logiche di orchestrazione in controller/service dedicati e mantenere le page come composizione visuale.

---

## 4) Correttezza logica: bug e punti fragili

## 4.1 Bug di navigazione: apertura impostazioni manda al tab sbagliato

### Evidenze
- `MainShell`: tab index = `[0:Map, 1:Community, 2:Profilo, 3:Impostazioni]`.
- `ShellNavigationStore.openSettingsAndFocusGpsToggle()` usa `goToTab(2)`.

### Impatto
- Dal flusso “risolvi problema GPS” l'utente viene portato su **Profilo** invece che su **Impostazioni**.

### Fix consigliato
- Cambiare target tab a `3`.

---

## 4.2 Ricerca username probabilmente incoerente con normalizzazione

### Evidenze
- In creazione profilo: salvataggio `username` e `usernameNormalized`.
- In `searchUsers`: query range su campo `username` usando query lowercased.

### Impatto
- Possibili falsi negativi/ordinamenti incoerenti a seconda del casing del valore salvato.

### Fix consigliato
- Cercare su `usernameNormalized` (e salvare sempre normalizzato coerente).

---

## 4.3 Stato errore profilo pubblico: loading potenzialmente infinito

### Evidenze
- In `PublicProfilePage._loadProfile()`, nel `catch` viene mostrato snackbar ma non viene settato `_isLoading = false`.

### Impatto
- Se il caricamento fallisce, la schermata può restare bloccata nel loader.

### Fix consigliato
- Gestire stato errore esplicito (`_isLoading=false` + messaggio/retry UI).

---

## 4.4 Mutazione diretta di liste del dominio in UI

### Evidenze
- In `PublicProfilePage._onFriendAction`, aggiornamento ottimistico muta direttamente le liste del `UserProfile` (`friends`, `sent/receivedFriendRequests`).

### Impatto
- Possibili incoerenze se la richiesta backend fallisce o arriva update concorrente dallo stream.

### Fix consigliato
- Modellare stato UI separato/immutabile o usare copie difensive e rollback robusto.

---

## 5) Sicurezza e configurazione

## 5.1 Segreti/API key hardcoded lato client

### Evidenze
- Google clientId hardcoded in `FirebaseAuthRepository`.
- MapTiler API key hardcoded in `OfflineMapRepository`.
- Chiave API map style dark hardcoded in `MapPage` URL Stadia.

### Impatto
- Chiavi esposte, facile estrazione da APK/IPA.
- Rotazione chiavi difficile.

### Raccomandazione
- Spostare in configurazione ambiente/proxy backend dove possibile.
- Limitare per dominio/bundleId e ruotare periodicamente.

---

## 6) Coerenza grafica tra pagine

## 6.1 Punti positivi
- `AppPalette` e temi light/dark centralizzati sono presenti e usati in gran parte delle schermate principali.
- Componenti social/profile condividono identità cromatica (olive/tan/moss).

## 6.2 Incoerenze rilevate
- `LoginPage` definisce una palette locale autonoma (costanti private) e uno stile visual completamente differente dal resto dell'app, invece di appoggiarsi a `AppPalette`/`ThemeData`.
- Terminologia mista IT/EN nella navigation (`Community` vs `Mappa/Profilo/Impostazioni`).

### Impatto
- Percezione di prodotto meno uniforme.
- Maggiore costo di manutenzione visuale.

### Raccomandazione
- Portare login dentro design system unico (token colori, tipografia, spacing).
- Uniformare naming localizzato.

---

## 7) Parti inutili o migliorabili

- Metodi di serializzazione potenzialmente non usati (`PoiModel.fromJson/toJson`, `UserModel.toJson`) da verificare rispetto a roadmap futura.
- Commenti molto verbosi/storici in alcune classi: utili in fase sviluppo, ma andrebbero asciugati in ottica clean code per ridurre rumore.

---

## 8) Piano di remediation prioritizzato

## Priorità alta (subito)
1. Correggere bug tab GPS → Settings.
2. Rimuovere Firebase direct calls dal presentation layer (almeno nei punti più critici: AuthGate, SettingsController, MapPage, ThemeController).
3. Rendere coerente la ricerca username su campo normalizzato.
4. Eliminare hardcoded keys o almeno metterle sotto config controllata.

## Priorità media
5. Ridurre dimensione e responsabilità di `MapPage`, `SettingsPage`, `PoiBottomSheet`, `PublicProfilePage`.
6. Stabilizzare lifecycle di `SocialController` (evitare factory multipla se lo stato deve essere condiviso).

## Priorità bassa
7. Consolidare design system della LoginPage.
8. Pulizia metodi/commenti non necessari.

---

## 9) Conclusione

Il repository è già funzionale e ben avviato, ma per essere davvero “clean” in senso DDD/SRP serve un refactoring mirato sui confini architetturali e sulla scomposizione delle feature UI più grandi. Le criticità principali non sono tanto di “feature mancanti”, quanto di **governance del codice**: dipendenze, responsabilità e coerenza tra layer.

Con gli interventi prioritari proposti, il progetto può passare in tempi relativamente brevi da una base buona a una base molto robusta e manutenibile.
