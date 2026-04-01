# Re-check tecnico (post-refactor) – CesenaRemembers

Data: 31 marzo 2026  
Scope: controllo nuovamente completo con focus su `lib/` (DDD, SRP, clean code, coerenza UI)

---

## 1) Esito sintetico

Rispetto al controllo iniziale, il progetto è migliorato in modo sensibile:

- `MapPage` non è più monolitica come prima.
- Logica tour separata in controller dedicato.
- Modelli tour estratti nel dominio.
- Palette condivisa centralizzata tra pagine principali.

Valutazione aggiornata:

- DDD: **7/10** (prima 5.5)
- SRP: **6.5/10** (prima 4.5)
- Clean code: **7/10** (prima 6)
- Coerenza grafica: **7.5/10** (prima 7)
- Prontezza produzione: **6/10** (prima 5)

---

## 2) Miglioramenti reali verificati

### 2.1 Separazione logica tour

La logica runtime del tour (stato, timer, tracking, arrivo, avanzamento) è stata spostata in `TourSessionController`, riducendo responsabilità dirette della pagina mappa.

### 2.2 Estrazione dominio tour

`TourStop` e `QuizQuestion` non sono più classi annidate dentro la pagina mappa, ma entità dedicate.

### 2.3 Algoritmo percorso separato

La strategia nearest-neighbor è in `TourRoutePlanner`, ora riusabile e testabile.

### 2.4 UI mappa separata in moduli

Controlli mappa e bottom sheet quiz/POI sono in file dedicati (`map_controls.dart`, `poi_bottom_sheet.dart`), alleggerendo `MapPage`.

### 2.5 Design tokens centralizzati

`AppPalette` è stata introdotta e usata in `main`, `ProfilePage`, `SettingsPage`.

---

## 3) Criticità ancora presenti (da chiudere)

### 3.1 Dimensioni ancora elevate nel layer presentation

Anche dopo il refactor, diversi file restano molto grandi:

- `settings_page.dart`: ~910 righe
- `profile_page.dart`: ~688 righe
- `poi_bottom_sheet.dart`: ~551 righe
- `map_controls.dart`: ~351 righe
- `map_page.dart`: ~429 righe

Conclusione: SRP è migliorato, ma serve un secondo passaggio di decomposizione per componenti/sezioni più piccole.

### 3.2 Placeholder e contenuti non production-ready

Restano stringhe placeholder/fittizie in impostazioni:

- testi “Inserisci qui ...” (privacy/termini)
- email supporto fittizia
- versione mostrata hardcoded in UI

### 3.3 Profilo ancora demo-hardcoded

Nome utente e username restano hardcoded (`Alessandro`, `@cesena_explorer_42`) e non legati a un vero stato utente/app.

### 3.4 Doppia fonte dati funzionale

La mappa usa POI da repository seed e il tour usa `TourStopsSeed` separato. È un passo avanti rispetto al passato, ma non è ancora una single source of truth unificata.

### 3.5 Testing insufficiente

La struttura ora è più testabile, ma non risultano test aggiuntivi su planner/controller/quiz.

---

## 4) Coerenza grafica aggiornata

- Migliorata la consistenza tra pagine interne grazie a palette centralizzata.
- Resta valida la nota precedente: login (dark cinematic) e shell interna (chiara editoriale) hanno uno stacco forte, ma è stata una scelta lasciata invariata su richiesta.

---

## 5) Priorità consigliate (nuovo ordine)

### Priorità alta
1. Scomporre `SettingsPage` e `ProfilePage` in feature-sections + widgets dedicati.
2. Estrarre la logica quiz da `poi_bottom_sheet.dart` in controller dedicato.
3. Unificare fonte dati POI/tour (single source of truth + mapping esplicito).

### Priorità media
4. Eliminare placeholder e collegare i contenuti a config/dati reali.
5. Collegare `ProfilePage` a stato utente reale (`AppUser`) invece di valori hardcoded.
6. Ridurre la logica rimasta in `MapPage` (ulteriore pass in presenter/view-model).

### Priorità bassa
7. Rifinire naming e documentazione tecnica.
8. Aggiornare README dal template Flutter a documentazione progetto reale.

---

## 6) Verdetto finale del re-check

Refactor **promosso**: il salto qualitativo rispetto alla versione iniziale è concreto e misurabile.

Per essere pienamente allineato ai principi richiesti (DDD/SRP/clean code “forte”), manca un ultimo ciclo di hardening su:

- decomposizione finale delle pagine ancora troppo lunghe,
- unificazione dati,
- rimozione placeholder,
- test automatici su componenti estratti.
