# Report tecnico approfondito – Cesena Remembers (repo audit)

Data analisi: 17 maggio 2026  
Ambito: intero repository con focus su `lib/` (DDD/SRP/Clean Code), coerenza logica, coerenza grafica cross-page, codice inutile/rumore.

## 1) Executive summary

Valutazione complessiva: **buona base architetturale**, con layering coerente e separazione `domain/data/presentation` già presente.  
Il progetto è vicino a una Clean Architecture pragmatica, ma ha **alcuni punti critici** che impattano correttezza runtime e manutenibilità.

### Priorità alta (da correggere prima)
1. **Possibile bug lifecycle/dispose**: un controller registrato come singleton DI viene `dispose()`-ato dalla pagina Settings, con rischio di riuso successivo di oggetto già disposed.  
2. **Error handling incompleto in bootstrap app**: inizializzazione Firebase/DI senza fallback visivo o gestione errori utente.  
3. **Lieve incoerenza i18n**: stringa “Community” hardcoded in shell/social (non localizzata), mentre altrove si usa `AppLocalizations`.

### Priorità media
4. **Rumore da commenti temporanei/marker (`🔴`)** in file di produzione.
5. **Alcune responsabilità UI molto dense** (pagine corpose con logica view-state e costruzione widget molto estesa), che riducono SRP a livello di widget.

---

## 2) Metodo di verifica

- Ispezione statica dei layer principali (`domain`, `data`, `presentation`, bootstrap DI).
- Verifica pattern DDD/SRP/Clean Code su dipendenze e responsabilità.
- Verifica coerenza UI tramite lettura delle pagine principali e uso tema/localizzazione.
- Ricerca di segnali di codice temporaneo/inutile.
- Tentativo di quality gate automatico (`flutter analyze`, `flutter test`) non eseguibile in ambiente per assenza SDK Flutter.

---

## 3) Architettura (DDD / Clean Architecture)

## 3.1 Punti positivi

- Struttura a layer dichiarata e rispettata a livello macro (`domain`, `data`, `presentation`, `core`).
- Repository interfaces nel domain e implementazioni nel data.
- Use case specifici per capability applicative (auth, POI, quiz, social, profile, preferences).
- Dependency Injection centralizzata con `get_it`.

**Giudizio**: la direzione architetturale è corretta.

## 3.2 Osservazioni critiche

- In alcuni punti la presentation mantiene logica non banale (es. orchestrazione stato + costruzione UI molto ampia nella stessa pagina), che rende più difficile testare e mantenere singole responsabilità.
- Alcuni controller sono creati direttamente nella pagina invece di essere sempre risolti via DI (scelta legittima, ma non uniforme).

**Impatto**: medio (più manutenzione che bug immediato).

---

## 4) SRP e qualità del codice

## 4.1 SRP nel layer presentation

- `MapPage`, `ProfilePage`, `SettingsPage` sono ben organizzate per feature, ma rimangono file molto densi: animazioni, orchestrazione stato, wiring controller, widget tree esteso.
- Buona pratica osservata: in alcune pagine c’è split in `part` (es. sections/view), che aiuta la leggibilità.

**Valutazione SRP**: discreta ma migliorabile (specialmente per testabilità e leggibilità a lungo termine).

## 4.2 Clean Code

### Buono
- Naming generalmente chiaro.
- Uso di `late final`, `ValueNotifier`, controller dedicati, stream/listener gestiti.
- Riduzione dell’accesso diretto a FirebaseAuth nella UI (uso use case/controller).

### Da migliorare
- Presenza di commenti temporanei/di working history (`🔴`) in file core/presentation.
- Alcune parti con formattazione e spacing non uniforme (sintomo di refactor successivi non rifiniti).

---

## 5) Correttezza logica (bug/rischi)

## 5.1 Critico – lifecycle controller singleton

`SettingsUiController` viene registrato come **lazy singleton** nel container DI, ma la `SettingsPage` lo `dispose()` nel proprio `dispose()`.  
Se la pagina viene ricreata e il singleton riutilizzato, si rischia chiamata su `ChangeNotifier` già disposed (errore runtime quando notifica o ascolta).

**Rischio**: alto.  
**Azione consigliata**: non fare dispose del singleton dalla pagina; delegare lifecycle al container o registrarlo factory/scoped invece di singleton.

## 5.2 Medio – bootstrap senza fallback error UI

Nel `main` l’inizializzazione Firebase/DI è sequenziale e senza `try/catch` con fallback UX dedicato. In caso di errore di init, l’app può fallire in avvio senza percorso utente chiaro.

**Rischio**: medio.

## 5.3 Medio – localizzazione parziale

La voce “Community” compare hardcoded in punti di navigazione/social, mentre il resto usa localizzazione. Non è bug funzionale ma è incoerenza di prodotto e i18n incompleta.

**Rischio**: medio-basso (qualità UX).

---

## 6) Coerenza grafica tra pagine

## 6.1 Coerenze buone

- Uso diffuso di `Theme.of(context)` e palette condivisa (`AppPalette`) in molte schermate.
- Pattern visivi simili su card, bottoni, bottom sheet, header moderni.

## 6.2 Incoerenze osservate

- `LoginPage` usa palette hardcoded locale e stile molto “cinematico” (nero/olive/tan) distinto dal resto app: può essere scelta voluta di brand, ma crea stacco netto rispetto alle pagine interne.
- Label navigazione/social non completamente localizzata (“Community”).
- Presenza di toni stilistici leggermente diversi tra pagine (alcune molto tematizzate, altre più Material standard).

**Giudizio grafico**: buono, ma con incoerenze leggere/moderate di linguaggio visivo.

---

## 7) Parti inutili / rumore

- Marker/commenti `🔴` e commenti di “storia modifica” sono rumore nel codice production.
- File di build report Android (`android/build/reports/problems/problems-report.html`) potrebbe essere artefatto generato; valutare esclusione/versionamento intenzionale.

---

## 8) Conformità complessiva a DDD/SRP/Clean Code

- **DDD/Clean Architecture (macro): 8/10**
- **SRP (widget/controller granularità): 7/10**
- **Clean Code/manutenibilità: 7/10**
- **Coerenza grafica cross-page: 7/10**
- **Robustezza logica runtime: 6.5/10** (penalizzata soprattutto dal punto lifecycle singleton)

---

## 9) Piano raccomandato (ordine consigliato)

1. **Fix lifecycle DI/controller** (priorità P0).  
2. **Uniformare localizzazione completa UI** (P1).  
3. **Rimuovere commenti temporanei e marker di modifica** (P1).  
4. **Rifinire SRP UI**: estrarre sezioni/widget + spostare logica UI complessa in presenter/controller dedicati (P2).  
5. **Migliorare bootstrap resiliente** con schermata fallback errore init (P2).  
6. **Allineare design language login vs shell interna** (P3, decisione prodotto/UX).

---

## 10) Esito finale

Il repository è **complessivamente solido** e impostato bene per evoluzione, ma presenta **1 criticità tecnica alta** e alcune aree di rifinitura (i18n, pulizia, coerenza visiva/SRP) che meritano un passaggio dedicato.  
La base è buona: con pochi interventi mirati può diventare molto robusta.
