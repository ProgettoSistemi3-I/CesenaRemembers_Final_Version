import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Cesena Remembers 1945'**
  String get appTitle;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsHeaderTitle.
  ///
  /// In en, this message translates to:
  /// **'Interactive WWII Tour'**
  String get settingsHeaderTitle;

  /// No description provided for @settingsHeaderSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy, notifications and language in one place.'**
  String get settingsHeaderSubtitle;

  /// No description provided for @sectionCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get sectionCredits;

  /// No description provided for @creditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits & Acknowledgements'**
  String get creditsTitle;

  /// No description provided for @creditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the team behind Cesena Remembers'**
  String get creditsSubtitle;

  /// No description provided for @creditsPageTitle.
  ///
  /// In en, this message translates to:
  /// **'Acknowledgements'**
  String get creditsPageTitle;

  /// No description provided for @creditsAppName.
  ///
  /// In en, this message translates to:
  /// **'Cesena Remembers'**
  String get creditsAppName;

  /// No description provided for @creditsAppDescription.
  ///
  /// In en, this message translates to:
  /// **'Made with passion to preserve the historical memory of our city.'**
  String get creditsAppDescription;

  /// No description provided for @sectionTeam.
  ///
  /// In en, this message translates to:
  /// **'The Team'**
  String get sectionTeam;

  /// No description provided for @sectionThanks.
  ///
  /// In en, this message translates to:
  /// **'Thanks'**
  String get sectionThanks;

  /// No description provided for @creditRoleDev.
  ///
  /// In en, this message translates to:
  /// **'Development & Architecture'**
  String get creditRoleDev;

  /// No description provided for @creditRoleTeacher.
  ///
  /// In en, this message translates to:
  /// **'Supervising Teacher'**
  String get creditRoleTeacher;

  /// No description provided for @creditRoleClass.
  ///
  /// In en, this message translates to:
  /// **'Support & Ideation'**
  String get creditRoleClass;

  /// No description provided for @creditSchoolSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Visit the school website'**
  String get creditSchoolSubtitle;

  /// No description provided for @sectionAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get sectionAccount;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logoutTitle;

  /// No description provided for @logoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of the current account'**
  String get logoutSubtitle;

  /// No description provided for @loggingOut.
  ///
  /// In en, this message translates to:
  /// **'Signing out...'**
  String get loggingOut;

  /// No description provided for @deleteAccountTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccountTitle;

  /// No description provided for @deleteAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove profile and associated data'**
  String get deleteAccountSubtitle;

  /// No description provided for @deletingAccount.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get deletingAccount;

  /// No description provided for @deleteAccountDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get deleteAccountDialogTitle;

  /// No description provided for @deleteAccountDialogBody.
  ///
  /// In en, this message translates to:
  /// **'This action permanently removes the account, progress and all associated data.'**
  String get deleteAccountDialogBody;

  /// No description provided for @deleteAccountSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account permanently deleted.'**
  String get deleteAccountSuccess;

  /// No description provided for @deleteAccountFailure.
  ///
  /// In en, this message translates to:
  /// **'Could not complete now. Check the error message.'**
  String get deleteAccountFailure;

  /// No description provided for @sectionPreferences.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get sectionPreferences;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts on stops and rewards'**
  String get notificationsSubtitle;

  /// No description provided for @darkModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Night Mode'**
  String get darkModeTitle;

  /// No description provided for @darkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme for the entire app'**
  String get darkModeSubtitle;

  /// No description provided for @sectionPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get sectionPrivacy;

  /// No description provided for @gpsTitle.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get gpsTitle;

  /// No description provided for @gpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to explore the map'**
  String get gpsSubtitle;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how your data is handled'**
  String get privacyPolicySubtitle;

  /// No description provided for @gpsPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied or GPS disabled. Check your phone settings.'**
  String get gpsPermissionDenied;

  /// No description provided for @sectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get sectionGeneral;

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @sectionInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get sectionInfo;

  /// No description provided for @versionTitle.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get versionTitle;

  /// No description provided for @versionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'1.0.0'**
  String get versionSubtitle;

  /// No description provided for @versionSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get versionSheetTitle;

  /// No description provided for @versionSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Build number: 1.0.0'**
  String get versionSheetBody;

  /// No description provided for @termsTitle.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get termsTitle;

  /// No description provided for @termsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Usage rules and responsibilities'**
  String get termsSubtitle;

  /// No description provided for @contactsTitle.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get contactsTitle;

  /// No description provided for @contactsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'cesenaremembers@gmail.com'**
  String get contactsSubtitle;

  /// No description provided for @buttonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get buttonClose;

  /// No description provided for @buttonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get buttonCancel;

  /// No description provided for @buttonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get buttonDelete;

  /// No description provided for @buttonOk.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get buttonOk;

  /// No description provided for @buttonRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get buttonRetry;

  /// No description provided for @navMap.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get navMap;

  /// No description provided for @navProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @errorLoadPreferences.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences: {error}'**
  String errorLoadPreferences(String error);

  /// No description provided for @errorConnection.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Change cancelled.'**
  String get errorConnection;

  /// No description provided for @errorLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout failed.'**
  String errorLogout(String error);

  /// No description provided for @errorDeleteAccountPartial.
  ///
  /// In en, this message translates to:
  /// **'Account not fully deleted. App data was removed, but auth deletion failed. You will be signed out for safety.'**
  String get errorDeleteAccountPartial;

  /// No description provided for @errorDeleteData.
  ///
  /// In en, this message translates to:
  /// **'Unable to delete data: {error}'**
  String errorDeleteData(String error);

  /// No description provided for @errorLoadProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load profile.'**
  String get errorLoadProfile;

  /// No description provided for @errorOperationFailed.
  ///
  /// In en, this message translates to:
  /// **'Operation failed. State restored.'**
  String get errorOperationFailed;

  /// No description provided for @tourStopped.
  ///
  /// In en, this message translates to:
  /// **'Tour stopped.'**
  String get tourStopped;

  /// No description provided for @errorSaveScore.
  ///
  /// In en, this message translates to:
  /// **'Error saving score. Try again in a moment.'**
  String get errorSaveScore;

  /// No description provided for @errorLoadPoi.
  ///
  /// In en, this message translates to:
  /// **'Error loading points of interest.'**
  String get errorLoadPoi;

  /// No description provided for @errorSearch.
  ///
  /// In en, this message translates to:
  /// **'Error during search.'**
  String get errorSearch;

  /// No description provided for @errorAction.
  ///
  /// In en, this message translates to:
  /// **'Error performing action.'**
  String get errorAction;

  /// No description provided for @removeFriendship.
  ///
  /// In en, this message translates to:
  /// **'Remove friendship'**
  String get removeFriendship;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location disabled'**
  String get locationDisabled;

  /// No description provided for @quizAnswerPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect!'**
  String get quizAnswerPerfect;

  /// No description provided for @quizAnswerGood.
  ///
  /// In en, this message translates to:
  /// **'Well done!'**
  String get quizAnswerGood;

  /// No description provided for @toursCompleted.
  ///
  /// In en, this message translates to:
  /// **'Tours Completed'**
  String get toursCompleted;

  /// No description provided for @tourLabel.
  ///
  /// In en, this message translates to:
  /// **'Tour'**
  String get tourLabel;

  /// No description provided for @tourConfirmStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop the tour?'**
  String get tourConfirmStopTitle;

  /// No description provided for @tourConfirmStopBody.
  ///
  /// In en, this message translates to:
  /// **'The tour will be ended and you will lose the current stop order.'**
  String get tourConfirmStopBody;

  /// No description provided for @buttonStop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get buttonStop;

  /// No description provided for @tourStartGpsRequired.
  ///
  /// In en, this message translates to:
  /// **'To start the tour, enable GPS, location permission and the in-app option.'**
  String get tourStartGpsRequired;

  /// No description provided for @tourCompleted.
  ///
  /// In en, this message translates to:
  /// **'🎉 Tour completed! Great job.'**
  String get tourCompleted;

  /// No description provided for @tourStopButton.
  ///
  /// In en, this message translates to:
  /// **'Stop tour'**
  String get tourStopButton;

  /// No description provided for @tourOrderButton.
  ///
  /// In en, this message translates to:
  /// **'Order stops'**
  String get tourOrderButton;

  /// No description provided for @profileTitle.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get profileTitle;

  /// No description provided for @sectionStatistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get sectionStatistics;

  /// No description provided for @sectionAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get sectionAchievements;

  /// No description provided for @statTotalXp.
  ///
  /// In en, this message translates to:
  /// **'Total XP'**
  String get statTotalXp;

  /// No description provided for @statBestTour.
  ///
  /// In en, this message translates to:
  /// **'Best tour (XP)'**
  String get statBestTour;

  /// No description provided for @statVisitedSites.
  ///
  /// In en, this message translates to:
  /// **'Sites Visited'**
  String get statVisitedSites;

  /// No description provided for @statBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best time'**
  String get statBestTime;

  /// No description provided for @statAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get statAchievements;

  /// No description provided for @profileFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get profileFriends;

  /// No description provided for @profilePoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get profilePoints;

  /// No description provided for @profileNoRequests.
  ///
  /// In en, this message translates to:
  /// **'No requests at the moment.'**
  String get profileNoRequests;

  /// No description provided for @profileYourFriends.
  ///
  /// In en, this message translates to:
  /// **'Your Friends'**
  String get profileYourFriends;

  /// No description provided for @profileFriendRequests.
  ///
  /// In en, this message translates to:
  /// **'Friend Requests'**
  String get profileFriendRequests;

  /// No description provided for @profileNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be {min}-{max} characters.'**
  String profileNameTooShort(int min, int max);

  /// No description provided for @profileNameOffensive.
  ///
  /// In en, this message translates to:
  /// **'The name contains forbidden terms.\nPlease choose a different one.'**
  String get profileNameOffensive;

  /// No description provided for @avatarPickerTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose your Avatar'**
  String get avatarPickerTitle;

  /// No description provided for @avatarPickerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Customize your profile'**
  String get avatarPickerSubtitle;

  /// No description provided for @poiTabInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get poiTabInfo;

  /// No description provided for @poiTabQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quiz'**
  String get poiTabQuiz;

  /// No description provided for @poiSectionHistory.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get poiSectionHistory;

  /// No description provided for @poiStartQuiz.
  ///
  /// In en, this message translates to:
  /// **'Take the quiz for this stop →'**
  String get poiStartQuiz;

  /// No description provided for @poiNoQuiz.
  ///
  /// In en, this message translates to:
  /// **'No quiz available for this stop.'**
  String get poiNoQuiz;

  /// No description provided for @quizNextQuestion.
  ///
  /// In en, this message translates to:
  /// **'Next question →'**
  String get quizNextQuestion;

  /// No description provided for @quizFinish.
  ///
  /// In en, this message translates to:
  /// **'Finish quiz →'**
  String get quizFinish;

  /// No description provided for @quizNextStop.
  ///
  /// In en, this message translates to:
  /// **'Next stop →'**
  String get quizNextStop;

  /// No description provided for @quizNotice.
  ///
  /// In en, this message translates to:
  /// **'Quiz notice'**
  String get quizNotice;

  /// No description provided for @quizCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'{score} / {total} correct answers'**
  String quizCorrectAnswers(int score, int total);

  /// No description provided for @quizTime.
  ///
  /// In en, this message translates to:
  /// **'Time: {time}'**
  String quizTime(String time);

  /// No description provided for @quizQuestion.
  ///
  /// In en, this message translates to:
  /// **'Question {current} of {total}'**
  String quizQuestion(int current, int total);

  /// No description provided for @tourStartButton.
  ///
  /// In en, this message translates to:
  /// **'Start tour'**
  String get tourStartButton;

  /// No description provided for @tourArrivedButton.
  ///
  /// In en, this message translates to:
  /// **'I\'m here'**
  String get tourArrivedButton;

  /// No description provided for @tourStopCardArrived.
  ///
  /// In en, this message translates to:
  /// **'You arrived! Tap to open'**
  String get tourStopCardArrived;

  /// No description provided for @tourStopCardDistance.
  ///
  /// In en, this message translates to:
  /// **'{distance} · stop {index}/{total}'**
  String tourStopCardDistance(String distance, int index, int total);

  /// No description provided for @tourPlanTitle.
  ///
  /// In en, this message translates to:
  /// **'Stop order'**
  String get tourPlanTitle;

  /// No description provided for @tourPlanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Drag the handle to reorder the route.'**
  String get tourPlanSubtitle;

  /// No description provided for @tourPlanFirstStop.
  ///
  /// In en, this message translates to:
  /// **'First stop of the tour'**
  String get tourPlanFirstStop;

  /// No description provided for @tourPlanDistanceFromPrev.
  ///
  /// In en, this message translates to:
  /// **'{distance} from previous'**
  String tourPlanDistanceFromPrev(String distance);

  /// No description provided for @tourPlanCurrentLabel.
  ///
  /// In en, this message translates to:
  /// **'Current'**
  String get tourPlanCurrentLabel;

  /// No description provided for @locationBannerMissingPermission.
  ///
  /// In en, this message translates to:
  /// **'Missing permissions'**
  String get locationBannerMissingPermission;

  /// No description provided for @locationBannerGpsOff.
  ///
  /// In en, this message translates to:
  /// **'GPS Disabled'**
  String get locationBannerGpsOff;

  /// No description provided for @locationBannerEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Enable location to explore the map in real time.'**
  String get locationBannerEnableLocation;

  /// No description provided for @locationBannerReEnableLocation.
  ///
  /// In en, this message translates to:
  /// **'Re-enable location in settings to show your position on the map.'**
  String get locationBannerReEnableLocation;

  /// No description provided for @locationBannerResolve.
  ///
  /// In en, this message translates to:
  /// **'Fix'**
  String get locationBannerResolve;

  /// No description provided for @socialSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search user...'**
  String get socialSearchHint;

  /// No description provided for @socialLeaderboardEmpty.
  ///
  /// In en, this message translates to:
  /// **'No users in the leaderboard right now.'**
  String get socialLeaderboardEmpty;

  /// No description provided for @socialLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Global Leaderboard'**
  String get socialLeaderboard;

  /// No description provided for @socialNoUserFound.
  ///
  /// In en, this message translates to:
  /// **'No user found.'**
  String get socialNoUserFound;

  /// No description provided for @socialTypeMoreChars.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search.'**
  String get socialTypeMoreChars;

  /// No description provided for @socialYou.
  ///
  /// In en, this message translates to:
  /// **'You'**
  String get socialYou;

  /// No description provided for @socialDefaultUsername.
  ///
  /// In en, this message translates to:
  /// **'user'**
  String get socialDefaultUsername;

  /// No description provided for @socialFriendsOf.
  ///
  /// In en, this message translates to:
  /// **'Friends of {name}'**
  String socialFriendsOf(String name);

  /// No description provided for @socialMustBeFriend.
  ///
  /// In en, this message translates to:
  /// **'You must be friends to view their friend list.'**
  String get socialMustBeFriend;

  /// No description provided for @socialRequestSent.
  ///
  /// In en, this message translates to:
  /// **'Request sent'**
  String get socialRequestSent;

  /// No description provided for @socialAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get socialAccept;

  /// No description provided for @socialReject.
  ///
  /// In en, this message translates to:
  /// **'Decline'**
  String get socialReject;

  /// No description provided for @socialAddFriend.
  ///
  /// In en, this message translates to:
  /// **'Add as friend'**
  String get socialAddFriend;

  /// No description provided for @publicStatDetailed.
  ///
  /// In en, this message translates to:
  /// **'Detailed Statistics'**
  String get publicStatDetailed;

  /// No description provided for @publicStatAchievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get publicStatAchievements;

  /// No description provided for @publicStatBestScore.
  ///
  /// In en, this message translates to:
  /// **'Best Score'**
  String get publicStatBestScore;

  /// No description provided for @publicStatSites.
  ///
  /// In en, this message translates to:
  /// **'Sites Visited'**
  String get publicStatSites;

  /// No description provided for @publicStatQuiz.
  ///
  /// In en, this message translates to:
  /// **'Quizzes Passed'**
  String get publicStatQuiz;

  /// No description provided for @publicStatBestTime.
  ///
  /// In en, this message translates to:
  /// **'Best Time'**
  String get publicStatBestTime;

  /// No description provided for @publicStatCorrectAnswers.
  ///
  /// In en, this message translates to:
  /// **'Correct Answers'**
  String get publicStatCorrectAnswers;

  /// No description provided for @publicStatFriends.
  ///
  /// In en, this message translates to:
  /// **'Friends'**
  String get publicStatFriends;

  /// No description provided for @publicStatPoints.
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get publicStatPoints;

  /// No description provided for @publicStatLevel.
  ///
  /// In en, this message translates to:
  /// **'Level'**
  String get publicStatLevel;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Check your connection and try again.'**
  String get errorLoginFailed;

  /// No description provided for @errorOffline.
  ///
  /// In en, this message translates to:
  /// **'You are offline. Check your Internet connection and try again.'**
  String get errorOffline;

  /// No description provided for @errorLoginGeneric.
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please try again in a few seconds.'**
  String get errorLoginGeneric;

  /// No description provided for @loginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'SIGN IN WITH GOOGLE'**
  String get loginGoogleButton;

  /// No description provided for @errorCommunication.
  ///
  /// In en, this message translates to:
  /// **'Error communicating with the server.'**
  String get errorCommunication;

  /// No description provided for @errorNotLoggedIn.
  ///
  /// In en, this message translates to:
  /// **'User not logged in.'**
  String get errorNotLoggedIn;

  /// No description provided for @errorLoadPrefs.
  ///
  /// In en, this message translates to:
  /// **'Error loading preferences.'**
  String get errorLoadPrefs;

  /// No description provided for @errorGpsDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission denied or GPS disabled. Check your settings.'**
  String get errorGpsDenied;

  /// No description provided for @errorConnectionSettings.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Changes reverted.'**
  String get errorConnectionSettings;

  /// No description provided for @errorDeleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete data.'**
  String get errorDeleteAccount;

  /// No description provided for @errorDeleteAccountAuth.
  ///
  /// In en, this message translates to:
  /// **'Account not fully deleted. App data removed, but auth deletion failed. Logging out for security.'**
  String get errorDeleteAccountAuth;

  /// No description provided for @errorSyncProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync profile.'**
  String get errorSyncProfile;

  /// No description provided for @errorSaveProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile.'**
  String get errorSaveProfile;

  /// No description provided for @errorLoadLeaderboard.
  ///
  /// In en, this message translates to:
  /// **'Failed to load leaderboard.'**
  String get errorLoadLeaderboard;

  /// No description provided for @settingsTourTitle.
  ///
  /// In en, this message translates to:
  /// **'WWII Interactive Tour'**
  String get settingsTourTitle;

  /// No description provided for @settingsTourSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage privacy, notifications, and language in one place.'**
  String get settingsTourSubtitle;

  /// No description provided for @settingsCredits.
  ///
  /// In en, this message translates to:
  /// **'Credits'**
  String get settingsCredits;

  /// No description provided for @settingsCreditsTitle.
  ///
  /// In en, this message translates to:
  /// **'Credits & Acknowledgements'**
  String get settingsCreditsTitle;

  /// No description provided for @settingsCreditsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Discover the team behind Cesena Remembers'**
  String get settingsCreditsSubtitle;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsLogout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get settingsLogout;

  /// No description provided for @settingsLogoutInProgress.
  ///
  /// In en, this message translates to:
  /// **'Logging out...'**
  String get settingsLogoutInProgress;

  /// No description provided for @settingsLogoutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out of current account'**
  String get settingsLogoutSubtitle;

  /// No description provided for @settingsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get settingsDelete;

  /// No description provided for @settingsDeleteInProgress.
  ///
  /// In en, this message translates to:
  /// **'Deleting...'**
  String get settingsDeleteInProgress;

  /// No description provided for @settingsDeleteSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Remove profile and associated data'**
  String get settingsDeleteSubtitle;

  /// No description provided for @settingsAppPrefs.
  ///
  /// In en, this message translates to:
  /// **'App Preferences'**
  String get settingsAppPrefs;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingsNotifications;

  /// No description provided for @settingsNotifSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive alerts for stops and rewards'**
  String get settingsNotifSubtitle;

  /// No description provided for @settingsDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get settingsDarkMode;

  /// No description provided for @settingsDarkModeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Dark theme for the entire app'**
  String get settingsDarkModeSubtitle;

  /// No description provided for @settingsPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get settingsPrivacy;

  /// No description provided for @settingsGps.
  ///
  /// In en, this message translates to:
  /// **'GPS Location'**
  String get settingsGps;

  /// No description provided for @settingsGpsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Required to explore the map'**
  String get settingsGpsSubtitle;

  /// No description provided for @settingsPrivacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingsPrivacyPolicy;

  /// No description provided for @settingsPrivacySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Read how your data is handled'**
  String get settingsPrivacySubtitle;

  /// No description provided for @settingsGeneral.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get settingsGeneral;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsInfo.
  ///
  /// In en, this message translates to:
  /// **'Info'**
  String get settingsInfo;

  /// No description provided for @settingsVersion.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get settingsVersion;

  /// No description provided for @settingsTerms.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get settingsTerms;

  /// No description provided for @settingsTermsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Usage rules and responsibilities'**
  String get settingsTermsSubtitle;

  /// No description provided for @settingsContacts.
  ///
  /// In en, this message translates to:
  /// **'Contacts'**
  String get settingsContacts;

  /// No description provided for @settingsClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get settingsClose;

  /// No description provided for @settingsPerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get settingsPerfect;

  /// No description provided for @settingsDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete account?'**
  String get settingsDeleteConfirmTitle;

  /// No description provided for @settingsDeleteConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'This operation permanently removes your account, progress, and associated data.'**
  String get settingsDeleteConfirmBody;

  /// No description provided for @settingsCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get settingsCancel;

  /// No description provided for @settingsDeleteConfirmBtn.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get settingsDeleteConfirmBtn;

  /// No description provided for @settingsDeleteSuccess.
  ///
  /// In en, this message translates to:
  /// **'Account permanently deleted.'**
  String get settingsDeleteSuccess;

  /// No description provided for @settingsDeleteError.
  ///
  /// In en, this message translates to:
  /// **'Unable to complete now. Check the error message.'**
  String get settingsDeleteError;

  /// No description provided for @achievement_first_visit_title.
  ///
  /// In en, this message translates to:
  /// **'First Step'**
  String get achievement_first_visit_title;

  /// No description provided for @achievement_first_visit_desc.
  ///
  /// In en, this message translates to:
  /// **'Visit your first historical site'**
  String get achievement_first_visit_desc;

  /// No description provided for @achievement_first_quiz_title.
  ///
  /// In en, this message translates to:
  /// **'Student'**
  String get achievement_first_quiz_title;

  /// No description provided for @achievement_first_quiz_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete your first quiz'**
  String get achievement_first_quiz_desc;

  /// No description provided for @achievement_first_tour_title.
  ///
  /// In en, this message translates to:
  /// **'Pioneer'**
  String get achievement_first_tour_title;

  /// No description provided for @achievement_first_tour_desc.
  ///
  /// In en, this message translates to:
  /// **'Finish your first complete tour'**
  String get achievement_first_tour_desc;

  /// No description provided for @achievement_quiz_15_title.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get achievement_quiz_15_title;

  /// No description provided for @achievement_quiz_15_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete 15 quizzes'**
  String get achievement_quiz_15_desc;

  /// No description provided for @achievement_perfect_tour_title.
  ///
  /// In en, this message translates to:
  /// **'Flawless'**
  String get achievement_perfect_tour_title;

  /// No description provided for @achievement_perfect_tour_desc.
  ///
  /// In en, this message translates to:
  /// **'Answer all questions correctly in a tour'**
  String get achievement_perfect_tour_desc;

  /// No description provided for @achievement_xp_500_title.
  ///
  /// In en, this message translates to:
  /// **'Collector'**
  String get achievement_xp_500_title;

  /// No description provided for @achievement_xp_500_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach 500 total XP'**
  String get achievement_xp_500_desc;

  /// No description provided for @achievement_tour_under_1h_title.
  ///
  /// In en, this message translates to:
  /// **'On the March'**
  String get achievement_tour_under_1h_title;

  /// No description provided for @achievement_tour_under_1h_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a tour in under 1 hour'**
  String get achievement_tour_under_1h_desc;

  /// No description provided for @achievement_tour_under_30m_title.
  ///
  /// In en, this message translates to:
  /// **'Lightning'**
  String get achievement_tour_under_30m_title;

  /// No description provided for @achievement_tour_under_30m_desc.
  ///
  /// In en, this message translates to:
  /// **'Complete a tour in under 30 minutes'**
  String get achievement_tour_under_30m_desc;

  /// No description provided for @achievement_friend_1_title.
  ///
  /// In en, this message translates to:
  /// **'Citizen'**
  String get achievement_friend_1_title;

  /// No description provided for @achievement_friend_1_desc.
  ///
  /// In en, this message translates to:
  /// **'Add your first friend'**
  String get achievement_friend_1_desc;

  /// No description provided for @achievement_friend_5_title.
  ///
  /// In en, this message translates to:
  /// **'Historical Circle'**
  String get achievement_friend_5_title;

  /// No description provided for @achievement_friend_5_desc.
  ///
  /// In en, this message translates to:
  /// **'Reach 5 friends'**
  String get achievement_friend_5_desc;

  /// No description provided for @poi_santa_cristina_name.
  ///
  /// In en, this message translates to:
  /// **'Church of Santa Cristina'**
  String get poi_santa_cristina_name;

  /// No description provided for @poi_santa_cristina_desc.
  ///
  /// In en, this message translates to:
  /// **'Historic church with a hemispherical dome and bell tower, set within Cesena\'s residential urban fabric. It represents the balance between religious architecture and urban development. During World War II, it likely served as a visual landmark during bombings, useful for population orientation. The surrounding area was partially affected or modified in the post-war period, with redefined urban spaces.'**
  String get poi_santa_cristina_desc;

  /// No description provided for @poi_rocca_name.
  ///
  /// In en, this message translates to:
  /// **'Malatestiana Fortress'**
  String get poi_rocca_name;

  /// No description provided for @poi_rocca_desc.
  ///
  /// In en, this message translates to:
  /// **'A medieval fortress dominating the city, featuring crenellated walls and towers; a central defensive and symbolic element of Cesena. Built by the Malatesta in 1380, it houses the Malatestiana Library, a UNESCO World Heritage site since 2005. During World War II, it was repurposed as a natural shelter thanks to its massive structure: the hill hosted tunnels and air-raid shelters to protect the civilian population during bombings.'**
  String get poi_rocca_desc;

  /// No description provided for @poi_san_rocco_name.
  ///
  /// In en, this message translates to:
  /// **'Church of San Rocco'**
  String get poi_san_rocco_name;

  /// No description provided for @poi_san_rocco_desc.
  ///
  /// In en, this message translates to:
  /// **'A church located in a working-class neighborhood of Cesena, surrounded by simple buildings and historically unpaved roads. Dedicated to Saint Roch, the patron saint of plague victims, it has been a spiritual reference point for the working classes for centuries. During WWII, the neighborhood, inhabited by working families, was directly exposed to the hardships of the bombings, and the church served as a possible gathering point and transit area towards shelters during air raids.'**
  String get poi_san_rocco_desc;

  /// No description provided for @poi_abbazia_monte_name.
  ///
  /// In en, this message translates to:
  /// **'Abbey of Santa Maria del Monte'**
  String get poi_abbazia_monte_name;

  /// No description provided for @poi_abbazia_monte_desc.
  ///
  /// In en, this message translates to:
  /// **'A monastic complex on a hill overlooking the city, surrounded by cultivated countryside; a strong religious and territorial symbol of Cesena for over a thousand years. Its elevated position made it strategically significant during World War II: it was used as an observation point or visual reference for military operations. The hilly area offered shelter and isolation from the urban center\'s bombings.'**
  String get poi_abbazia_monte_desc;

  /// No description provided for @poi_osservanza_name.
  ///
  /// In en, this message translates to:
  /// **'Church and Convent of the Osservanza'**
  String get poi_osservanza_name;

  /// No description provided for @poi_osservanza_desc.
  ///
  /// In en, this message translates to:
  /// **'A Franciscan religious complex nestled in the Cesena countryside, historically separated from the urban center. The church preserves valuable artworks from the 15th and 16th centuries. During World War II, its isolation from the city made it less exposed to direct attacks, becoming a possible place of refuge and spiritual assistance for evacuees and the rural population fleeing the bombings.'**
  String get poi_osservanza_desc;

  /// No description provided for @poi_palazzo_ridotto_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo del Ridotto'**
  String get poi_palazzo_ridotto_name;

  /// No description provided for @poi_palazzo_ridotto_desc.
  ///
  /// In en, this message translates to:
  /// **'A historic building with a civic tower, a symbol of the city center and public life in Cesena. It overlooks Piazza del Popolo, the heart of the city since the Middle Ages, also dominated by the Masini fountain. During World War II, it housed an air-raid siren essential for signaling incoming bombings, acting as a vital node in the alarm and coordination system for the civilian population.'**
  String get poi_palazzo_ridotto_desc;

  /// No description provided for @poi_stazione_name.
  ///
  /// In en, this message translates to:
  /// **'Cesena Railway Station'**
  String get poi_stazione_name;

  /// No description provided for @poi_stazione_desc.
  ///
  /// In en, this message translates to:
  /// **'An important railway hub for freight and passenger transport between the 19th and 20th centuries, on the Bologna–Rimini Adriatic line. During World War II, it was one of the primary strategic targets of Allied bombings, as disrupting its supplies was essential to halting the German advance. It suffered severe destruction, becoming one of the most heavily bombed areas in the city.'**
  String get poi_stazione_desc;

  /// No description provided for @poi_arrigoni_name.
  ///
  /// In en, this message translates to:
  /// **'Arrigoni Factory'**
  String get poi_arrigoni_name;

  /// No description provided for @poi_arrigoni_desc.
  ///
  /// In en, this message translates to:
  /// **'A large canning industry founded in 1880, the heart of the local economy and working-class labor in Cesena for over a century. Specializing in canned fish, it was among the most important companies in Romagna. During World War II, the production facility was strategically relevant for food logistics and was the site of strikes and strong social tensions, especially in the 1943–1944 biennium.'**
  String get poi_arrigoni_desc;

  /// No description provided for @poi_fantaguzzi_name.
  ///
  /// In en, this message translates to:
  /// **'Palazzo Fantaguzzi'**
  String get poi_fantaguzzi_name;

  /// No description provided for @poi_fantaguzzi_desc.
  ///
  /// In en, this message translates to:
  /// **'A historic building in the heart of Cesena, the local headquarters of the National Fascist Party during Mussolini\'s regime. It represents one of the symbols of the Fascist era in the city. During World War II, it was the center of fascist political and administrative power at the city level, likely a place of repression, population control, and the organization of wartime activities in the territory.'**
  String get poi_fantaguzzi_desc;

  /// No description provided for @poi_rifugi_antiaerei_name.
  ///
  /// In en, this message translates to:
  /// **'Air-Raid Shelters of the Fortress'**
  String get poi_rifugi_antiaerei_name;

  /// No description provided for @poi_rifugi_antiaerei_desc.
  ///
  /// In en, this message translates to:
  /// **'A system of underground tunnels excavated beneath and around the Malatestiana Fortress to protect the civilian population from aerial bombings. During World War II, they were fundamental for the survival of hundreds of citizens: the shelters accommodated entire families, becoming true spaces of temporary underground life during the Allied attacks between 1943 and 1944.'**
  String get poi_rifugi_antiaerei_desc;

  /// No description provided for @setupUsernameInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid username (use {min}-{max} characters: a-z, 0-9, _ or .).'**
  String setupUsernameInvalid(int min, int max);

  /// No description provided for @setupUsernameOffensive.
  ///
  /// In en, this message translates to:
  /// **'Username contains prohibited terms. Please choose another.'**
  String get setupUsernameOffensive;

  /// No description provided for @setupUsernameTaken.
  ///
  /// In en, this message translates to:
  /// **'Username is already taken. Please choose another.'**
  String get setupUsernameTaken;

  /// No description provided for @setupFirestoreError.
  ///
  /// In en, this message translates to:
  /// **'Invalid Firestore configuration: read/write permissions required on usernames/{username}.'**
  String setupFirestoreError(Object username);

  /// No description provided for @setupPermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Insufficient Firestore permissions to complete the profile. Check project rules.'**
  String get setupPermissionDenied;

  /// No description provided for @setupGenericError.
  ///
  /// In en, this message translates to:
  /// **'Unable to save profile. Please try again in a few seconds.'**
  String get setupGenericError;

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'Create your profile'**
  String get setupTitle;

  /// No description provided for @setupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a unique username (cannot be changed), display name, and avatar.'**
  String get setupSubtitle;

  /// No description provided for @setupNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get setupNameLabel;

  /// No description provided for @setupUsernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get setupUsernameLabel;

  /// No description provided for @setupUsernameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., cesena_explorer'**
  String get setupUsernameHint;

  /// No description provided for @setupAvatarLabel.
  ///
  /// In en, this message translates to:
  /// **'Choose avatar'**
  String get setupAvatarLabel;

  /// No description provided for @setupSubmitButton.
  ///
  /// In en, this message translates to:
  /// **'Confirm Profile'**
  String get setupSubmitButton;

  /// No description provided for @creditRoleDiplo.
  ///
  /// In en, this message translates to:
  /// **'German Diplomatic Missions in Italy'**
  String get creditRoleDiplo;

  /// No description provided for @creditRoleDiploDesc.
  ///
  /// In en, this message translates to:
  /// **'Developed with their valuable contribution'**
  String get creditRoleDiploDesc;

  /// No description provided for @sectionSupport.
  ///
  /// In en, this message translates to:
  /// **'Collaborators and Support'**
  String get sectionSupport;

  /// No description provided for @quiz_fallback_name.
  ///
  /// In en, this message translates to:
  /// **'Standard difficulty (local seed)'**
  String get quiz_fallback_name;

  /// No description provided for @quiz_fallback_desc.
  ///
  /// In en, this message translates to:
  /// **'Due to a server error, questions are not personalized and use a specific local difficulty.'**
  String get quiz_fallback_desc;

  /// No description provided for @quiz_santa_cristina_q1.
  ///
  /// In en, this message translates to:
  /// **'Which architectural element characterizes the church?'**
  String get quiz_santa_cristina_q1;

  /// No description provided for @quiz_santa_cristina_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'A Gothic bell tower'**
  String get quiz_santa_cristina_q1_o1;

  /// No description provided for @quiz_santa_cristina_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'A hemispherical dome'**
  String get quiz_santa_cristina_q1_o2;

  /// No description provided for @quiz_santa_cristina_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'A Renaissance rose window'**
  String get quiz_santa_cristina_q1_o3;

  /// No description provided for @quiz_santa_cristina_q2.
  ///
  /// In en, this message translates to:
  /// **'What role did the church play during World War II?'**
  String get quiz_santa_cristina_q2;

  /// No description provided for @quiz_santa_cristina_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'It was used as a field hospital'**
  String get quiz_santa_cristina_q2_o1;

  /// No description provided for @quiz_santa_cristina_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'It was a visual landmark for orientation during bombings'**
  String get quiz_santa_cristina_q2_o2;

  /// No description provided for @quiz_santa_cristina_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'It was the headquarters of the German military command'**
  String get quiz_santa_cristina_q2_o3;

  /// No description provided for @quiz_rocca_q1.
  ///
  /// In en, this message translates to:
  /// **'Who had the Fortress built?'**
  String get quiz_rocca_q1;

  /// No description provided for @quiz_rocca_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'The Visconti'**
  String get quiz_rocca_q1_o1;

  /// No description provided for @quiz_rocca_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'The Malatesta'**
  String get quiz_rocca_q1_o2;

  /// No description provided for @quiz_rocca_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Federico da Montefeltro'**
  String get quiz_rocca_q1_o3;

  /// No description provided for @quiz_rocca_q2.
  ///
  /// In en, this message translates to:
  /// **'In what year did the Malatestiana Library become a UNESCO World Heritage site?'**
  String get quiz_rocca_q2;

  /// No description provided for @quiz_rocca_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'1995'**
  String get quiz_rocca_q2_o1;

  /// No description provided for @quiz_rocca_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'2005'**
  String get quiz_rocca_q2_o2;

  /// No description provided for @quiz_rocca_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'2015'**
  String get quiz_rocca_q2_o3;

  /// No description provided for @quiz_rocca_q3.
  ///
  /// In en, this message translates to:
  /// **'How was the Fortress used during World War II?'**
  String get quiz_rocca_q3;

  /// No description provided for @quiz_rocca_q3_o1.
  ///
  /// In en, this message translates to:
  /// **'As a prison for partisans'**
  String get quiz_rocca_q3_o1;

  /// No description provided for @quiz_rocca_q3_o2.
  ///
  /// In en, this message translates to:
  /// **'As an air-raid shelter for civilians'**
  String get quiz_rocca_q3_o2;

  /// No description provided for @quiz_rocca_q3_o3.
  ///
  /// In en, this message translates to:
  /// **'As an ammunition depot'**
  String get quiz_rocca_q3_o3;

  /// No description provided for @quiz_san_rocco_q1.
  ///
  /// In en, this message translates to:
  /// **'Which saint is the church dedicated to?'**
  String get quiz_san_rocco_q1;

  /// No description provided for @quiz_san_rocco_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Saint Francis'**
  String get quiz_san_rocco_q1_o1;

  /// No description provided for @quiz_san_rocco_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Saint Roch'**
  String get quiz_san_rocco_q1_o2;

  /// No description provided for @quiz_san_rocco_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Saint Anthony'**
  String get quiz_san_rocco_q1_o3;

  /// No description provided for @quiz_san_rocco_q2.
  ///
  /// In en, this message translates to:
  /// **'In what kind of neighborhood is the church located?'**
  String get quiz_san_rocco_q2;

  /// No description provided for @quiz_san_rocco_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Noble neighborhood'**
  String get quiz_san_rocco_q2_o1;

  /// No description provided for @quiz_san_rocco_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Working-class neighborhood'**
  String get quiz_san_rocco_q2_o2;

  /// No description provided for @quiz_san_rocco_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'University neighborhood'**
  String get quiz_san_rocco_q2_o3;

  /// No description provided for @quiz_abbazia_monte_q1.
  ///
  /// In en, this message translates to:
  /// **'Where is the abbey located?'**
  String get quiz_abbazia_monte_q1;

  /// No description provided for @quiz_abbazia_monte_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'On the plain, near the river'**
  String get quiz_abbazia_monte_q1_o1;

  /// No description provided for @quiz_abbazia_monte_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'On a hill overlooking the city'**
  String get quiz_abbazia_monte_q1_o2;

  /// No description provided for @quiz_abbazia_monte_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'In the historical center'**
  String get quiz_abbazia_monte_q1_o3;

  /// No description provided for @quiz_abbazia_monte_q2.
  ///
  /// In en, this message translates to:
  /// **'What advantage did the abbey offer during the war?'**
  String get quiz_abbazia_monte_q2;

  /// No description provided for @quiz_abbazia_monte_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'It housed a military food depot'**
  String get quiz_abbazia_monte_q2_o1;

  /// No description provided for @quiz_abbazia_monte_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Its elevated position made it useful as an observation point'**
  String get quiz_abbazia_monte_q2_o2;

  /// No description provided for @quiz_abbazia_monte_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'It was the seat of the provisional government'**
  String get quiz_abbazia_monte_q2_o3;

  /// No description provided for @quiz_osservanza_q1.
  ///
  /// In en, this message translates to:
  /// **'To which religious order does the convent belong?'**
  String get quiz_osservanza_q1;

  /// No description provided for @quiz_osservanza_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Dominicans'**
  String get quiz_osservanza_q1_o1;

  /// No description provided for @quiz_osservanza_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Franciscans'**
  String get quiz_osservanza_q1_o2;

  /// No description provided for @quiz_osservanza_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Benedictines'**
  String get quiz_osservanza_q1_o3;

  /// No description provided for @quiz_osservanza_q2.
  ///
  /// In en, this message translates to:
  /// **'Why was the convent less exposed to bombings?'**
  String get quiz_osservanza_q2;

  /// No description provided for @quiz_osservanza_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'It was protected by underground bunkers'**
  String get quiz_osservanza_q2_o1;

  /// No description provided for @quiz_osservanza_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'It was isolated from the urban center'**
  String get quiz_osservanza_q2_o2;

  /// No description provided for @quiz_osservanza_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'It was garrisoned by the Allied army'**
  String get quiz_osservanza_q2_o3;

  /// No description provided for @quiz_palazzo_ridotto_q1.
  ///
  /// In en, this message translates to:
  /// **'What is the name of the fountain in Piazza del Popolo?'**
  String get quiz_palazzo_ridotto_q1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Fountain of Neptune'**
  String get quiz_palazzo_ridotto_q1_o1;

  /// No description provided for @quiz_palazzo_ridotto_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Fountain of Masini'**
  String get quiz_palazzo_ridotto_q1_o2;

  /// No description provided for @quiz_palazzo_ridotto_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Fountain of the Dolphins'**
  String get quiz_palazzo_ridotto_q1_o3;

  /// No description provided for @quiz_palazzo_ridotto_q2.
  ///
  /// In en, this message translates to:
  /// **'What military device was installed in the palace?'**
  String get quiz_palazzo_ridotto_q2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'An anti-aircraft machine gun'**
  String get quiz_palazzo_ridotto_q2_o1;

  /// No description provided for @quiz_palazzo_ridotto_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'An air-raid siren'**
  String get quiz_palazzo_ridotto_q2_o2;

  /// No description provided for @quiz_palazzo_ridotto_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'A spotting radar'**
  String get quiz_palazzo_ridotto_q2_o3;

  /// No description provided for @quiz_stazione_q1.
  ///
  /// In en, this message translates to:
  /// **'Why was the station a target of Allied bombings?'**
  String get quiz_stazione_q1;

  /// No description provided for @quiz_stazione_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'It housed the German headquarters'**
  String get quiz_stazione_q1_o1;

  /// No description provided for @quiz_stazione_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'It was a strategic node for military supplies'**
  String get quiz_stazione_q1_o2;

  /// No description provided for @quiz_stazione_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'It was the only hospital in the city'**
  String get quiz_stazione_q1_o3;

  /// No description provided for @quiz_stazione_q2.
  ///
  /// In en, this message translates to:
  /// **'On which railway line is the Cesena station located?'**
  String get quiz_stazione_q2;

  /// No description provided for @quiz_stazione_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Bologna–Florence'**
  String get quiz_stazione_q2_o1;

  /// No description provided for @quiz_stazione_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Bologna–Rimini (Adriatic line)'**
  String get quiz_stazione_q2_o2;

  /// No description provided for @quiz_stazione_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Rimini–Rome'**
  String get quiz_stazione_q2_o3;

  /// No description provided for @quiz_arrigoni_q1.
  ///
  /// In en, this message translates to:
  /// **'In which sector did the Arrigoni Factory operate?'**
  String get quiz_arrigoni_q1;

  /// No description provided for @quiz_arrigoni_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Textile industry'**
  String get quiz_arrigoni_q1_o1;

  /// No description provided for @quiz_arrigoni_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Canned fish and food'**
  String get quiz_arrigoni_q1_o2;

  /// No description provided for @quiz_arrigoni_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Heavy mechanics'**
  String get quiz_arrigoni_q1_o3;

  /// No description provided for @quiz_arrigoni_q2.
  ///
  /// In en, this message translates to:
  /// **'What happened in the factory in 1943–1944?'**
  String get quiz_arrigoni_q2;

  /// No description provided for @quiz_arrigoni_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'It was converted into a military hospital'**
  String get quiz_arrigoni_q2_o1;

  /// No description provided for @quiz_arrigoni_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'It was the scene of strikes and social tensions'**
  String get quiz_arrigoni_q2_o2;

  /// No description provided for @quiz_arrigoni_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'It was used as a prison by the Germans'**
  String get quiz_arrigoni_q2_o3;

  /// No description provided for @quiz_fantaguzzi_q1.
  ///
  /// In en, this message translates to:
  /// **'Which organization was headquartered in Palazzo Fantaguzzi during the regime?'**
  String get quiz_fantaguzzi_q1;

  /// No description provided for @quiz_fantaguzzi_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'The Municipality of Cesena'**
  String get quiz_fantaguzzi_q1_o1;

  /// No description provided for @quiz_fantaguzzi_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'The National Fascist Party'**
  String get quiz_fantaguzzi_q1_o2;

  /// No description provided for @quiz_fantaguzzi_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'The Red Cross'**
  String get quiz_fantaguzzi_q1_o3;

  /// No description provided for @quiz_fantaguzzi_q2.
  ///
  /// In en, this message translates to:
  /// **'What role did the palace play during the war?'**
  String get quiz_fantaguzzi_q2;

  /// No description provided for @quiz_fantaguzzi_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'Coordination center for partisan resistance'**
  String get quiz_fantaguzzi_q2_o1;

  /// No description provided for @quiz_fantaguzzi_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'Center of fascist political and administrative power'**
  String get quiz_fantaguzzi_q2_o2;

  /// No description provided for @quiz_fantaguzzi_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'Headquarters of the Allied military tribunal'**
  String get quiz_fantaguzzi_q2_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q1.
  ///
  /// In en, this message translates to:
  /// **'Where were the air-raid shelters excavated?'**
  String get quiz_rifugi_antiaerei_q1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o1.
  ///
  /// In en, this message translates to:
  /// **'Under the Palazzo del Ridotto'**
  String get quiz_rifugi_antiaerei_q1_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o2.
  ///
  /// In en, this message translates to:
  /// **'Under and around the Malatestiana Fortress'**
  String get quiz_rifugi_antiaerei_q1_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q1_o3.
  ///
  /// In en, this message translates to:
  /// **'Under the railway station'**
  String get quiz_rifugi_antiaerei_q1_o3;

  /// No description provided for @quiz_rifugi_antiaerei_q2.
  ///
  /// In en, this message translates to:
  /// **'In which years were the shelters mainly used?'**
  String get quiz_rifugi_antiaerei_q2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o1.
  ///
  /// In en, this message translates to:
  /// **'1940–1941'**
  String get quiz_rifugi_antiaerei_q2_o1;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o2.
  ///
  /// In en, this message translates to:
  /// **'1943–1944'**
  String get quiz_rifugi_antiaerei_q2_o2;

  /// No description provided for @quiz_rifugi_antiaerei_q2_o3.
  ///
  /// In en, this message translates to:
  /// **'1945–1946'**
  String get quiz_rifugi_antiaerei_q2_o3;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'it': return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
