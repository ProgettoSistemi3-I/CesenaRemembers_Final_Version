# Audit repository CesenaRemembers (23 marzo 2026)

## Ambito e metodo
- Revisione statica dell'intero repository, con analisi approfondita della cartella `lib/` (core applicativo).
- Verifica per coerenza architetturale, applicazione DDD, SRP e principi di Clean Code.
- Esecuzione dei controlli automatici disponibili in ambiente.

## Esito sintetico
- **Stato generale:** progetto funzionante a livello strutturale, ma con **aderenza parziale** a DDD/SRP/Clean Code.
- **Giudizio complessivo:** **6/10**.
- **Rischio tecnico medio:** alto accoppiamento in presentation, assenza gestione errori in alcuni flussi async, DI non robusta.

## Punti positivi
1. Presenza di una separazione a livelli (`domain`, `data`, `presentation`) chiara e leggibile.
2. Uso di interfacce repository (`AuthRepository`, `IPoiRepository`) nel domain.
3. Uso di use case dedicati per autenticazione e recupero POI.
4. Iniezione dipendenze centralizzata (GetIt) già introdotta.
5. Entità di dominio semplici e coerenti con lo scopo attuale.

## Criticità principali (priorità alta)

### 1) Composizione DI fragile / potenziale race di registrazione
- In `init()` il repository `AuthRepository` viene registrato **dopo** i use case che lo dipendono.
- GetIt normalmente risolve la dipendenza alla prima richiesta del lazy singleton, ma l'ordine corrente rende la configurazione più fragile e meno esplicita.
- Inoltre per `SignInWithGoogleUseCase` e `SignOutUseCase` manca il check `isRegistered`, a differenza di `IPoiRepository` e `GetPoisUseCase`, introducendo possibile double-registration in scenari di reinizializzazione.

**Impatto:** robustezza e prevedibilità bootstrap.

### 2) SRP violato in `MapPage`
- `MapPage` gestisce contemporaneamente:
  - permessi geolocalizzazione,
  - stream stato servizi GPS,
  - caricamento dati POI,
  - mapping tipo POI -> marker UI,
  - logica lock/rotation/controlli mappa,
  - rendering complesso della UI.
- La classe ha molte responsabilità e stato interno esteso.

**Impatto:** manutenzione difficile, testabilità bassa, incremento rischio regressioni.

### 3) Gestione errori asincroni incompleta
- `_loadPois()` non ha `try/catch`: qualsiasi eccezione del repository può rompere la schermata.
- `_handleLogout()` non gestisce eccezioni di sign-out.
- `_checkPermissionsAndInitialize()` aggiorna stato minimale senza reporting strutturato errori/denied.

**Impatto:** UX fragile e comportamenti silenziosi in errore.

### 4) Incoerenza DDD: domain con anemic model e logica in UI
- L'entità `Poi` è solo contenitore dati; regole (es. colore marker per tipo) sono nella presentation (`MapPage`).
- Se la tassonomia POI cresce, la regola business resta dispersa in widget UI.

**Impatto:** regole dominio non centralizzate, minore evolvibilità.

## Criticità medie

### 5) Data layer ancora stub/non allineato al dominio reale
- `PoiRepositoryImpl` simula una rete con `Future.delayed` e ritorna lista hardcoded.
- L'infrastruttura Firestore è presente nelle dipendenze ma non utilizzata per POI.

**Impatto:** mismatch tra aspettativa architetturale e implementazione reale.

### 6) Parti inutili/commentate
- Blocchi `AppBar` completamente commentati in `ProfilePage` e `SettingsPage`.
- Commenti temporanei `// FIX` lasciati in produzione in `MapPage`.

**Impatto:** rumore cognitivo e riduzione pulizia codice.

### 7) Coerenza naming e lingua
- Mix italiano/inglese in naming (es. `_notifiche`, `_modalitaNotte`, `_posizione` con API e classi inglesi).
- Non è un errore tecnico ma riduce consistenza interna del codice.

## Criticità basse

### 8) Test coverage molto ridotta
- È presente un solo test unitario minimale su `AppUser`.
- Mancano test su use case, repository, gating auth, map logic.

**Impatto:** confidenza bassa nei refactor.

### 9) Documentazione progetto non allineata
- `README.md` è ancora template Flutter standard, non descrive architettura, setup Firebase, flussi login/map.

## Valutazione DDD
- **Bounded context:** implicito, non documentato.
- **Entities/Repositories/UseCases:** presenti ma essenziali.
- **Domain logic placement:** parzialmente errato (regole UI-centric).
- **Conclusione DDD:** base discreta ma ancora **light architecture**, non DDD pieno.

## Valutazione SRP
- Buona nei file domain/usecases.
- Insufficiente in presentation, soprattutto `MapPage`.
- **Conclusione SRP:** rispettato in parte.

## Valutazione Clean Code
- Positivi: leggibilità generale, cartelle chiare.
- Negativi: codice commentato lasciato, commenti legacy, hardcoded values, error handling incompleto, README non curato.
- **Conclusione Clean Code:** medio.

## Raccomandazioni operative (ordine suggerito)
1. Rifattorizzare `MapPage` separando:
   - `MapViewModel/Controller` (stato e logica),
   - `LocationPermissionService`,
   - `PoiMarkerFactory`.
2. Rinforzare DI in `injection_container.dart`:
   - registrare prima i repository, poi use case,
   - usare `isRegistered` coerentemente su tutte le dipendenze.
3. Aggiungere gestione errori con stati espliciti (`loading/success/error`) per POI e logout.
4. Rimuovere codice commentato e commenti `FIX` obsoleti.
5. Portare POI repository verso datasource reale (Firestore) con mapping esplicito DTO->domain.
6. Aggiungere test: use case auth/poi, unit test mapping marker, widget test AuthGate.
7. Aggiornare README con setup reale progetto.

## Comandi eseguiti
- `flutter analyze` -> non eseguibile in questo ambiente (`flutter: command not found`).
- `flutter test` -> non eseguibile in questo ambiente (`flutter: command not found`).
- Verifiche testuali su repository effettuate via shell (`rg`, `nl`, `find`).
