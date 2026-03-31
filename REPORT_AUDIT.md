# Report di revisione tecnica – CesenaRemembers

Data revisione: 31 marzo 2026  
Ambito: intero repository, con focus su `lib/` (architettura, DDD, SRP, clean code, coerenza UI)

---

## 1) Executive summary

Il progetto è **funzionante e ben presentato lato UI**, con una direzione visuale chiara e una buona separazione *minima* tra livelli (`domain`, `data`, `presentation`).

Tuttavia, dal punto di vista architetturale, emergono criticità importanti:

- **SRP fortemente violato** in `MapPage` (file monolitico, logica business + UI + geolocalizzazione + stato tour + quiz nello stesso widget).
- **DDD solo parzialmente applicato**: il dominio esiste, ma molta logica core è nel layer `presentation` invece che in use case/service dedicati.
- **Presenza di dati e testi placeholder/demo** in aree core (POI hardcoded, testi “Inserisci qui...”, email fittizia).
- **Coerenza grafica buona tra pagine interne**, ma con un **salto stilistico netto** fra login e shell autenticata.
- **Testing insufficiente**: presente solo un test unitario minimale su `AppUser`.

Valutazione sintetica:

- DDD: **5.5/10**
- SRP: **4.5/10**
- Clean Code: **6/10**
- Coerenza grafica: **7/10**
- Prontezza produzione: **5/10**

---

## 2) Aspetti positivi

1. **Struttura a layer già impostata** (`domain`, `data`, `presentation`) e uso di DI via `GetIt`.
2. **Uso corretto di stream auth** con `AuthGate` per routing reattivo login/app.
3. **UI curata** in Profilo/Impostazioni/Map: componentizzazione locale, palette coerente, animazioni gradevoli.
4. **Gestione base permessi posizione** presente sia a bootstrap sia in pagina mappa.

---

## 3) Criticità architetturali (DDD / SRP)

### 3.1 `MapPage` troppo grande e multi-responsabilità (critico)

`lib/presentation/pages/map_page.dart` contiene in un unico file:
- modello tour (`TourStop`, `QuizQuestion`),
- dataset di dominio (`_allStops`),
- algoritmo di ordinamento percorso (`_sortStopsGreedy`),
- logica tour (start/arrivo/avanzamento/timer/tracking),
- gestione geolocalizzazione e permessi,
- rendering mappa,
- rendering card/fab/bottom sheet,
- logica quiz.

Questo rende la pagina difficile da testare, mantenere e riusare.

**Impatto**: alto costo evolutivo, rischio regressioni, testabilità bassa.

### 3.2 Logica business nel layer UI (critico)

Logiche che dovrebbero stare in use case/service dedicati sono in presentation:
- scelta percorso (greedy nearest-neighbor),
- stato tour e timer,
- criterio arrivo (`_arrivedThresholdMeters`),
- scoring quiz.

Di fatto il dominio “vero” del tour non è nel layer `domain`.

### 3.3 Dominio POI incompleto / non allineato

Esistono repository/use case per POI, ma il repository è demo con lista hardcoded e ritardo artificiale; inoltre il tour usa un dataset separato (`_allStops`) invece dei POI caricati dal repository.

**Conseguenza**: doppia fonte dati, possibile incoerenza tra mappa POI e tappe tour.

### 3.4 Use case con valore limitato

Alcuni use case sono solo thin wrapper senza logica (es. `GetPoisUseCase`, auth use cases). Non è un errore in sé, ma con il dominio attuale non aggiungono reale valore architetturale.

---

## 4) Clean Code – analisi dettagliata

### 4.1 Duplicazione design tokens

Le stesse costanti colore sono replicate in più pagine (`login`, `map`, `profile`, `settings`) invece di essere centralizzate in un tema/design system.

**Effetto**: rischio drift stilistico e manutenzione più costosa.

### 4.2 Hardcoded estesi

