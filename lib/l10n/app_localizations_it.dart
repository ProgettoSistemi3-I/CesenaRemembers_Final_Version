// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Cesena Remembers 1945';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get settingsHeaderTitle => 'Tour interattivo WWII';

  @override
  String get settingsHeaderSubtitle => 'Gestisci privacy, notifiche e lingua in un unico posto.';

  @override
  String get sectionCredits => 'Crediti';

  @override
  String get creditsTitle => 'Crediti e Riconoscimenti';

  @override
  String get creditsSubtitle => 'Scopri il team dietro Cesena Remembers';

  @override
  String get creditsPageTitle => 'Riconoscimenti';

  @override
  String get creditsAppName => 'Cesena Remembers';

  @override
  String get creditsAppDescription => 'Realizzato con passione per preservare la memoria storica della nostra città.';

  @override
  String get sectionTeam => 'Il Team';

  @override
  String get sectionThanks => 'Ringraziamenti';

  @override
  String get creditRoleDev => 'Sviluppo & Architettura';

  @override
  String get creditRoleTeacher => 'Docente Referente';

  @override
  String get creditRoleClass => 'Supporto e Ideazione';

  @override
  String get creditSchoolSubtitle => 'Visita il sito web dell\'istituto';

  @override
  String get sectionAccount => 'Account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutSubtitle => 'Esci dall\'account corrente';

  @override
  String get loggingOut => 'Uscita in corso...';

  @override
  String get deleteAccountTitle => 'Elimina account';

  @override
  String get deleteAccountSubtitle => 'Rimuovi profilo e dati associati';

  @override
  String get deletingAccount => 'Eliminazione in corso...';

  @override
  String get deleteAccountDialogTitle => 'Eliminare account?';

  @override
  String get deleteAccountDialogBody => 'Questa operazione rimuove account, progressi e dati associati in modo permanente.';

  @override
  String get deleteAccountSuccess => 'Account eliminato definitivamente.';

  @override
  String get deleteAccountFailure => 'Impossibile completare ora. Controlla il messaggio di errore.';

  @override
  String get sectionPreferences => 'Preferenze App';

  @override
  String get notificationsTitle => 'Notifiche';

  @override
  String get notificationsSubtitle => 'Ricevi avvisi su tappe e premi';

  @override
  String get darkModeTitle => 'Modalità Notte';

  @override
  String get darkModeSubtitle => 'Tema scuro per l\'intera app';

  @override
  String get sectionPrivacy => 'Privacy';

  @override
  String get gpsTitle => 'Posizione GPS';

  @override
  String get gpsSubtitle => 'Necessario per esplorare la mappa';

  @override
  String get privacyPolicyTitle => 'Informativa privacy';

  @override
  String get privacyPolicySubtitle => 'Leggi come vengono trattati i dati';

  @override
  String get gpsPermissionDenied => 'Permesso negato o GPS disattivato. Controlla le impostazioni del telefono.';

  @override
  String get sectionGeneral => 'Generale';

  @override
  String get languageTitle => 'Lingua';

  @override
  String get sectionInfo => 'Info';

  @override
  String get versionTitle => 'Versione';

  @override
  String get versionSubtitle => '1.0.0';

  @override
  String get versionSheetTitle => 'Versione app';

  @override
  String get versionSheetBody => 'Build number: 1.0.0';

  @override
  String get termsTitle => 'Termini di servizio';

  @override
  String get termsSubtitle => 'Regole d\'uso e responsabilità';

  @override
  String get contactsTitle => 'Contatti';

  @override
  String get contactsSubtitle => 'cesenaremembers@gmail.com';

  @override
  String get buttonClose => 'Chiudi';

  @override
  String get buttonCancel => 'Annulla';

  @override
  String get buttonDelete => 'Elimina';

  @override
  String get buttonOk => 'Perfetto';

  @override
  String get buttonRetry => 'Riprova';

  @override
  String get navMap => 'Mappa';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get navCommunity => 'Comunità';

  @override
  String errorLoadPreferences(String error) {
    return 'Errore nel caricamento preferenze: $error';
  }

  @override
  String get errorConnection => 'Errore di connessione. Modifica annullata.';

  @override
  String errorLogout(String error) {
    return 'Logout fallito.';
  }

  @override
  String get errorDeleteAccountPartial => 'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';

  @override
  String errorDeleteData(String error) {
    return 'Impossibile eliminare i dati: $error';
  }

  @override
  String get errorLoadProfile => 'Impossibile caricare il profilo.';

  @override
  String get errorOperationFailed => 'Operazione non riuscita. Stato ripristinato.';

  @override
  String get tourStopped => 'Tour interrotto.';

  @override
  String get errorSaveScore => 'Errore nel salvataggio del punteggio. Riprova tra poco.';

  @override
  String get errorLoadPoi => 'Errore nel caricamento dei punti di interesse.';

  @override
  String get errorSearch => 'Errore durante la ricerca.';

  @override
  String get errorAction => 'Errore durante l\'azione.';

  @override
  String get removeFriendship => 'Rimuovi amicizia';

  @override
  String get locationDisabled => 'Posizione disattivata';

  @override
  String get quizAnswerPerfect => 'Perfetto!';

  @override
  String get quizAnswerGood => 'Molto bravo!';

  @override
  String get toursCompleted => 'Tour Completati';

  @override
  String get tourLabel => 'Tour';

  @override
  String get tourConfirmStopTitle => 'Interrompere il tour?';

  @override
  String get tourConfirmStopBody => 'Il tour verrà terminato e perderai l\'ordine attuale delle tappe.';

  @override
  String get buttonStop => 'Interrompi';

  @override
  String get tourStartGpsRequired => 'Per iniziare il tour attiva GPS, permessi posizione e opzione nell\'app.';

  @override
  String get tourCompleted => '🎉 Tour completato! Ottimo lavoro.';

  @override
  String get tourStopButton => 'Interrompi tour';

  @override
  String get tourOrderButton => 'Ordina tappe';

  @override
  String get profileTitle => 'Il mio profilo';

  @override
  String get sectionStatistics => 'Statistiche';

  @override
  String get sectionAchievements => 'Achievement';

  @override
  String get statTotalXp => 'XP Totali';

  @override
  String get statBestTour => 'Miglior tour (XP)';

  @override
  String get statVisitedSites => 'Siti Visitati';

  @override
  String get statBestTime => 'Miglior tempo';

  @override
  String get statAchievements => 'Achievement';

  @override
  String get profileFriends => 'Amici';

  @override
  String get profilePoints => 'Punti';

  @override
  String get profileNoRequests => 'Nessuna richiesta al momento.';

  @override
  String get profileYourFriends => 'I tuoi Amici';

  @override
  String get profileFriendRequests => 'Richieste d\'amicizia';

  @override
  String profileNameTooShort(int min, int max) {
    return 'Il nome deve avere $min-$max caratteri.';
  }

  @override
  String get profileNameOffensive => 'Il nome contiene termini non consentiti.\nInseriscine uno diverso.';

  @override
  String get avatarPickerTitle => 'Scegli il tuo Avatar';

  @override
  String get avatarPickerSubtitle => 'Personalizza il tuo profilo';

  @override
  String get poiTabInfo => 'Informazioni';

  @override
  String get poiTabQuiz => 'Quiz';

  @override
  String get poiSectionHistory => 'Storia';

  @override
  String get poiStartQuiz => 'Fai il quiz su questa tappa →';

  @override
  String get poiNoQuiz => 'Nessun quiz disponibile per questa tappa.';

  @override
  String get quizNextQuestion => 'Prossima domanda →';

  @override
  String get quizFinish => 'Termina quiz →';

  @override
  String get quizNextStop => 'Prossima tappa →';

  @override
  String get quizNotice => 'Avviso quiz';

  @override
  String quizCorrectAnswers(int score, int total) {
    return '$score / $total risposte corrette';
  }

  @override
  String quizTime(String time) {
    return 'Tempo: $time';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Domanda $current di $total';
  }

  @override
  String get tourStartButton => 'Inizia il tour';

  @override
  String get tourArrivedButton => 'Sono arrivato';

  @override
  String get tourStopCardArrived => 'Sei arrivato! Tocca per aprire';

  @override
  String tourStopCardDistance(String distance, int index, int total) {
    return '$distance · tappa $index/$total';
  }

  @override
  String get tourPlanTitle => 'Ordine tappe';

  @override
  String get tourPlanSubtitle => 'Trascina dalla maniglia per riordinare il percorso.';

  @override
  String get tourPlanFirstStop => 'Prima tappa del tour';

  @override
  String tourPlanDistanceFromPrev(String distance) {
    return '$distance dalla precedente';
  }

  @override
  String get tourPlanCurrentLabel => 'Attuale';

  @override
  String get locationBannerMissingPermission => 'Permessi mancanti';

  @override
  String get locationBannerGpsOff => 'GPS Disattivato';

  @override
  String get locationBannerEnableLocation => 'Attiva la posizione per esplorare la mappa in tempo reale.';

  @override
  String get locationBannerReEnableLocation => 'Riattiva la posizione nelle impostazioni per mostrare la tua posizione sulla mappa.';

  @override
  String get locationBannerResolve => 'Risolvi';

  @override
  String get socialSearchHint => 'Cerca utente...';

  @override
  String get socialLeaderboardEmpty => 'Nessun utente in classifica al momento.';

  @override
  String get socialLeaderboard => 'Classifica Globale';

  @override
  String get socialNoUserFound => 'Nessun utente trovato.';

  @override
  String get socialTypeMoreChars => 'Digita almeno 2 caratteri per cercare.';

  @override
  String get socialYou => 'Tu';

  @override
  String get socialDefaultUsername => 'utente';

  @override
  String socialFriendsOf(String name) {
    return 'Amici di $name';
  }

  @override
  String get socialMustBeFriend => 'Devi essere amico per vedere la sua lista amici.';

  @override
  String get socialRequestSent => 'Richiesta inviata';

  @override
  String get socialAccept => 'Accetta';

  @override
  String get socialReject => 'Rifiuta';

  @override
  String get socialAddFriend => 'Aggiungi agli amici';

  @override
  String get publicStatDetailed => 'Statistiche Dettagliate';

  @override
  String get publicStatAchievements => 'Traguardi';

  @override
  String get publicStatBestScore => 'Miglior Score';

  @override
  String get publicStatSites => 'Siti Visitati';

  @override
  String get publicStatQuiz => 'Quiz Superati';

  @override
  String get publicStatBestTime => 'Tempo Migliore';

  @override
  String get publicStatCorrectAnswers => 'Risposte Esatte';

  @override
  String get publicStatFriends => 'Amici';

  @override
  String get publicStatPoints => 'Punti';

  @override
  String get publicStatLevel => 'Livello';

  @override
  String get errorLoginFailed => 'Accesso non riuscito. Controlla la connessione e riprova.';

  @override
  String get errorOffline => 'Sei offline. Controlla la connessione Internet e riprova.';

  @override
  String get errorLoginGeneric => 'Accesso non riuscito. Riprova tra qualche secondo.';

  @override
  String get loginGoogleButton => 'ACCEDI CON GOOGLE';

  @override
  String get errorCommunication => 'Errore durante la comunicazione con il server.';

  @override
  String get errorNotLoggedIn => 'Utente non loggato.';

  @override
  String get errorLoadPrefs => 'Errore nel caricamento preferenze.';

  @override
  String get errorGpsDenied => 'Permesso negato o GPS disattivato. Controlla le impostazioni.';

  @override
  String get errorConnectionSettings => 'Errore di connessione. Modifica annullata.';

  @override
  String get errorDeleteAccount => 'Impossibile eliminare i dati.';

  @override
  String get errorDeleteAccountAuth => 'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';

  @override
  String get errorSyncProfile => 'Impossibile sincronizzare il profilo.';

  @override
  String get errorSaveProfile => 'Salvataggio profilo non riuscito.';

  @override
  String get errorLoadLeaderboard => 'Impossibile caricare la classifica.';

  @override
  String get settingsTourTitle => 'Tour interattivo WWII';

  @override
  String get settingsTourSubtitle => 'Gestisci privacy, notifiche e lingua in un unico posto.';

  @override
  String get settingsCredits => 'Crediti';

  @override
  String get settingsCreditsTitle => 'Crediti e Riconoscimenti';

  @override
  String get settingsCreditsSubtitle => 'Scopri il team dietro Cesena Remembers';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutInProgress => 'Uscita in corso...';

  @override
  String get settingsLogoutSubtitle => 'Esci dall\'account corrente';

  @override
  String get settingsDelete => 'Elimina account';

  @override
  String get settingsDeleteInProgress => 'Eliminazione in corso...';

  @override
  String get settingsDeleteSubtitle => 'Rimuovi profilo e dati associati';

  @override
  String get settingsAppPrefs => 'Preferenze App';

  @override
  String get settingsNotifications => 'Notifiche';

  @override
  String get settingsNotifSubtitle => 'Ricevi avvisi su tappe e premi';

  @override
  String get settingsDarkMode => 'Modalità Notte';

  @override
  String get settingsDarkModeSubtitle => 'Tema scuro per l\'intera app';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsGps => 'Posizione GPS';

  @override
  String get settingsGpsSubtitle => 'Necessario per esplorare la mappa';

  @override
  String get settingsPrivacyPolicy => 'Informativa privacy';

  @override
  String get settingsPrivacySubtitle => 'Leggi come vengono trattati i dati';

  @override
  String get settingsGeneral => 'Generale';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsVersion => 'Versione';

  @override
  String get settingsTerms => 'Termini di servizio';

  @override
  String get settingsTermsSubtitle => 'Regole d\'uso e responsabilità';

  @override
  String get settingsContacts => 'Contatti';

  @override
  String get settingsClose => 'Chiudi';

  @override
  String get settingsPerfect => 'Perfetto';

  @override
  String get settingsDeleteConfirmTitle => 'Eliminare account?';

  @override
  String get settingsDeleteConfirmBody => 'Questa operazione rimuove account, progressi e dati associati in modo permanente.';

  @override
  String get settingsCancel => 'Annulla';

  @override
  String get settingsDeleteConfirmBtn => 'Elimina';

  @override
  String get settingsDeleteSuccess => 'Account eliminato definitivamente.';

  @override
  String get settingsDeleteError => 'Impossibile completare ora. Controlla il messaggio di errore.';

  @override
  String get achievement_first_visit_title => 'Primo passo';

  @override
  String get achievement_first_visit_desc => 'Visita il tuo primo sito storico';

  @override
  String get achievement_first_quiz_title => 'Studente';

  @override
  String get achievement_first_quiz_desc => 'Completa il tuo primo quiz';

  @override
  String get achievement_first_tour_title => 'Pioniere';

  @override
  String get achievement_first_tour_desc => 'Finisci il tuo primo tour completo';

  @override
  String get achievement_quiz_15_title => 'Veterano';

  @override
  String get achievement_quiz_15_desc => 'Completa 15 quiz';

  @override
  String get achievement_perfect_tour_title => 'Infallibile';

  @override
  String get achievement_perfect_tour_desc => 'Rispondi correttamente a tutte le domande in un tour';

  @override
  String get achievement_xp_500_title => 'Collezionista';

  @override
  String get achievement_xp_500_desc => 'Raggiungi 500 XP totali';

  @override
  String get achievement_tour_under_1h_title => 'In marcia';

  @override
  String get achievement_tour_under_1h_desc => 'Completa un tour in meno di 1 ora';

  @override
  String get achievement_tour_under_30m_title => 'Fulmine';

  @override
  String get achievement_tour_under_30m_desc => 'Completa un tour in meno di 30 minuti';

  @override
  String get achievement_friend_1_title => 'Cittadino';

  @override
  String get achievement_friend_1_desc => 'Aggiungi il tuo primo amico';

  @override
  String get achievement_friend_5_title => 'Circolo storico';

  @override
  String get achievement_friend_5_desc => 'Raggiungi 5 amici';

  @override
  String get poi_santa_cristina_name => 'Chiesa di Santa Cristina';

  @override
  String get poi_santa_cristina_desc => 'Chiesa storica con cupola emisferica e campanile, inserita nel tessuto urbano residenziale di Cesena. Rappresenta l\'equilibrio tra architettura religiosa e sviluppo cittadino. Durante la Seconda Guerra Mondiale fu un probabile punto di riferimento visivo durante i bombardamenti, utile per l\'orientamento della popolazione. L\'area circostante venne parzialmente colpita o modificata nel dopoguerra, con spazi urbani ridefiniti.';

  @override
  String get poi_rocca_name => 'Rocca Malatestiana';

  @override
  String get poi_rocca_desc => 'Fortezza medievale dominante sulla città, con mura merlate e torrioni; elemento difensivo e simbolico centrale di Cesena. Costruita dai Malatesta nel 1380, ospita la Biblioteca Malatestiana, patrimonio UNESCO dal 2005. Durante la Seconda Guerra Mondiale fu riutilizzata come rifugio naturale grazie alla sua struttura massiccia: il colle ospitò gallerie e rifugi antiaerei per la protezione della popolazione civile durante i bombardamenti.';

  @override
  String get poi_san_rocco_name => 'Chiesa di San Rocco';

  @override
  String get poi_san_rocco_desc => 'Chiesa situata in un quartiere popolare di Cesena, con edifici semplici e strade storicamente sterrate. Dedicata a San Rocco, patrono degli appestati, è da secoli un punto di riferimento spirituale per le classi lavoratrici. Durante la Seconda Guerra Mondiale il quartiere, abitato da famiglie operaie, fu direttamente esposto alle difficoltà dei bombardamenti e la chiesa rappresentò un possibile luogo di raccolta e transito verso i rifugi durante gli allarmi aerei.';

  @override
  String get poi_abbazia_monte_name => 'Abbazia di Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'Complesso monastico su un colle dominante la città, circondato da campagna coltivata; forte simbolo religioso e territoriale di Cesena da oltre mille anni. La sua posizione elevata la rese strategicamente significativa durante la Seconda Guerra Mondiale: fu usata come punto di osservazione o riferimento visivo per le operazioni militari. L\'area collinare offrì rifugio e isolamento rispetto ai bombardamenti del centro urbano.';

  @override
  String get poi_osservanza_name => 'Chiesa e Convento dell\'Osservanza';

  @override
  String get poi_osservanza_desc => 'Complesso religioso francescano immerso nella campagna cesenate, storicamente separato dal centro urbano. La chiesa conserva pregevoli opere d\'arte del Quattrocento e Cinquecento. Durante la Seconda Guerra Mondiale l\'isolamento rispetto alla città lo rendeva meno esposto agli attacchi diretti, diventando un possibile luogo di rifugio e assistenza spirituale per sfollati e popolazione rurale in fuga dai bombardamenti.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'Edificio storico con torre civica, simbolo del centro cittadino e della vita pubblica di Cesena. Affaccia sulla Piazza del Popolo, cuore della città fin dal Medioevo, dominata anche dalla fontana del Masini. Durante la Seconda Guerra Mondiale ospitava una sirena antiaerea fondamentale per segnalare l\'arrivo dei bombardamenti, costituendo un nodo vitale nel sistema di allarme e coordinamento della popolazione civile.';

  @override
  String get poi_stazione_name => 'Stazione Ferroviaria di Cesena';

  @override
  String get poi_stazione_desc => 'Importante nodo ferroviario per il trasporto merci e passeggeri tra l\'Ottocento e il Novecento, sulla linea adriatica Bologna–Rimini. Durante la Seconda Guerra Mondiale fu uno degli obiettivi strategici primari dei bombardamenti alleati, poiché interromperne i rifornimenti era essenziale per bloccare l\'avanzata tedesca. Subì gravi distruzioni, diventando uno dei punti più colpiti della città.';

  @override
  String get poi_arrigoni_name => 'Stabilimento Arrigoni';

  @override
  String get poi_arrigoni_desc => 'Grande industria conserviera fondata nel 1880, cuore dell\'economia locale e del lavoro operaio cesenate per oltre un secolo. Specializzata in conserve ittiche, fu tra le più importanti aziende della Romagna. Durante la Seconda Guerra Mondiale la struttura produttiva era strategicamente rilevante per la logistica alimentare, e fu teatro di scioperi e forti tensioni sociali, soprattutto nel biennio 1943–1944.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'Palazzo storico nel cuore di Cesena, sede del Partito Nazionale Fascista locale durante il regime mussoliniano. Rappresenta uno dei simboli del ventennio fascista in città. Durante la Seconda Guerra Mondiale fu il centro del potere politico e amministrativo fascista a livello cittadino, probabile luogo di repressione, controllo della popolazione e organizzazione delle attività belliche sul territorio.';

  @override
  String get poi_rifugi_antiaerei_name => 'Rifugi Antiaerei della Rocca';

  @override
  String get poi_rifugi_antiaerei_desc => 'Sistema di tunnel sotterranei scavati sotto e intorno alla Rocca Malatestiana per proteggere la popolazione civile dai bombardamenti aerei. Durante la Seconda Guerra Mondiale furono fondamentali per la sopravvivenza di centinaia di cesenati: i rifugi accolsero famiglie intere, diventando veri e propri spazi di vita temporanea sotterranea durante gli attacchi alleati tra il 1943 e il 1944.';

  @override
  String setupUsernameInvalid(int min, int max) {
    return 'Username non valido (usa $min-$max caratteri: a-z, 0-9, _ o .).';
  }

  @override
  String get setupUsernameOffensive => 'Username contiene termini non consentiti. Scegline uno diverso.';

  @override
  String get setupUsernameTaken => 'Username già in uso. Scegline un altro.';

  @override
  String setupFirestoreError(Object username) {
    return 'Configurazione Firestore non valida: servono permessi di lettura/scrittura su usernames/$username.';
  }

  @override
  String get setupPermissionDenied => 'Permessi Firestore insufficienti per completare il profilo. Controlla le regole del progetto.';

  @override
  String get setupGenericError => 'Impossibile salvare il profilo. Riprova tra qualche secondo.';

  @override
  String get setupTitle => 'Crea il tuo profilo';

  @override
  String get setupSubtitle => 'Scegli username univoco (non modificabile), nome in app e avatar.';

  @override
  String get setupNameLabel => 'Nome in app';

  @override
  String get setupUsernameLabel => 'Username';

  @override
  String get setupUsernameHint => 'es. cesena_explorer';

  @override
  String get setupAvatarLabel => 'Scegli avatar';

  @override
  String get setupSubmitButton => 'Conferma profilo';

  @override
  String get creditRoleDiplo => 'Rappresentanze Diplomatiche Tedesche in Italia';

  @override
  String get creditRoleDiploDesc => 'Sviluppato grazie al loro prezioso contributo';

  @override
  String get sectionSupport => 'Collaboratori e Supporto';

  @override
  String get quiz_fallback_name => 'Difficoltà standard (seed locale)';

  @override
  String get quiz_fallback_desc => 'Per un errore del server le domande non sono personalizzate e usano una difficoltà locale specifica.';

  @override
  String get quiz_santa_cristina_q1 => 'Quale elemento architettonico caratterizza la chiesa?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'Un campanile gotico';

  @override
  String get quiz_santa_cristina_q1_o2 => 'Una cupola emisferica';

  @override
  String get quiz_santa_cristina_q1_o3 => 'Un rosone rinascimentale';

  @override
  String get quiz_santa_cristina_q2 => 'Quale ruolo ebbe la chiesa durante la Seconda Guerra Mondiale?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'Fu usata come ospedale da campo';

  @override
  String get quiz_santa_cristina_q2_o2 => 'Fu un riferimento visivo per orientarsi durante i bombardamenti';

  @override
  String get quiz_santa_cristina_q2_o3 => 'Fu sede del comando militare tedesco';

  @override
  String get quiz_rocca_q1 => 'Chi ha fatto costruire la Rocca?';

  @override
  String get quiz_rocca_q1_o1 => 'I Visconti';

  @override
  String get quiz_rocca_q1_o2 => 'I Malatesta';

  @override
  String get quiz_rocca_q1_o3 => 'Federico da Montefeltro';

  @override
  String get quiz_rocca_q2 => 'In quale anno la Biblioteca Malatestiana è diventata patrimonio UNESCO?';

  @override
  String get quiz_rocca_q2_o1 => '1995';

  @override
  String get quiz_rocca_q2_o2 => '2005';

  @override
  String get quiz_rocca_q2_o3 => '2015';

  @override
  String get quiz_rocca_q3 => 'Come fu usata la Rocca durante la Seconda Guerra Mondiale?';

  @override
  String get quiz_rocca_q3_o1 => 'Come prigione per i partigiani';

  @override
  String get quiz_rocca_q3_o2 => 'Come rifugio antiaereo per i civili';

  @override
  String get quiz_rocca_q3_o3 => 'Come deposito di munizioni';

  @override
  String get quiz_san_rocco_q1 => 'A quale santo è dedicata la chiesa?';

  @override
  String get quiz_san_rocco_q1_o1 => 'San Francesco';

  @override
  String get quiz_san_rocco_q1_o2 => 'San Rocco';

  @override
  String get quiz_san_rocco_q1_o3 => 'Sant\'Antonio';

  @override
  String get quiz_san_rocco_q2 => 'In quale tipo di quartiere sorge la chiesa?';

  @override
  String get quiz_san_rocco_q2_o1 => 'Quartiere nobiliare';

  @override
  String get quiz_san_rocco_q2_o2 => 'Quartiere popolare operaio';

  @override
  String get quiz_san_rocco_q2_o3 => 'Quartiere universitario';

  @override
  String get quiz_abbazia_monte_q1 => 'Dove sorge l\'abbazia?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'In pianura, vicino al fiume';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'Su un colle dominante la città';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'Nel centro storico';

  @override
  String get quiz_abbazia_monte_q2 => 'Quale vantaggio offrì l\'abbazia durante la guerra?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'Ospitava un deposito di viveri militari';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'La posizione elevata la rendeva utile come punto di osservazione';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'Era sede del governo provvisorio';

  @override
  String get quiz_osservanza_q1 => 'A quale ordine religioso appartiene il convento?';

  @override
  String get quiz_osservanza_q1_o1 => 'Domenicani';

  @override
  String get quiz_osservanza_q1_o2 => 'Francescani';

  @override
  String get quiz_osservanza_q1_o3 => 'Benedettini';

  @override
  String get quiz_osservanza_q2 => 'Perché il convento era meno esposto ai bombardamenti?';

  @override
  String get quiz_osservanza_q2_o1 => 'Era protetto da bunker sotterranei';

  @override
  String get quiz_osservanza_q2_o2 => 'Era isolato rispetto al centro urbano';

  @override
  String get quiz_osservanza_q2_o3 => 'Era presidiato dall\'esercito alleato';

  @override
  String get quiz_palazzo_ridotto_q1 => 'Come si chiama la fontana in Piazza del Popolo?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'Fontana di Nettuno';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'Fontana del Masini';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'Fontana dei Delfini';

  @override
  String get quiz_palazzo_ridotto_q2 => 'Quale dispositivo bellico era installato nel palazzo?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'Una mitragliatrice antiaerea';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'Una sirena antiaerea';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'Un radar di avvistamento';

  @override
  String get quiz_stazione_q1 => 'Perché la stazione era un obiettivo dei bombardamenti alleati?';

  @override
  String get quiz_stazione_q1_o1 => 'Ospitava il quartier generale tedesco';

  @override
  String get quiz_stazione_q1_o2 => 'Era un nodo strategico per i rifornimenti militari';

  @override
  String get quiz_stazione_q1_o3 => 'Era l\'unico ospedale della città';

  @override
  String get quiz_stazione_q2 => 'Su quale linea ferroviaria si trova la stazione di Cesena?';

  @override
  String get quiz_stazione_q2_o1 => 'Bologna–Firenze';

  @override
  String get quiz_stazione_q2_o2 => 'Bologna–Rimini (linea adriatica)';

  @override
  String get quiz_stazione_q2_o3 => 'Rimini–Roma';

  @override
  String get quiz_arrigoni_q1 => 'In quale settore operava lo Stabilimento Arrigoni?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Industria tessile';

  @override
  String get quiz_arrigoni_q1_o2 => 'Conserve ittiche e alimentari';

  @override
  String get quiz_arrigoni_q1_o3 => 'Meccanica pesante';

  @override
  String get quiz_arrigoni_q2 => 'Cosa accadde nello stabilimento nel 1943–1944?';

  @override
  String get quiz_arrigoni_q2_o1 => 'Fu convertito in ospedale militare';

  @override
  String get quiz_arrigoni_q2_o2 => 'Fu teatro di scioperi e tensioni sociali';

  @override
  String get quiz_arrigoni_q2_o3 => 'Fu utilizzato come prigione dai tedeschi';

  @override
  String get quiz_fantaguzzi_q1 => 'Quale organizzazione aveva sede nel Palazzo Fantaguzzi durante il regime?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'Il Comune di Cesena';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'Il Partito Nazionale Fascista';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'La Croce Rossa';

  @override
  String get quiz_fantaguzzi_q2 => 'Quale ruolo ebbe il palazzo durante la guerra?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'Centro di coordinamento della resistenza partigiana';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'Centro del potere politico e amministrativo fascista';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'Sede del tribunale militare alleato';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'Dove erano scavati i rifugi antiaerei?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'Sotto il Palazzo del Ridotto';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'Sotto e intorno alla Rocca Malatestiana';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'Sotto la stazione ferroviaria';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'In quali anni furono principalmente utilizzati i rifugi?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => '1940–1941';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => '1943–1944';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => '1945–1946';
}
