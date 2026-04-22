# Report di Audit Tecnico — CesenaRemembers

**Data audit:** 22 aprile 2026  
**Scope:** intero repository, con focus principale su `lib/`.

---

## 1) Executive summary

Il progetto mostra una base architetturale buona (struttura a layer, separazione domain/data/presentation, uso di use case e controller), ma presenta alcune criticità importanti su:

- **coerenza DDD/Clean Architecture** (dipendenze dal layer sbagliato in presentation);
- **SRP** (classi molto grandi con responsabilità eterogenee);
- **robustezza logica** (gestione errori incompleta e alcuni edge case);
- **sicurezza/configurazione** (chiavi/API ID hardcoded nel codice);
- **coerenza grafica cross-page** (stile molto coerente in profile/settings/social, meno in login/profile setup).

Valutazione sintetica (0-10):

- **Architettura generale:** 7.0
- **DDD / Confini layer:** 5.5
- **SRP / manutenibilità:** 5.5
- **Clean code:** 6.0
- **Coerenza UI/UX:** 7.0
- **Robustezza logica:** 6.0
- **Testabilità / copertura test:** 3.0

---

## 2) Metodologia utilizzata

- Revisione statica file-by-file in `lib/` e `test/`.
- Analisi dipendenze tra layer (`domain`, `data`, `presentation`).
- Verifica qualità del codice rispetto a DDD/SRP/Clean Code.
- Verifica coerenza visiva tra pagine principali (`login`, `map`, `profile`, `social`, `settings`, `profile_setup`).
- Verifica logica principale: autenticazione, profilo, amicizie, leaderboard, tour, offline map, preferenze.

> Nota ambiente: non è stato possibile eseguire `flutter analyze`/`flutter test` perché gli strumenti Flutter/Dart non sono presenti nell’ambiente corrente.

---

## 3) Punti forti rilevati

1. **Struttura a layer già impostata correttamente** (`domain`, `data`, `presentation`) con entità e use case separati.
2. **Uso di use case e repository interface**: buona base per disaccoppiamento e testabilità.
3. **Tema centralizzato** con palette dedicata e supporto light/dark.
4. **Buona cura visuale** su pagine social/profile/settings (componenti, card, spacing, hierarchy).
5. **Logica tour ben modellata** con controller dedicato e servizi di scoring/route planning.

---

## 4) Criticità ad alta priorità (HIGH)

### H1 — Segreti e chiavi hardcoded nel codice

Sono presenti valori sensibili direttamente nel repository:

- `clientId` Google Sign-In hardcoded nel data layer auth;
- API key MapTiler hardcoded nel repository mappe offline;
- API key tile dark map hardcoded nella mappa.

**Rischio:** sicurezza, leakage credenziali, difficoltà di rotazione chiavi e gestione ambienti (dev/stage/prod).

**Raccomandazione:** spostare in variabili ambiente/build-time config (es. `--dart-define`) e centralizzare in config provider.

---

### H2 — Violazione confini DDD/Clean Architecture (presentation → data)

La presentation dipende direttamente da classi del layer data per le mappe offline (`OfflineMapRepository`).

**Perché è un problema:** il layer UI conosce dettagli infrastrutturali, riduce sostituibilità e testabilità.

**Raccomandazione:** introdurre un repository/port nel domain (es. `IOfflineMapRepository`) e usare use case nel presentation.

---

### H3 — Responsabilità eccessive in classi chiave (SRP)

`UserRepositoryImpl` accorpa molte responsabilità: profilo, username index, preferenze, quiz stats, leaderboard, social graph (amicizie/richieste), cancellazione account e cleanup relazionale.

`MapPage` + part gestiscono insieme rendering, input utente, orchestrazione tour, posizione, map style, offline availability, snackbar, popup.

**Effetto:** aumento complessità ciclomatica, più bug regressivi, test difficili.

**Raccomandazione:** estrarre servizi/repository verticali (ProfileRepository, SocialRepository, LeaderboardRepository, QuizProgressRepository; MapUiStateController ecc.).

---

## 5) Criticità medie (MEDIUM)

### M1 — Potenziale leak/duplicazione stato con `SocialController`

Il container registra `SocialController` come `factory`, ma in più punti viene richiesto direttamente via `sl<SocialController>()`; in almeno un punto è creato on-demand solo per una chiamata e non disposto.

**Rischio:** stream multipli verso leaderboard, stato incoerente tra schermate, consumo risorse.

**Raccomandazione:** definire una strategia univoca:
- o controller per-page (creazione/dispose sempre locale);
- o singleton condiviso con lifecycle globale.

---

### M2 — Gestione errore incompleta in caricamento profilo pubblico

Nel caricamento di `PublicProfilePage`, in caso errore viene mostrato snackbar ma lo stato di loading non viene necessariamente risolto in UI con fallback esplicito.