Presenti molti valori hardcoded:
- coordinate, soglie e stringhe in mappa/tour,
- username/nome/stats nel profilo,
- testi placeholder nelle impostazioni,
- versione app hardcoded nella UI,
- clientId Google e config Firebase in codice.

Non tutti sono sbagliati, ma la quantità è elevata per una base scalabile.

### 4.3 Naming e convenzioni

- `IPoiRepository` usa prefisso `I` (convenzione da altri ecosistemi), meno idiomatico in Dart.
- In alcune zone naming e commenti sono ottimi, in altre più “demo/prototipo”.

### 4.4 Complessità ciclom. percepita alta

`MapPage` e `SettingsPage` hanno molte diramazioni e funzioni UI con responsabilità aggregate. Mancano boundary chiari tra stato, logica, rendering.

---

## 5) Parti inutili / debolmente utili (stato attuale)

1. **`README.md` generico Flutter**: non documenta progetto, setup reale, architettura, limiti.
2. **Test coverage quasi nulla**: un solo test di entity non copre casi critici.
3. **Contenuti placeholder** nelle impostazioni (“Inserisci qui...”, `supporto@tuapp.it`) non pronti per rilascio.
4. **Doppia modellazione POI/TourStop** senza mapping esplicito condiviso.

---

## 6) Coerenza grafica tra pagine

### 6.1 Coerenza interna shell autenticata: buona

`Map`, `Profile`, `Settings` condividono:
- stessa palette base (cream/olive/tan),
- linguaggio di card arrotondate + ombre leggere,
- tipografia e densità visiva simili,
- uso coerente di bottom sheet e micro-interazioni.

### 6.2 Punto di attenzione: login vs resto app

La login ha un’estetica dark/cinematic, mentre il resto app è chiaro/editoriale. La scelta può essere voluta (momento “immersivo”), ma oggi appare come cambio netto di brand-experience.

**Suggerimento UX**: introdurre 1-2 elementi ponte (token, shape, typography cues) o un onboarding intermedio per rendere più graduale la transizione.

---

## 7) Valutazione DDD/SRP per layer

### Domain
- ✅ Entità e interfacce presenti.
- ⚠️ Dominio applicativo reale (tour/quiz/percorso) quasi assente nel layer.

### Data
- ✅ Repository auth concreto.
- ⚠️ Repository POI demo/non persistente.

### Presentation
- ✅ UI ricca e usabile.
- ❌ Troppa logica core nel widget, soprattutto in `MapPage`.

---

## 8) Rischi principali

1. **Scalabilità funzionale bassa** della mappa/tour (ogni feature nuova aumenta complessità in modo non lineare).
2. **Regressioni frequenti** in assenza di test su logica tour/quiz/permessi.
3. **Incoerenza dati** (POI repository vs tappe tour statiche).
4. **Difficoltà onboarding nuovi sviluppatori** per file troppo estesi e mixed concerns.

---

## 9) Piano raccomandato (priorità)

### Priorità alta (subito)
1. Estrarre da `MapPage`:
   - `tour_engine` (stato tour, arrivo, timer, avanzamento),
   - `route_planner` (sort/strategy),
   - `quiz_controller`.
2. Unificare fonte dati POI/tappe (single source of truth).
3. Introdurre test unitari su:
   - sorting percorso,
   - transizioni stato tour,
   - scoring quiz.

### Priorità media
4. Centralizzare design tokens/theme in un modulo condiviso.
5. Ripulire placeholder e testi demo in settings/profile.
6. Aggiornare `README` con setup reale, architettura e flussi principali.

### Priorità bassa
7. Migrare naming a convenzioni Dart più idiomatiche.
8. Valutare gestione stato (es. ViewModel/Cubit) per pagine complesse.

---

## 10) Verdetto finale

Il repository ha una **base promettente** e una **UI già di buon livello**, ma per essere “coerente, corretta e clean” in senso ingegneristico serve una rifinitura architetturale importante, soprattutto nella mappa.

In sintesi:
- **buon prototipo evoluto**,
- **non ancora solido per crescita strutturata** senza refactor mirato.
