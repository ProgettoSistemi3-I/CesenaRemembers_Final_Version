# Report di Audit Tecnico — CesenaRemembers

Data audit: 2026-05-18
Ambito: intero repository (focus `lib/`), coerenza DDD/SRP/Clean Code, coerenza grafica cross-page, logica applicativa, bug funzionali e bug logici.

## 1) Executive summary

Valutazione complessiva: **buona base architetturale**, con separazione a layer presente e in gran parte coerente con DDD/Clean Architecture; tuttavia emergono alcune **criticità concrete** su:

- **debito tecnico di manutenzione** (commenti temporanei “FIX/AGGIUNTA”, codice/commenti non allineati allo stato reale),
- **SRP parzialmente violato** in alcune classi UI molto dense (es. `MapPage` e `SettingsPage`),
- **bug logici/potenziali** in gestione quiz/tour e notifiche,
- **incoerenze UI/UX** tra schermate (soprattutto Login vs resto app),
- **test coverage minima** (presente solo test entity base).

## 2) Struttura architetturale (DDD / Clean)

### Punti positivi

1. **Layering chiaro** in `domain`, `data`, `presentation` e uso di `get_it` per DI.
2. **Repository astratti** nel domain e implementazioni concrete nel data layer (`IUserRepository` → `UserRepositoryImpl`).
3. Presenza di **use case** per separare orchestrazione dall’UI.

### Criticità

1. **Use case “anemici”/pass-through**: diversi use case sono wrapper sottili di repository senza vera logica di dominio; non è un errore bloccante, ma riduce il valore del layer applicativo.
2. **MapPage molto accentrata**: la pagina combina stato UI, location, map rendering, tour orchestration, cache tiles, snackbars e modali. È separata in part file, ma la responsabilità resta elevata.
3. **Commenti di sviluppo temporanei** (es. “FIX”, “AGGIUNTA”, “NUOVO”) presenti in produzione: segnale di patch incremental non consolidata.

## 3) SRP e Clean Code

### Osservazioni

- `MapPage` mostra una decomposizione buona in extension, ma mantiene molte responsabilità nello stesso state object.
- `SettingsPage` contiene logica di animazione, orchestrazione use case/controller, handling errori e varie modali nella stessa classe.
- `MainShell` ha import non utilizzati e commenti patch-oriented.

### Effetto pratico

- Più rischio regressioni su modifiche future.
- Testing unitario difficile senza refactor in componenti/servizi dedicati.

## 4) Bug e bug logici rilevati

### 4.1 Quiz personalizzato non realmente alimentato da XP utente (bug logico)

Nel flusso apertura quiz della tappa, `userXp` è impostato a `0` e non viene mai valorizzato prima di chiamare quiz API. Quindi la personalizzazione basata su XP è di fatto disabilitata.

Impatto: domande AI non calibrate al livello utente come previsto dal design.

### 4.2 Endpoint quiz hardcoded con URL ngrok (rischio affidabilità)

`QuizRepositoryImpl` usa `_baseUrl` hardcoded su dominio `ngrok-free.dev`.

Impatto:
- endpoint volatile/non stabile in produzione,
- fallback locale frequente anche quando non desiderato,
- comportamento difficilmente gestibile per ambienti dev/stage/prod.

### 4.3 Notifiche push: listener agganciato a `BuildContext` di shell (rischio UX/runtime)

`PushNotificationService.initializeAndSaveToken(context)` installa listener statici con callback che usano `ScaffoldMessenger.of(context)`.

Rischio:
- snackbars legati al context della shell anche quando il tree cambia,
- gestione UI notifiche non centralizzata via navigator/scaffold key globale.

### 4.4 Incoerenza i18n nelle notifiche

Etichetta azione snack “VAI” hardcoded e non localizzata.

Impatto: incoerenza con internazionalizzazione generale (italiano/inglese).

### 4.5 Stato statico in `MapPage` (cache e permission flag) con effetti cross-session

Uso di campi statici per cache POI/stops e flag permission iniziale.

Rischio:
- stato condiviso oltre il ciclo di vita widget,
- edge case su logout/login o ricostruzioni complete app,
- invalidazione cache non esplicita.

## 5) Coerenza grafica tra pagine

## Valutazione

- **Buona coerenza** su palette nelle pagine principali (map/profile/settings) grazie a `AppPalette` e ThemeData.
- **Parziale incoerenza** su LoginPage:
  - sfondo `Colors.black` fisso e stile visual fortemente custom, separato dal tema globale,
  - molte costanti colore locali duplicate anziché derivate dal `ColorScheme`.

Effetto UX: transizione percepita “stacco” forte tra login e resto app (potenzialmente voluto dal branding, ma non coerente con clean design system se non documentato).

## 6) Qualità test e verifiche

- Test presenti ma **molto minimali** (`test/widget_test.dart` verifica solo entity `AppUser`).
- Mancano test unitari per:
  - use case utente/quiz,
  - controller (Profile/Settings/PoiQuiz/Tour session),
  - servizi dominio (scoring, route planner),
  - regressioni dei bug logici evidenziati.

## 7) Parti potenzialmente inutili / da ripulire

1. Import non usati in `MainShell` (es. use case/profile/sl importati ma non usati direttamente).
2. Commenti patch-oriented (“🔴 AGGIUNTA”, “FIX”) da rimuovere o trasformare in documentazione tecnica pulita.
3. Variabile/commento in `_openPoiPopup` che dichiara ottimizzazione XP cache ma non implementa realmente il recupero valore.

## 8) Conclusione

Il repository è **funzionalmente ben impostato** e con una direzione architetturale corretta. Non è però ancora “pulito” al livello richiesto per piena aderenza a DDD/SRP/Clean Code in senso rigoroso.

Priorità consigliate:
1. Correggere i bug logici su quiz personalization e notifiche.
2. Spostare configurazioni runtime (es. endpoint quiz) su config/env.
3. Rifinire SRP di `MapPage`/`SettingsPage` estraendo orchestration service/controller aggiuntivi.
4. Allineare design system login al tema (o documentare esplicitamente l’eccezione di branding).
5. Aumentare la test coverage su casi core.
