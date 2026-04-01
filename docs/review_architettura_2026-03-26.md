# Audit repository CesenaRemembers (26 marzo 2026)

## Scopo del controllo
Rieseguire un controllo completo del repository, con profondità equivalente al controllo iniziale:
- correttezza generale,
- coerenza architetturale,
- aderenza a DDD/SRP/Clean Code,
- ricerca parti inutili,
- verifica specifica della **coerenza grafica tra le pagine**.

## Metodo usato
1. Ispezione della struttura repository e dei file applicativi principali.
2. Revisione statica approfondita dei layer `domain`, `data`, `presentation`.
3. Analisi UI cross-page (tema globale, palette, componenti, spaziature, stile navigazione).
4. Tentativo di verifica automatica (`flutter analyze`, `flutter test`) nel contesto corrente.

## Executive summary
- **Stato complessivo:** buono per un MVP, ma con debiti tecnici ancora presenti.
- **Qualità architetturale:** discreta (layering chiaro, DI migliorata), ma DDD ancora leggero.
- **Qualità codice:** mediamente buona, con margini su test, datasource reali, uniformità stile UI.
- **Coerenza grafica:** **parziale**: buone basi, ma inconsistenza tra login/map/profile/settings in palette, componenti e gerarchia visuale.
- **Score sintetico:** **7.6/10**.

---

## 1) Coerenza strutturale repository
- Repository ordinato e leggibile (`lib/domain`, `lib/data`, `lib/presentation`, `test`, `docs`).
- Presenza di documenti di audit storici che aiutano la tracciabilità delle decisioni.

**Valutazione:** positiva.

## 2) Architettura applicativa (DDD / layered)

### Punti solidi
- Separazione in layer presente e chiara.
- Domain contiene entità, repository interface e use case (struttura corretta per Clean Architecture light).
- Presentation dipende da use case/repository abstractions, non direttamente da infrastruttura in larga parte.

### Limiti attuali
- DDD ancora “anemic”: entità prevalentemente contenitori dati, con poche regole di dominio.
- Parte della logica resta in widget stateful complessi (`MapPage`).
- Manca formalizzazione di policy di dominio più ricche (value objects, invarianti esplicite, error model di dominio).

**Valutazione DDD:** parziale ma coerente con fase progettuale.

## 3) SRP e separazione responsabilità

### Miglioramenti già consolidati
- Permessi geolocalizzazione estratti in servizio dedicato.
- Mapping `Poi -> Marker` estratto in factory dedicata.
- DI bootstrap più robusta con `isRegistered` su tutte le registrazioni chiave.

### Aree ancora da rifinire
- `MapPage` mantiene ancora molte responsabilità insieme:
  - orchestrazione stato mappa,
  - lifecycle,
  - stream GPS,
  - UX overlay,
  - gestione errori caricamento.

**Valutazione SRP:** migliorato, non ancora ottimale.

## 4) Clean Code

### Punti buoni
- Codice generalmente leggibile.
- Commenti legacy rumorosi ridotti rispetto al passato.
- Naming tecnico abbastanza coerente nelle parti core.

### Debiti residui
- Data source POI ancora stub hardcoded.
- README non descrive il progetto reale (è template Flutter).
- Test coverage molto bassa.
- Presenza di valori hardcoded (colori, stringhe UI, spacing) distribuiti localmente anziché centralizzati.

**Valutazione Clean Code:** media tendente al buono.

---

## 5) Correttezza tecnica e rischi runtime

### Rischi principali ancora presenti
1. **POI mock in produzione logica app**: il repository restituisce dati fissi con delay simulato.
2. **Assenza test di regressione reali**: solo test minimale su `AppUser`.
3. **Gestione auth Google con clientId hardcoded**: funziona per MVP ma poca flessibilità configurativa.

### Aspetti positivi
- Error handling su caricamento POI e logout presente.
- Guardie `mounted` usate correttamente nei flussi async UI.

---

## 6) Coerenza grafica cross-page (richiesta specifica)

### Stato attuale
La coerenza grafica è **parziale**.

#### Elementi coerenti
- Uso esteso di `Scaffold` e background chiaro.
- Presenza di componenti Material standard (FAB, card-like container, bottom navigation).

#### Incoerenze visive rilevanti
1. **Palette non unificata**
   - Tema globale seed blu.
   - Login usa AppBar grigia.
   - Profile/Settings usano palette verde/blu scuro variabile per sezione.
   - Map usa controlli bianchi e accenti blu/rossi.
2. **Tipografia/gerarchia non uniforme**
   - Dimensioni testo e pesi variabili tra pagine senza design token condivisi.
3. **Componenti simili ma non standardizzati**
   - Tile/cards costruite manualmente in profile/settings con logica locale.
4. **Navigation shell vs singole pagine**
   - Main shell coerente, ma le pagine figlie non condividono un pattern visuale unificato (header, spacing rhythm, key actions).

### Raccomandazioni UX/UI (priorità)
1. Introdurre `AppTheme` centralizzato con:
   - `ColorScheme`,
   - typography scale,
   - component themes (`CardTheme`, `OutlinedButtonTheme`, `AppBarTheme`, `SwitchTheme`).
2. Definire design token (`spacing`, radius, colors semantiche).
3. Estrarre componenti comuni (`SettingsTile`, `StatTile`, `SectionHeader`) in widget riusabili.
4. Uniformare header pattern:
   - scelta unica tra AppBar esplicita o layout full-bleed senza appbar.
5. Ridurre hardcoded colors nelle pagine a favore di `Theme.of(context).colorScheme`.

---

## 7) Backlog consigliato (ordine operativo)

### Alta priorità
1. Sostituire `PoiRepositoryImpl` mock con datasource reale (Firestore/API) + gestione errori typed.
2. Aggiungere test unitari su use case e repository; widget test su auth gate/map error state.

### Media priorità
3. Ulteriore decomposizione `MapPage` (controller/view-model + widget compositi).
4. Uniformare design system cross-page con tema centralizzato.

### Bassa priorità
5. Aggiornare README con setup reale progetto e architettura.

---

## Comandi eseguiti
- `flutter analyze` -> non eseguibile in questo ambiente (`flutter: command not found`).
- `flutter test` -> non eseguibile in questo ambiente (`flutter: command not found`).
- Ispezioni statiche completate con `find`, `rg`, `nl`.

## Conclusione finale
Il progetto è in stato complessivamente buono e migliore rispetto alle prime revisioni: la base architetturale c’è, la qualità è in crescita e i punti critici principali sono ora chiaramente delimitati. La priorità vera, adesso, è passare da MVP tecnico a prodotto mantenibile: datasource reale, test di regressione e design system condiviso per coerenza grafica completa.
