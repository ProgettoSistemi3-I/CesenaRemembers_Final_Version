# Report di Audit Tecnico – CesenaRemembers

Data audit: 3 aprile 2026  
Ambito: revisione statica dell'intero repository con focus su `lib/`, controllo coerenza architetturale (DDD/SRP/Clean Code), qualità logica e coerenza grafica tra pagine.

## 1) Metodo usato

- Revisione manuale dei file in `lib/` (domain, data, presentation, services, controllers).
- Controllo file di configurazione (`pubspec.yaml`, `analysis_options.yaml`, `README.md`) e test disponibili.
- Verifica di possibili problemi logici, accoppiamento tra layer, anti-pattern e parti placeholder.
- **Limite ambiente**: non è stato possibile eseguire `flutter analyze`/`flutter test` perché `flutter` non è installato nel container.

---

## 2) Valutazione sintetica

### Stato complessivo

Il progetto ha una base buona lato UI (design coerente e curato) e un tentativo reale di separazione layer (domain/data/presentation), ma **non è ancora coerente al 100% con DDD + SRP + clean architecture**.

### Giudizio per area

- **Architettura (DDD/Clean)**: **6/10**
- **SRP / separazione responsabilità**: **5.5/10**
- **Correttezza logica**: **5/10**
- **Coerenza grafica**: **8/10**
- **Maturità test/quality gate**: **3/10**

---

## 3) Problemi critici (da correggere prima del rilascio)

## 3.1 Import path errati (rischio build break)

Sono presenti import relativi non coerenti con la struttura `lib/`:

- `lib/models/user_model.dart` usa `../../domain/...` invece di `../domain/...`
- `lib/data/user_repository_impl.dart` usa `../../domain/...` invece di `../domain/...`

Con Dart/Flutter questi path risultano fragili o errati rispetto alla posizione del file, con rischio concreto di errore in compilazione/analyzer.

**Impatto**: alto (bloccante).

## 3.2 Errore logico XP: incrementi multipli sullo stesso POI

`markPoiAsVisited` fa:
- `arrayUnion([poiId])` (deduplica il POI)
- `FieldValue.increment(xpGained)` (incrementa sempre XP)

Se l’utente richiama l’azione più volte sullo stesso POI, la lista non duplica il POI ma gli XP continuano ad aumentare.

**Impatto**: alto (integrità dati / gamification alterata).

## 3.3 Domain layer contaminato da dipendenze UI/framework

`TourStop` in domain contiene `IconData` e `Color`, oltre a dipendere da `flutter/material.dart`.

In ottica DDD/Clean, il domain dovrebbe essere indipendente da Flutter/UI. Questo rende difficile testare e riusare il core.

**Impatto**: alto (violazione architetturale).

---

## 4) Problemi importanti (non bloccanti ma prioritari)

## 4.1 Mismatch tra tipi POI e marker rendering

I seed usano tipi come `church`, `monument`, `square`; il `PoiMarkerFactory` gestisce esplicitamente solo `school`, `bridge`, `library`, con fallback unico.

Conseguenza: marcatori poco semantici e perdita di differenziazione visiva dei POI reali.

## 4.2 Theme flow incoerente (sorgenti di verità multiple)

- `ThemeController` legge da Firebase in init.
- `SettingsController` aggiorna tema live via `toggleTheme`.
- In Settings c’è anche `_selectedTheme` (“Sistema/Chiaro/Scuro”) che però è solo locale UI e non governa realmente `ThemeMode`.

Questo crea UX ambigua: ci sono due punti apparentemente “tema” ma solo uno ha effetto reale.

## 4.3 Profilo fortemente mockato/hardcoded

In `ProfilePage` molti dati sono statici (`Alessandro`, username fisso, statistiche statiche), non collegati a repository/use case.

È utile per prototipo UI, ma non coerente con dominio utente reale.

## 4.4 Settings page molto “monolitica”

La pagina settings contiene moltissima logica di presentazione, popup, scelta opzioni, gestione stato locale, wiring controller. Funziona, ma viola parzialmente SRP lato UI component.

Suggerito split in widget sezionali dedicati o view-model per blocchi.

---

## 5) Osservazioni DDD/SRP/Clean Code (approfondite)

## 5.1 Cosa è già buono

- Esistono repository astratti nel dominio (`AuthRepository`, `IPoiRepository`, `IUserRepository`).
- Use case separati (`GetPoisUseCase`, `SignOutUseCase`, `UserUseCases`).
- DI centralizzata con `get_it`.
- Controller separati per sessione tour e quiz (buona coesione).

