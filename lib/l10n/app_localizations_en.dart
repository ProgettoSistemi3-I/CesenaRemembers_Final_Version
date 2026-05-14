// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Cesena Remembers 1945';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsHeaderTitle => 'Interactive WWII Tour';

  @override
  String get settingsHeaderSubtitle => 'Manage privacy, notifications and language in one place.';

  @override
  String get sectionCredits => 'Credits';

  @override
  String get creditsTitle => 'Credits & Acknowledgements';

  @override
  String get creditsSubtitle => 'Discover the team behind Cesena Remembers';

  @override
  String get creditsPageTitle => 'Acknowledgements';

  @override
  String get creditsAppName => 'Cesena Remembers';

  @override
  String get creditsAppDescription => 'Made with passion to preserve the historical memory of our city.';

  @override
  String get sectionTeam => 'The Team';

  @override
  String get sectionThanks => 'Thanks';

  @override
  String get creditRoleDev => 'Development & Architecture';

  @override
  String get creditRoleTeacher => 'Supervising Teacher';

  @override
  String get creditRoleClass => 'Support & Ideation';

  @override
  String get creditSchoolSubtitle => 'Visit the school website';

  @override
  String get sectionAccount => 'Account';

  @override
  String get logoutTitle => 'Logout';

  @override
  String get logoutSubtitle => 'Sign out of the current account';

  @override
  String get loggingOut => 'Signing out...';

  @override
  String get deleteAccountTitle => 'Delete account';

  @override
  String get deleteAccountSubtitle => 'Remove profile and associated data';

  @override
  String get deletingAccount => 'Deleting...';

  @override
  String get deleteAccountDialogTitle => 'Delete account?';

  @override
  String get deleteAccountDialogBody => 'This action permanently removes the account, progress and all associated data.';

  @override
  String get deleteAccountSuccess => 'Account permanently deleted.';

  @override
  String get deleteAccountFailure => 'Could not complete now. Check the error message.';

  @override
  String get sectionPreferences => 'App Preferences';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSubtitle => 'Receive alerts on stops and rewards';

  @override
  String get darkModeTitle => 'Night Mode';

  @override
  String get darkModeSubtitle => 'Dark theme for the entire app';

  @override
  String get sectionPrivacy => 'Privacy';

  @override
  String get gpsTitle => 'GPS Location';

  @override
  String get gpsSubtitle => 'Required to explore the map';

  @override
  String get privacyPolicyTitle => 'Privacy policy';

  @override
  String get privacyPolicySubtitle => 'Read how your data is handled';

  @override
  String get gpsPermissionDenied => 'Permission denied or GPS disabled. Check your phone settings.';

  @override
  String get sectionGeneral => 'General';

  @override
  String get languageTitle => 'Language';

  @override
  String get sectionInfo => 'Info';

  @override
  String get versionTitle => 'Version';

  @override
  String get versionSubtitle => '1.0.0';

  @override
  String get versionSheetTitle => 'App version';

  @override
  String get versionSheetBody => 'Build number: 1.0.0';

  @override
  String get termsTitle => 'Terms of service';

  @override
  String get termsSubtitle => 'Usage rules and responsibilities';

  @override
  String get contactsTitle => 'Contacts';

  @override
  String get contactsSubtitle => 'cesenaremembers@gmail.com';

  @override
  String get buttonClose => 'Close';

  @override
  String get buttonCancel => 'Cancel';

  @override
  String get buttonDelete => 'Delete';

  @override
  String get buttonOk => 'Got it';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String errorLoadPreferences(String error) {
    return 'Error loading preferences: $error';
  }

  @override
  String get errorConnection => 'Connection error. Change cancelled.';

  @override
  String errorLogout(String error) {
    return 'Logout failed: $error';
  }

  @override
  String get errorDeleteAccountPartial => 'Account not fully deleted. App data was removed, but auth deletion failed. You will be signed out for safety.';

  @override
  String errorDeleteData(String error) {
    return 'Unable to delete data: $error';
  }

  @override
  String get tourStopped => 'Tour stopped.';

  @override
  String get errorSaveScore => 'Error saving score. Try again in a moment.';

  @override
  String get errorLoadPoi => 'Error loading points of interest.';

  @override
  String get errorSearch => 'Error during search.';

  @override
  String get errorAction => 'Error during action.';

  @override
  String get removeFriendship => 'Remove friendship';

  @override
  String get locationDisabled => 'Location disabled';

  @override
  String get quizAnswerPerfect => 'Perfect!';

  @override
  String get quizAnswerGood => 'Well done!';

  @override
  String get toursCompleted => 'Tours Completed';

  @override
  String get tourLabel => 'Tour';

  @override
  String get tourConfirmStopTitle => 'Stop the tour?';

  @override
  String get tourConfirmStopBody => 'The tour will be ended and you will lose the current stop order.';

  @override
  String get buttonStop => 'Stop';

  @override
  String get tourStartGpsRequired => 'To start the tour, enable GPS, location permission and the in-app option.';

  @override
  String get tourCompleted => '🎉 Tour completed! Great job.';

  @override
  String get tourStopButton => 'Stop tour';

  @override
  String get tourOrderButton => 'Order stops';

  @override
  String get tourStartButton => 'Start tour';
  @override
  String get tourArrivedTapOpen => 'You arrived! Tap to open';
  @override
  String get tourStopShort => 'stop';
  @override
  String get currentLabel => 'Current';
  @override
  String get firstTourStop => 'First tour stop';
  @override
  String get fromPrevious => 'from previous';
  @override
  String get takeQuizThisStop => 'Take the quiz for this stop →';
  @override
  String get noQuizForStop => 'No quiz available for this stop.';
  @override
  String get questionLabel => 'Question';
  @override
  String get ofLabel => 'of';
  @override
  String get finishQuiz => 'Finish quiz →';
  @override
  String get quizNotice => 'Quiz notice';
  @override
  String get nextQuestion => 'Next question →';
  @override
  String get offlineRetry => 'You are offline. Check your Internet connection and try again.';
  @override
  String get loginRetrySoon => 'Sign-in failed. Try again in a few seconds.';
  @override
  String get loginCheckConnection => 'Sign-in failed. Check your connection and try again.';
  @override
  String get statisticsLabel => 'Statistics';
  @override
  String get totalXp => 'Total XP';
  @override
  String get bestTourXp => 'Best tour (XP)';
  @override
  String get visitedSites => 'Visited Sites';
  @override
  String get bestTime => 'Best Time';
  @override
  String get achievementsLabel => 'Achievements';

  @override
  String get noLeaderboardUsers => 'No users in leaderboard yet.';

  @override
  String get noUsersFound => 'No users found.';

  @override
  String get operationFailedRestored => 'Operation failed. State restored.';

  @override
  String get detailedStats => 'Detailed Statistics';

  @override
  String get bestScore => 'Best Score';

  @override
  String get fundingLabel => 'Funding';

  @override
  String get fundingSubtitle => 'Developed thanks to their valuable support';

  @override
  String get missingPermissions => 'Missing permissions';

  @override
  String get nextStop => 'Next stop →';
}
