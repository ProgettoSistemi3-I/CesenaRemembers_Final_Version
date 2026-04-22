# Report di Audit Tecnico Repository

**Progetto:** CesenaRemembers_Final_Version  
**Data audit:** 22 aprile 2026  
**Scope richiesto:** analisi completa repository (focus `lib/`), coerenza architetturale (DDD/SRP/Clean Code), coerenza grafica tra pagine, correttezza logica, identificazione parti inutili.

---

## 1) Executive Summary

Il progetto è strutturato in modo generalmente ordinato e leggibile, con una separazione a layer (`domain`, `data`, `presentation`) che va nella direzione della Clean Architecture. La maggior parte dei casi d’uso principali è coperta in modo coerente: autenticazione, profilo, social/leaderboard, mappa, tour, quiz, preferenze, offline map.

**Valutazione complessiva:** buona base architetturale, ma con alcune criticità rilevanti su:

1. **Gestione dello stato condiviso dei controller social** (rischio inconsistenze/disposal non prevedibile in navigazioni complesse).
2. **Pipeline offline map** (download segnato come completato anche senza verifica di completezza tile).
3. **Coerenza tra DDD e dipendenze cross-layer** (presentation che dipende direttamente dai seed del data layer).
4. **Elementi UI non collegati/duplicati** (metodi e stato presenti ma non utilizzati).
5. **Copertura test praticamente assente** (un solo widget test base).

---

## 2) Verifica Architetturale (DDD, SRP, Clean Code)

## 2.1 Punti forti

- **Stratificazione chiara:** `domain` con entità/use case/repository contract, `data` con implementazioni e datasource, `presentation` con controller + pagine/widget.  
- **Use cases semplici e leggibili**, soprattutto per auth e utente.  
- **Repository utente ben delegato** a datasource distinti (profilo/progress/social/cleanup), buon segnale SRP nel data layer.  
- **Injection centralizzata** tramite `GetIt`, riduce il coupling diretto nelle UI.

## 2.2 Criticità DDD / layering

### A) Dipendenza inversa non rispettata in presentation
La presentation dipende da `HistoricPlacesSeed` nel data layer (`tour_stop_mapper.dart`, `tour_stop_visuals.dart`). Questo viola il principio classico di dipendenze dirette solo verso astrazioni/layer più interni.

**Impatto:** accoppiamento più alto, minore sostituibilità delle fonti dati future (es. API remota).

### B) Domain non completamente agnostico da librerie esterne
L’entità `TourStop` usa `LatLng` (`latlong2`) direttamente. Non è necessariamente errato in assoluto, ma è una scelta meno “pura” per DDD.

**Impatto:** dominio meno portabile/testabile senza dipendenza mapping geografica.

### C) Use case “facade” molto ampio
`UserUseCases` concentra molte responsabilità (profilo, preferenze, ricerca, leaderboard, amicizie, cleanup), diventando di fatto un service aggregato.

**Impatto:** perdita di granularità SRP sul layer applicativo; crescita futura più rischiosa.

---

## 3) Analisi SRP e responsabilità per modulo

## 3.1 Data layer

**Buono:** la separazione in datasource (`UserProfileDataSource`, `UserProgressDataSource`, `UserSocialDataSource`, `UserCleanupDataSource`) è corretta e coerente con SRP.

**Osservazione:** `UserProfileDataSource` contiene molta logica (validazione, transazioni username index, query di ricerca). È ancora accettabile, ma meriterebbe estrazione di policy/validator dedicati già al confine applicativo.

## 3.2 Presentation controllers

- `SettingsController` è ricco di responsabilità (preferenze, tema, geolocalizzazione permission flow, logout, delete account, error UX).  
- `SocialController` gestisce leaderboard + ricerca + friendship actions.

Sono controller funzionali, ma diventano “God objects” nel medio periodo.

## 3.3 UI pages

Le pagine principali sono leggibili, specialmente dove è stato usato `part` per separare sezioni (`settings_page_sections.dart`, `profile_page_sections.dart`, `map_page_*`).

---

## 4) Correttezza Logica e Potenziali Bug

## 4.1 Criticità alta: completamento offline map non verificato
In `OfflineMapRepository.downloadOfflineMap()` il progresso viene incrementato anche quando il tile non viene effettivamente salvato (status HTTP non 200, timeout, fallimenti rete), e al termine viene comunque scritto manifest `isReady: true`.

**Rischio:** mappa offline dichiarata disponibile ma incompleta/corrotta.

**Effetto utente:** modalità offline apparentemente attiva, ma con buchi tile o rendering incompleto.

## 4.2 Criticità media: gestione lifecycle SocialController in pagine multiple
`SocialController` viene risolto in più pagine e poi `dispose()` chiamato localmente. Con registerFactory questo funziona “quasi sempre”, ma aumenta rischio di stati disallineati tra schermate social/public profile e ricreazioni non controllate.

