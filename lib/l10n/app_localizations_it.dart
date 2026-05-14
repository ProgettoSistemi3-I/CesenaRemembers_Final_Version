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
  String get navMap => 'Mappa';

  @override
  String get navProfile => 'Profilo';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String errorLoadPreferences(String error) {
    return 'Errore nel caricamento preferenze: $error';
  }

  @override
  String get errorConnection => 'Errore di connessione. Modifica annullata.';

  @override
  String errorLogout(String error) {
    return 'Logout fallito: $error';
  }

  @override
  String get errorDeleteAccountPartial => 'Account non eliminato completamente. I dati app sono stati rimossi, ma la cancellazione auth è fallita. Verrai disconnesso per sicurezza.';

  @override
  String errorDeleteData(String error) {
    return 'Impossibile eliminare i dati: $error';
  }

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
  String get tourStartButton => 'Inizia il tour';
  @override
  String get tourArrivedTapOpen => 'Sei arrivato! Tocca per aprire';
  @override
  String get tourStopShort => 'tappa';
  @override
  String get currentLabel => 'Attuale';
  @override
  String get firstTourStop => 'Prima tappa del tour';
  @override
  String get fromPrevious => 'dalla precedente';
  @override
  String get takeQuizThisStop => 'Fai il quiz su questa tappa →';
  @override
  String get noQuizForStop => 'Nessun quiz disponibile per questa tappa.';
  @override
  String get questionLabel => 'Domanda';
  @override
  String get ofLabel => 'di';
  @override
  String get finishQuiz => 'Termina quiz →';
  @override
  String get quizNotice => 'Avviso quiz';
  @override
  String get nextQuestion => 'Prossima domanda →';
  @override
  String get offlineRetry => 'Sei offline. Controlla la connessione Internet e riprova.';
  @override
  String get loginRetrySoon => 'Accesso non riuscito. Riprova tra qualche secondo.';
  @override
  String get loginCheckConnection => 'Accesso non riuscito. Controlla la connessione e riprova.';
  @override
  String get statisticsLabel => 'Statistiche';
  @override
  String get totalXp => 'XP Totali';
  @override
  String get bestTourXp => 'Miglior tour (XP)';
  @override
  String get visitedSites => 'Siti Visitati';
  @override
  String get bestTime => 'Miglior tempo';
  @override
  String get achievementsLabel => 'Achievement';

  @override
  String get noLeaderboardUsers => 'Nessun utente in classifica al momento.';

  @override
  String get noUsersFound => 'Nessun utente trovato.';

  @override
  String get operationFailedRestored => 'Operazione non riuscita. Stato ripristinato.';

  @override
  String get detailedStats => 'Statistiche Dettagliate';

  @override
  String get bestScore => 'Miglior Score';

  @override
  String get fundingLabel => 'Finanziamento';

  @override
  String get fundingSubtitle => 'Sviluppato grazie al loro prezioso contributo';

  @override
  String get missingPermissions => 'Permessi mancanti';

  @override
  String get nextStop => 'Prossima tappa →';
}