**Rischio:** schermata in loading infinito in alcuni scenari di errore.

**Raccomandazione:** impostare `_isLoading = false` anche nel catch e mostrare stato errore con retry.

---

### M3 — Bug nel filtro linguaggio offensivo

Nella lista `_blockedTerms` manca una virgola tra due elementi, producendo una stringa concatenata involontaria (`magrebini` + `frocio`).

Inoltre nel metodo `containsOffensiveLanguage` viene calcolata una variabile locale (`cleaned`) che non viene usata: blocco morto.

**Rischio:** falsi negativi nel filtraggio + codice confondente.

**Raccomandazione:** correggere la lista e rimuovere/implementare davvero il controllo per token.

---

### M4 — Race condition possibile nella ricerca social

La ricerca usa debounce, ma una risposta lenta di query precedente può sovrascrivere risultati più recenti.

**Raccomandazione:** associare request token/versione e scartare risultati non più attuali.

---

## 6) Criticità basse (LOW)

1. **Commenti rumorosi/storici** (`NUOVO`, note interne) e mix italiano/inglese non sempre uniforme.
2. **README generico Flutter template** non descrive architettura reale, setup Firebase, regole Firestore, flussi.
3. **Test quasi assenti** (solo test entity semplice). Mancano test su use case, controller, repository logic.

---

## 7) Coerenza grafica tra pagine (UI consistency)

### Cosa è coerente

- Forte identità visiva olive/tan + card arrotondate su **Profile / Social / Settings**.
- Buona adozione del tema dinamico con `Theme.of(context).colorScheme`.
- Pattern ricorrenti coerenti (section labels, cards, statistiche, action rows).

### Dove c’è disallineamento

1. **LoginPage**: usa palette hardcoded e background network esterno; è volutamente “hero” ma molto separata dal resto dell’app (non aderisce a light/dark system in modo pieno).
2. **ProfileSetupPage**: aspetto più “default Material” rispetto allo stile premium delle altre pagine (input base, minore personalizzazione).
3. Alcuni componenti usano stili diretti invece di token/theme estesi (scarsa uniformità futura).

### Suggerimenti UI

- Definire un piccolo **design system interno** (spacing scale, radius scale, text styles, component tokens).
- Portare `ProfileSetupPage` su stessi componenti card/input/stato errore di `Settings/Profile`.
- Valutare una versione di `LoginPage` tematicamente integrata (stesso linguaggio visuale, mantenendo impatto).

---

## 8) Verifica logica funzionale

### Flussi solidi

- Auth gate + ensure documento utente + completamento profilo: ben orchestrato.
- Tour session: stato, arrivo, avanzamento tappa, scoring XP coerenti.
- Preferenze: sincronizzazione local-state + persistenza Firestore ben pensata.

### Rischi logici principali

- Controller social multipli (stato non unico).
- Error handling incompleto in alcune pagine.
- Logica social e profilo fortemente accoppiata nello stesso repository.

---

## 9) DDD / SRP / Clean Code — giudizio puntuale

## DDD

**Pro:** presenza entity/repository/usecase.  
**Contro:** boundary non rispettati in alcuni punti (presentation che dipende dal data).  
**Esito:** **parzialmente conforme**.

## SRP

**Pro:** alcuni servizi dedicati (scoring, route planner, marker factory).  
**Contro:** classi “God object” (`UserRepositoryImpl`, `MapPage` orchestration).  
**Esito:** **non pienamente conforme**.

## Clean Code

**Pro:** naming generalmente comprensibile, codice leggibile, componentizzazione UI discreta.  
**Contro:** comment noise, duplicazioni di logica/stile, blocchi morti, assenza test robusti.  
**Esito:** **discreto ma migliorabile**.

---

## 10) Piano di miglioramento consigliato (prioritizzato)

### Sprint 1 (alta priorità)

1. Rimuovere tutte le chiavi hardcoded e introdurre config per ambiente.
2. Introdurre interfaccia domain per offline maps + use case dedicati.
3. Correggere bug filtro offensivo (virgola mancante + cleanup logica).
4. Fix error state in `PublicProfilePage` (no loading infinito).

### Sprint 2

1. Rifattorizzare `UserRepositoryImpl` in repository verticali.
2. Definire lifecycle univoco dei controller social.
3. Aggiungere test unitari su use case/controller chiave.

### Sprint 3

1. Uniformare `ProfileSetupPage` al design system.
2. Ridurre hardcoded visual values con token comuni.
3. Aggiornare README tecnico completo (setup, architettura, runbook).

---

## 11) Conclusione

Il progetto è già a un livello **intermedio buono** e mostra scelte corrette di base. Le aree da rafforzare sono soprattutto **confini architetturali, responsabilità delle classi e hardening logico/sicurezza**. Con i fix proposti, la codebase può diventare sensibilmente più robusta, testabile e manutenibile in tempi relativamente brevi.