## 5.2 Dove non è aderente al modello clean

- **Domain non puro**: entity `TourStop` con tipi UI.
- **Data/model inheritance**: `UserModel extends UserProfile` e `PoiModel extends Poi`; in clean architecture spesso è più manutenibile usare mapping compositivo esplicito.
- **Accesso globale al service locator** in alcune classi UI/controller: pratico ma riduce testabilità e chiarezza delle dipendenze.

## 5.3 SRP

- `SettingsController`: responsabilità ampie (caricamento profilo, sincronizzazione tema, permessi GPS, salvataggio remoto, rollback, logout).
- `SettingsPage`: contiene molte responsabilità di UI orchestration.

Non è “sbagliato” in assoluto, ma è oltre la soglia ideale SRP.

## 5.4 Clean code

- Nomi generalmente chiari.
- Commenti utili ma molto numerosi/rumorosi (“ADATTIVO”, commenti ridondanti), riducono leggibilità nel medio periodo.
- Presenza di testi placeholder (“Inserisci qui...”, “Testo dei termini...”) in sezioni che sembrano finali.

---

## 6) Coerenza grafica tra pagine

## 6.1 Punti forti

- Palette cromatica condivisa via `AppPalette`.
- Pattern visivi ricorrenti coerenti: cards arrotondate, section label con barra oliva, bottoni pieni oliva, uso consistente di `surface/onSurface` per dark mode.
- Map/Profile/Settings hanno linguaggio visivo compatibile.

## 6.2 Incoerenze rilevate

- **Login** usa stile visivo molto diverso (hero full-screen con background fotografico remoto, contrasto e tono più “cinematico”): non necessariamente errato, ma è più distante rispetto alle altre 3 sezioni.
- Marker POI poco coerenti con i tipi dominio reali (vedi mismatch tipi).
- Settings include opzioni “Stile Icone” e “Tema visivo” non realmente integrate nella UI globale (percezione di feature incompleta).

Valutazione coerenza grafica: buona ma migliorabile su allineamento funzionale tra ciò che la UI promette e ciò che applica davvero.

---

## 7) Logica applicativa: punti da attenzionare

- Richiesta permesso posizione già in `main()` al primo avvio: esperienza invasiva prima ancora dell’onboarding/login.
- Cache statica POI/stops in `MapPage`: può causare stale state tra sessioni utente diverse (soprattutto dopo logout/login).
- In `UserRepositoryImpl.getUserProfile`, in caso primo accesso viene creato utente con email vuota e nome placeholder: meglio bootstrap con dati auth reali.
- Operazioni Firestore con `update` falliscono se doc assente: nei flussi “preferenze” conviene harden con `set(..., merge:true)` dove appropriato.

---

## 8) Parti inutili / tecniche da ripulire

- `README.md` è ancora template generico Flutter (“A new Flutter project”).
- Molte opzioni settings sembrano mock (consensi, notifiche tipo, stile icone, testi legali placeholder) senza persistenza/reale effetto.
- Copertura test quasi assente (1 test entity). Nessun test su tour logic, repository, settings controller.

---

## 9) Priorità consigliata (roadmap breve)

### Fase 1 – Stabilità (immediata)
1. Correggere import path errati.
2. Correggere bug XP duplicate increment.
3. Eseguire analyzer/test in CI.

### Fase 2 – Architettura (breve)
1. Rendere il domain indipendente da Flutter (`TourStop` senza `IconData/Color`).
2. Separare metadata UI dal core domain.
3. Rifattorizzare settings in sotto-componenti + semplificare controller.

### Fase 3 – Prodotto/UX (medio)
1. Allineare impostazioni “tema/stile icone” al comportamento reale.
2. Collegare profilo ai dati utente reali (repo/use case).
3. Rimuovere placeholder legali o implementarli davvero.

---

## 10) Conclusione

Il repository è **promettente e già ben impostato sul piano UX**, ma **non è ancora “production grade”** sul piano architetturale e logico.

Se l’obiettivo è rispettare davvero DDD/SRP/Clean Code, i punti strutturali da sistemare sono soprattutto:

- purezza del dominio,
- allineamento tra UI e logica reale,
- robustezza persistence/business rules,
- qualità automatizzata (analyzer/test).

Con gli interventi della Fase 1 + Fase 2 il progetto fa un salto netto di qualità.
