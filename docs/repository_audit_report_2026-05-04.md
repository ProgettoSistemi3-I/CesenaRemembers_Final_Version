# Report di audit tecnico repository (2026-05-04)

## Ambito e metodo

- Audit statico dell'intero repository con approfondimento della cartella `lib/` (architettura, SRP/DDD, clean code, coerenza UI, logica applicativa).
- Verifiche automatiche tentate:
  - `flutter analyze`
  - `flutter test`
- Limite ambiente: comando `flutter` non disponibile nella sandbox (quindi verifiche solo statiche/manuali).

## Executive summary

Stato generale: **buono**, con una struttura a layer coerente con DDD/Clean Architecture e separazione ragionevole tra domain/data/presentation. Sono però presenti **punti di miglioramento concreti** su:

1. **Separazione responsabilità UI/controller** in alcune pagine grandi (Map/Profile/Settings).
2. **Coerenza visiva cross-page** non completamente uniforme (login molto custom rispetto a shell interna).
3. **Robustezza logica** su alcuni flussi (delete account, fallback quiz vuoto, stato loading/social).
4. **Pulizia e manutenibilità** (commenti ridondanti, stili inline ripetuti, piccoli anti-pattern).

## 1) Architettura, DDD e dependency flow

### Cosa è coerente

- La struttura del repository rispecchia chiaramente i layer dichiarati nel README (`domain`, `data`, `presentation`, `core`) con responsabilità comprensibili. 
- I repository di dominio sono astratti e implementati nel layer `data`; i use case sono cablati tramite `GetIt` in un entrypoint unico (`injection_container.dart`).
- I controller UI (`ChangeNotifier`) evitano in generale accessi diretti alle implementazioni `data` e passano dai use case.

### Criticità / debito tecnico

- In `injection_container.dart` la registrazione DI è centralizzata ma cresce molto e accoppia fortemente il bootstrap a dettagli concreti; è sostenibile ora, ma va modularizzata (es. `registerDomain()`, `registerData()`, `registerPresentation()`) per evitare regressioni future.
- Alcuni controller di presentazione incorporano anche logica di orchestrazione non banale (es. `SettingsController` con permessi sistema + persistenza + rollback). Questo è accettabile pragmaticamente, ma in ottica DDD/SRP conviene estrarre policy/facade dedicate.

### Valutazione

- **DDD/Clean Architecture:** 7.5/10
- **Direzione dipendenze:** buona
- **Testabilità potenziale:** media (ostacolata da dipendenze di piattaforma e controller molto ricchi)

## 2) SRP e clean code per layer

### Domain layer

- Entità/use case/services risultano concettualmente ben separati.
- `TourRoutePlanner` è piccolo, puro e coeso: buon esempio SRP.

### Data layer

- `QuizRepositoryImpl` ha fallback resiliente utile.
- Rischio logico: se la seed locale non contiene `poiId`, ritorna lista vuota (quiz impossibile), senza fallback di sicurezza alternativo. Andrebbe gestito almeno con un set minimo default.

### Presentation layer

- `MapPage`, `ProfilePage`, `SettingsPage` hanno dimensione e responsabilità elevate; pur con `part` file e controller separati, restano "god widgets" parziali.
- Alcuni commenti sono rumorosi o ridondanti (es. commenti enfatici maiuscoli), poco clean code in ottica manutenzione di team.
- Presenza di `debugPrint` residuali in controller (`settings_controller.dart`, `theme_controller.dart`): non bloccante, ma da uniformare con logger applicativo.

### Valutazione

- **SRP complessivo:** 6.8/10
- **Leggibilità/manutenibilità:** 7/10
- **Pulizia (stile/commenti/dupliche):** 6.5/10

## 3) Coerenza logica dei flussi principali

### Flussi ben gestiti

- **Settings update con rollback**: buona idea UX (ottimistico + restore su errore).
- **Delete account in due fasi**: cancellazione dati applicativi e poi Auth, con tentativo di ripristino stato sessione tramite logout in caso di errore auth.
- **Ricerca social**: debounce e sequence-id per evitare race condition di risposte asincrone stale.

### Rischi logici osservati

1. **Delete account: stato d'errore non propagato chiaramente all'utente** in caso di errore su step Auth dopo successo Firestore (ritorna `false`, ma senza `errorMessage` esplicito nel ramo catch finale).
2. **Social leaderboard loading-state ambiguo**: in UI la classifica vuota mostra spinner; se stream restituisce davvero 0 utenti, sembra loading infinito invece di empty-state.
3. **Quiz fallback vuoto possibile**: se `poiId` non mappato in seed, utente potrebbe ricevere 0 domande.
4. **Theme init**: gestione errori via `debugPrint` in `ThemeController`; meglio convergere su logger centralizzato e stato osservabile.

## 4) Coerenza grafica cross-page

### Coerente

- Nelle pagine interne (Map/Social/Profile/Settings) è evidente una direzione comune: palette olive/tan, card arrotondate, typography semi-bold/bold, bottom sheet con shape morbide.
- Uso consistente di `Theme.of(context).colorScheme` in buona parte della shell.

### Meno coerente

- **Login** è stilisticamente molto più "cinematico" (overlay scuro, tipografia gigante, emblema) rispetto al resto dell'app, più "material-clean". Non è necessariamente un errore, ma rappresenta un salto forte di linguaggio visivo.
- Diversi componenti hanno styling hardcoded locale invece di token centralizzati (`AppPalette` + eventuale set di text/button styles), riducendo uniformità nel lungo periodo.

### Valutazione

- **Coerenza grafica interna shell:** 8/10
- **Coerenza end-to-end (login vs app):** 6.5/10

## 5) Parti inutili / sospette

- Non emergono blocchi chiaramente morti o inutilizzati su larga scala dall'ispezione statica.
- Tuttavia c'è **rumore strutturale**:
  - commentistica verbosa/redundant in alcune pagine;
  - molte costanti stile locali replicate;
  - responsabilità miste UI-orchestrazione.

## 6) Priorità di intervento consigliate

### Priorità alta

1. Gestire fallback quiz quando seed non contiene `poiId` (mai lista vuota).
2. Distinguere esplicitamente `loading` vs `empty` in Social leaderboard.
3. Rendere esplicito messaggio errore in delete-account (ramo errore Auth post-delete Firestore).

### Priorità media

4. Estrarre componenti/presenter per ridurre complessità di `MapPage`, `ProfilePage`, `SettingsPage`.
5. Consolidare stile UI in design tokens/componenti condivisi (button, title, section-card).
6. Uniformare logging (`AppLogger`) eliminando `debugPrint` residuale.

### Priorità bassa

7. Pulizia commenti ridondanti e naming più omogeneo IT/EN.
8. Modularizzare registrazione DI in sotto-funzioni/feature modules.

## 7) Checklist sintetica qualità

- DDD: **Parzialmente rispettato, con buon impianto**.
- SRP: **Discreto, ma migliorabile nella presentation**.
- Clean code: **Buono con alcune eccezioni (rumore/commenti/stili inline)**.
- Coerenza UI: **Buona nella shell, discontinua col login**.
- Robustezza logica: **Generalmente buona, 3-4 edge case importanti da chiudere**.

## Allegato: comandi eseguiti

- `rg --files`
- `rg -n "TODO|FIXME|HACK|print\(|debugPrint\(" lib`
- `flutter analyze` (**fallito: comando non disponibile nell'ambiente**)
- `flutter test` (**fallito: comando non disponibile nell'ambiente**)