**Rischio:** race/event stream interrotti, risultati ricerca/classifica non sincronizzati tra pagine, costo extra di subscription duplicate.

## 4.3 Criticità media: ricerca social e UX su query corta
La vista passa a “search mode” appena `TextField` non è vuoto, ma `SocialController` ignora query < 2 char. Si può visualizzare subito “Nessun utente trovato” per 1 carattere, comportamento poco intuitivo.

## 4.4 Criticità media-bassa: update ottimistico amicizie senza rollback
In `PublicProfilePage` le liste friend/request vengono mutate localmente prima dell’esito server. In caso di errore non c’è rollback esplicito.

## 4.5 Criticità bassa: tema utente non sempre sincronizzato all’ingresso
Il tema viene inizializzato all’avvio app (`ThemeController.initTheme`) ma non è stream-based sul profilo utente. In alcuni percorsi può risultare momentaneamente non allineato finché non si ricaricano preferenze/settings.

---

## 5) Parti inutili / ridondanti / migliorabili

1. **`_showNotificationTypes()` in `SettingsPage`**: metodo presente ma non collegato a nessuna action row nella UI finale. Probabile residuo.
2. **`notificationType` in `SettingsUiController`**: stato presente ma non integrato in persistenza né in sezione impostazioni effettivamente visibile.
3. **Commenti “NUOVO IMPORT / LA TUA LOGICA…”** sparsi in presentation: utili in fase sviluppo, meno in codice finale pulito.
4. **README placeholder Flutter standard**: non descrive progetto, architettura, setup env, map keys, regole firestone, runbook test.

---

## 6) Coerenza Grafica tra pagine

## 6.1 Coerenza positiva

- Palette coerente (`olive/tan/moss`, varianti light/dark).
- Pattern visuali ricorrenti: card arrotondate, divider sottili, section label con barra verticale, uso consistente di `surface/onSurface/onSurfaceVariant`.
- Buona adozione tema adattivo in Settings/Profile/Map widgets.

## 6.2 Incoerenze rilevate

1. **LoginPage** usa palette locale hardcoded e background immagine esterna (Unsplash), parzialmente scollegata dalla `ThemeData` globale.
2. **Alcuni widget usano opacità legacy (`withOpacity`) e altri `withValues(alpha: ...)`**, stile non uniforme.
3. **Profilo setup** è più “standard Material” rispetto al resto (minor branding visuale rispetto Profile/Settings).
4. **Offline map option color** nel selector mappe resta arancione fisso anche in dark mode (meno armonico col design system).

---

## 7) Qualità Clean Code

## 7.1 Buone pratiche presenti

- Nomi in generale chiari e orientati al dominio.
- Entità semplici e senza side effects.
- Metodi mediamente brevi in use case e datasource.

## 7.2 Debiti tecnici

- Classi controller ampie con molte responsabilità.
- Eccezioni spesso generiche (`Exception('...')`) con string parsing a valle.
- Assenza quasi totale di test unitari/integration su logica critica (social, score, progress, offline download).

---

## 8) Test e verifiche effettuate

- Tentativo analisi statica Flutter: **non eseguibile in ambiente corrente** perché CLI Flutter non installata.
- Revisione statica manuale completa delle principali aree in `lib/` + file di configurazione e README.

---

## 9) Priorità di intervento consigliate

## Priorità P0 (alta, prima release stabile)

1. Rendere robusto `OfflineMapRepository`: contare solo tile realmente salvati e marcare `isReady` solo a download completo verificato.
2. Stabilire ownership chiara dei controller social (scope per pagina o singleton gestito), evitando dispose ambiguo in pagine annidate.

## Priorità P1 (media)

3. Rifattorizzare dipendenza presentation -> data seed (spostare mapping/metadata in layer più appropriato o esporlo via use case/repository).
4. Migliorare UX ricerca social per query corte (<2): stato “continua a digitare” invece di “nessun utente”.
5. Aggiungere rollback/reload post errore nelle azioni amicizia con optimistic update.

## Priorità P2 (media-bassa)

6. Ripulire metodi/stato UI non utilizzati in Settings.
7. Uniformare pattern grafici (Login/ProfileSetup) al design system comune.
8. Ridurre commenti temporanei e migliorare coerenza stilistica (alpha APIs, naming commenti).
9. Aggiornare README con documentazione reale del progetto.

---

## 10) Giudizio finale

Il repository è **globalmente valido** e già vicino a uno standard professionale per un’app Flutter di media complessità, soprattutto per la separazione per layer e la leggibilità delle schermate principali. Tuttavia, **non è ancora “clean” al 100%** su DDD/SRP: ci sono alcuni accoppiamenti cross-layer, logiche multi-responsabilità nei controller, e una criticità logica concreta sull’offline map che va sanata prima di considerare il codice pienamente robusto.

Con gli interventi P0/P1 sopra, la base può diventare molto solida e facilmente evolvibile.
