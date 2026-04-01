# Audit repository CesenaRemembers (24 marzo 2026)

## Obiettivo
Rifare il controllo completo del repository con lo stesso approccio iniziale, con focus primario sulla cartella `lib/`, verificando coerenza generale, correttezza, codice inutile e aderenza a DDD, SRP e Clean Code.

## Metodo di verifica
- Ispezione struttura repository e file applicativi (`lib/`, `test/`, `docs/`, file di configurazione root).
- Revisione statica dei componenti principali (domain/data/presentation, bootstrap, auth, map, settings).
- Tentativo di esecuzione controlli automatici (`flutter analyze`, `flutter test`) in ambiente corrente.

## Esito complessivo (stato attuale)
- **Valutazione generale:** migliorato rispetto al controllo precedente.
- **Score qualitativo attuale:** **7.5/10**.
- **Trend:** positivo (ridotti i principali problemi su DI, SRP parziale della mappa, gestione errori async base).

## Verifica punto-per-punto

### 1) Coerenza architetturale generale
**Esito:** Buona a livello macro.
- Layering chiaro (`domain`, `data`, `presentation`).
- Dipendenze direzionate in modo sensato (UI -> use case -> repository).

### 2) DDD
**Esito:** Parziale, ma coerente con un’app small/medium.
- Presenti entità, repository interface e use case nel domain.
- Manca ancora una modellazione di dominio più ricca (entità sostanzialmente anemiche).
- Regole business minime ancora distribuite in presentation (anche se migliorate con factory marker).

### 3) SRP
**Esito:** Migliorato ma non pienamente soddisfatto.
- Positivo: estratte responsabilità da `MapPage` in servizi dedicati (`LocationPermissionService`, `PoiMarkerFactory`).
- Residuo: `MapPage` resta una classe molto ampia con UI complessa + stato + orchestrazione stream/eventi.

### 4) Clean Code
**Esito:** Medio-buono.
- Positivo: rimozione di codice commentato legacy (`ProfilePage`, `SettingsPage`), riduzione commenti temporanei.
- Positivo: bootstrap DI più robusto e coerente.
- Residuo: ancora presenza di dati hardcoded e naming misto IT/EN.

### 5) Parti inutili / technical debt residuo
1. `PoiRepositoryImpl` è ancora uno stub con dati hardcoded.
2. `README.md` è ancora template Flutter standard, non descrive progetto reale.
3. Copertura test molto ridotta (solo test minimale su `AppUser`).
4. `MapPage` resta lunga e complessa; consigliata ulteriore estrazione di controller/view-model.

## Cosa è migliorato rispetto al precedente audit
- **DI**: ordine e guardie di registrazione più robusti in `injection_container.dart`.
- **Map SRP**: estrazione permessi geolocalizzazione e mapping marker in servizi dedicati.
- **Error handling async**: aggiunto handling per caricamento POI (errore + retry) e logout (errore + loading state).
- **Pulizia UI**: rimossi blocchi di codice commentato non utili.

## Criticità residue (priorità)

### Alta priorità
1. Passare `PoiRepositoryImpl` da stub hardcoded a datasource reale (Firestore o API), con mapping DTO -> domain.
2. Aumentare i test su use case/repository/auth gate/map behavior.

### Media priorità
3. Completare separazione responsabilità in `MapPage` (controller/viewmodel + widget compositi).
4. Unificare convenzione naming (italiano o inglese) per migliorare coerenza.

### Bassa priorità
5. Aggiornare README con setup reale (Firebase/Auth/Map), struttura e comandi.

## Comandi eseguiti in questo controllo
- `flutter analyze` -> **non eseguibile** in questo ambiente (`flutter: command not found`).
- `flutter test` -> **non eseguibile** in questo ambiente (`flutter: command not found`).
- Ispezione statica via shell (`find`, `rg`, `nl`) completata con successo.

## Conclusione
Il repository è ora in una condizione sensibilmente migliore rispetto alla revisione precedente: più robusto, più pulito e con gestione errori base più corretta. Non è ancora un’implementazione DDD “strict”, ma per la dimensione attuale del progetto l’architettura è ragionevole. Restano da chiudere soprattutto: datasource POI reale, test automation e ulteriore decomposizione di `MapPage`.
