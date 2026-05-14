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
  /// **'Logout failed: {error}'**
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
  /// **'Error during action.'**
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
