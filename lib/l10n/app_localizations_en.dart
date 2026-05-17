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
  String get buttonRetry => 'Retry';

  @override
  String get navMap => 'Map';

  @override
  String get navProfile => 'Profile';

  @override
  String get navSettings => 'Settings';

  @override
  String get navCommunity => 'Community';

  @override
  String errorLoadPreferences(String error) {
    return 'Error loading preferences: $error';
  }

  @override
  String get errorConnection => 'Connection error. Change cancelled.';

  @override
  String errorLogout(String error) {
    return 'Logout failed.';
  }

  @override
  String get errorDeleteAccountPartial => 'Account not fully deleted. App data was removed, but auth deletion failed. You will be signed out for safety.';

  @override
  String errorDeleteData(String error) {
    return 'Unable to delete data: $error';
  }

  @override
  String get errorLoadProfile => 'Failed to load profile.';

  @override
  String get errorOperationFailed => 'Operation failed. State restored.';

  @override
  String get tourStopped => 'Tour stopped.';

  @override
  String get errorSaveScore => 'Error saving score. Try again in a moment.';

  @override
  String get errorLoadPoi => 'Error loading points of interest.';

  @override
  String get errorSearch => 'Error during search.';

  @override
  String get errorAction => 'Error performing action.';

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
  String get profileTitle => 'My Profile';

  @override
  String get sectionStatistics => 'Statistics';

  @override
  String get sectionAchievements => 'Achievements';

  @override
  String get statTotalXp => 'Total XP';

  @override
  String get statBestTour => 'Best tour (XP)';

  @override
  String get statVisitedSites => 'Sites Visited';

  @override
  String get statBestTime => 'Best time';

  @override
  String get statAchievements => 'Achievements';

  @override
  String get profileFriends => 'Friends';

  @override
  String get profilePoints => 'Points';

  @override
  String get profileNoRequests => 'No requests at the moment.';

  @override
  String get profileYourFriends => 'Your Friends';

  @override
  String get profileFriendRequests => 'Friend Requests';

  @override
  String profileNameTooShort(int min, int max) {
    return 'Name must be $min-$max characters.';
  }

  @override
  String get profileNameOffensive => 'The name contains forbidden terms.\nPlease choose a different one.';

  @override
  String get avatarPickerTitle => 'Choose your Avatar';

  @override
  String get avatarPickerSubtitle => 'Customize your profile';

  @override
  String get poiTabInfo => 'Information';

  @override
  String get poiTabQuiz => 'Quiz';

  @override
  String get poiSectionHistory => 'History';

  @override
  String get poiStartQuiz => 'Take the quiz for this stop →';

  @override
  String get poiNoQuiz => 'No quiz available for this stop.';

  @override
  String get quizNextQuestion => 'Next question →';

  @override
  String get quizFinish => 'Finish quiz →';

  @override
  String get quizNextStop => 'Next stop →';

  @override
  String get quizNotice => 'Quiz notice';

  @override
  String quizCorrectAnswers(int score, int total) {
    return '$score / $total correct answers';
  }

  @override
  String quizTime(String time) {
    return 'Time: $time';
  }

  @override
  String quizQuestion(int current, int total) {
    return 'Question $current of $total';
  }

  @override
  String get tourStartButton => 'Start tour';

  @override
  String get tourArrivedButton => 'I\'m here';

  @override
  String get tourStopCardArrived => 'You arrived! Tap to open';

  @override
  String tourStopCardDistance(String distance, int index, int total) {
    return '$distance · stop $index/$total';
  }

  @override
  String get tourPlanTitle => 'Stop order';

  @override
  String get tourPlanSubtitle => 'Drag the handle to reorder the route.';

  @override
  String get tourPlanFirstStop => 'First stop of the tour';

  @override
  String tourPlanDistanceFromPrev(String distance) {
    return '$distance from previous';
  }

  @override
  String get tourPlanCurrentLabel => 'Current';

  @override
  String get locationBannerMissingPermission => 'Missing permissions';

  @override
  String get locationBannerGpsOff => 'GPS Disabled';

  @override
  String get locationBannerEnableLocation => 'Enable location to explore the map in real time.';

  @override
  String get locationBannerReEnableLocation => 'Re-enable location in settings to show your position on the map.';

  @override
  String get locationBannerResolve => 'Fix';

  @override
  String get socialSearchHint => 'Search user...';

  @override
  String get socialLeaderboardEmpty => 'No users in the leaderboard right now.';

  @override
  String get socialLeaderboard => 'Global Leaderboard';

  @override
  String get socialNoUserFound => 'No user found.';

  @override
  String get socialTypeMoreChars => 'Type at least 2 characters to search.';

  @override
  String get socialYou => 'You';

  @override
  String get socialDefaultUsername => 'user';

  @override
  String socialFriendsOf(String name) {
    return 'Friends of $name';
  }

  @override
  String get socialMustBeFriend => 'You must be friends to view their friend list.';

  @override
  String get socialRequestSent => 'Request sent';

  @override
  String get socialAccept => 'Accept';

  @override
  String get socialReject => 'Decline';

  @override
  String get socialAddFriend => 'Add as friend';

  @override
  String get publicStatDetailed => 'Detailed Statistics';

  @override
  String get publicStatAchievements => 'Achievements';

  @override
  String get publicStatBestScore => 'Best Score';

  @override
  String get publicStatSites => 'Sites Visited';

  @override
  String get publicStatQuiz => 'Quizzes Passed';

  @override
  String get publicStatBestTime => 'Best Time';

  @override
  String get publicStatCorrectAnswers => 'Correct Answers';

  @override
  String get publicStatFriends => 'Friends';

  @override
  String get publicStatPoints => 'Points';

  @override
  String get publicStatLevel => 'Level';

  @override
  String get errorLoginFailed => 'Login failed. Check your connection and try again.';

  @override
  String get errorOffline => 'You are offline. Check your Internet connection and try again.';

  @override
  String get errorLoginGeneric => 'Login failed. Please try again in a few seconds.';

  @override
  String get loginGoogleButton => 'SIGN IN WITH GOOGLE';

  @override
  String get errorCommunication => 'Error communicating with the server.';

  @override
  String get errorNotLoggedIn => 'User not logged in.';

  @override
  String get errorLoadPrefs => 'Error loading preferences.';

  @override
  String get errorGpsDenied => 'Permission denied or GPS disabled. Check your settings.';

  @override
  String get errorConnectionSettings => 'Connection error. Changes reverted.';

  @override
  String get errorDeleteAccount => 'Failed to delete data.';

  @override
  String get errorDeleteAccountAuth => 'Account not fully deleted. App data removed, but auth deletion failed. Logging out for security.';

  @override
  String get errorSyncProfile => 'Failed to sync profile.';

  @override
  String get errorSaveProfile => 'Failed to save profile.';

  @override
  String get errorLoadLeaderboard => 'Failed to load leaderboard.';

  @override
  String get settingsTourTitle => 'WWII Interactive Tour';

  @override
  String get settingsTourSubtitle => 'Manage privacy, notifications, and language in one place.';

  @override
  String get settingsCredits => 'Credits';

  @override
  String get settingsCreditsTitle => 'Credits & Acknowledgements';

  @override
  String get settingsCreditsSubtitle => 'Discover the team behind Cesena Remembers';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsLogout => 'Logout';

  @override
  String get settingsLogoutInProgress => 'Logging out...';

  @override
  String get settingsLogoutSubtitle => 'Sign out of current account';

  @override
  String get settingsDelete => 'Delete account';

  @override
  String get settingsDeleteInProgress => 'Deleting...';

  @override
  String get settingsDeleteSubtitle => 'Remove profile and associated data';

  @override
  String get settingsAppPrefs => 'App Preferences';

  @override
  String get settingsNotifications => 'Notifications';

  @override
  String get settingsNotifSubtitle => 'Receive alerts for stops and rewards';

  @override
  String get settingsDarkMode => 'Dark Mode';

  @override
  String get settingsDarkModeSubtitle => 'Dark theme for the entire app';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsGps => 'GPS Location';

  @override
  String get settingsGpsSubtitle => 'Required to explore the map';

  @override
  String get settingsPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingsPrivacySubtitle => 'Read how your data is handled';

  @override
  String get settingsGeneral => 'General';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsInfo => 'Info';

  @override
  String get settingsVersion => 'Version';

  @override
  String get settingsTerms => 'Terms of Service';

  @override
  String get settingsTermsSubtitle => 'Usage rules and responsibilities';

  @override
  String get settingsContacts => 'Contacts';

  @override
  String get settingsClose => 'Close';

  @override
  String get settingsPerfect => 'Perfect';

  @override
  String get settingsDeleteConfirmTitle => 'Delete account?';

  @override
  String get settingsDeleteConfirmBody => 'This operation permanently removes your account, progress, and associated data.';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsDeleteConfirmBtn => 'Delete';

  @override
  String get settingsDeleteSuccess => 'Account permanently deleted.';

  @override
  String get settingsDeleteError => 'Unable to complete now. Check the error message.';

  @override
  String get achievement_first_visit_title => 'First Step';

  @override
  String get achievement_first_visit_desc => 'Visit your first historical site';

  @override
  String get achievement_first_quiz_title => 'Student';

  @override
  String get achievement_first_quiz_desc => 'Complete your first quiz';

  @override
  String get achievement_first_tour_title => 'Pioneer';

  @override
  String get achievement_first_tour_desc => 'Finish your first complete tour';

  @override
  String get achievement_quiz_15_title => 'Veteran';

  @override
  String get achievement_quiz_15_desc => 'Complete 15 quizzes';

  @override
  String get achievement_perfect_tour_title => 'Flawless';

  @override
  String get achievement_perfect_tour_desc => 'Answer all questions correctly in a tour';

  @override
  String get achievement_xp_500_title => 'Collector';

  @override
  String get achievement_xp_500_desc => 'Reach 500 total XP';

  @override
  String get achievement_tour_under_1h_title => 'On the March';

  @override
  String get achievement_tour_under_1h_desc => 'Complete a tour in under 1 hour';

  @override
  String get achievement_tour_under_30m_title => 'Lightning';

  @override
  String get achievement_tour_under_30m_desc => 'Complete a tour in under 30 minutes';

  @override
  String get achievement_friend_1_title => 'Citizen';

  @override
  String get achievement_friend_1_desc => 'Add your first friend';

  @override
  String get achievement_friend_5_title => 'Historical Circle';

  @override
  String get achievement_friend_5_desc => 'Reach 5 friends';

  @override
  String get poi_santa_cristina_name => 'Church of Santa Cristina';

  @override
  String get poi_santa_cristina_desc => 'Historic church with a hemispherical dome and bell tower, set within Cesena\'s residential urban fabric. It represents the balance between religious architecture and urban development. During World War II, it likely served as a visual landmark during bombings, useful for population orientation. The surrounding area was partially affected or modified in the post-war period, with redefined urban spaces.';

  @override
  String get poi_rocca_name => 'Malatestiana Fortress';

  @override
  String get poi_rocca_desc => 'A medieval fortress dominating the city, featuring crenellated walls and towers; a central defensive and symbolic element of Cesena. Built by the Malatesta in 1380, it houses the Malatestiana Library, a UNESCO World Heritage site since 2005. During World War II, it was repurposed as a natural shelter thanks to its massive structure: the hill hosted tunnels and air-raid shelters to protect the civilian population during bombings.';

  @override
  String get poi_san_rocco_name => 'Church of San Rocco';

  @override
  String get poi_san_rocco_desc => 'A church located in a working-class neighborhood of Cesena, surrounded by simple buildings and historically unpaved roads. Dedicated to Saint Roch, the patron saint of plague victims, it has been a spiritual reference point for the working classes for centuries. During WWII, the neighborhood, inhabited by working families, was directly exposed to the hardships of the bombings, and the church served as a possible gathering point and transit area towards shelters during air raids.';

  @override
  String get poi_abbazia_monte_name => 'Abbey of Santa Maria del Monte';

  @override
  String get poi_abbazia_monte_desc => 'A monastic complex on a hill overlooking the city, surrounded by cultivated countryside; a strong religious and territorial symbol of Cesena for over a thousand years. Its elevated position made it strategically significant during World War II: it was used as an observation point or visual reference for military operations. The hilly area offered shelter and isolation from the urban center\'s bombings.';

  @override
  String get poi_osservanza_name => 'Church and Convent of the Osservanza';

  @override
  String get poi_osservanza_desc => 'A Franciscan religious complex nestled in the Cesena countryside, historically separated from the urban center. The church preserves valuable artworks from the 15th and 16th centuries. During World War II, its isolation from the city made it less exposed to direct attacks, becoming a possible place of refuge and spiritual assistance for evacuees and the rural population fleeing the bombings.';

  @override
  String get poi_palazzo_ridotto_name => 'Palazzo del Ridotto';

  @override
  String get poi_palazzo_ridotto_desc => 'A historic building with a civic tower, a symbol of the city center and public life in Cesena. It overlooks Piazza del Popolo, the heart of the city since the Middle Ages, also dominated by the Masini fountain. During World War II, it housed an air-raid siren essential for signaling incoming bombings, acting as a vital node in the alarm and coordination system for the civilian population.';

  @override
  String get poi_stazione_name => 'Cesena Railway Station';

  @override
  String get poi_stazione_desc => 'An important railway hub for freight and passenger transport between the 19th and 20th centuries, on the Bologna–Rimini Adriatic line. During World War II, it was one of the primary strategic targets of Allied bombings, as disrupting its supplies was essential to halting the German advance. It suffered severe destruction, becoming one of the most heavily bombed areas in the city.';

  @override
  String get poi_arrigoni_name => 'Arrigoni Factory';

  @override
  String get poi_arrigoni_desc => 'A large canning industry founded in 1880, the heart of the local economy and working-class labor in Cesena for over a century. Specializing in canned fish, it was among the most important companies in Romagna. During World War II, the production facility was strategically relevant for food logistics and was the site of strikes and strong social tensions, especially in the 1943–1944 biennium.';

  @override
  String get poi_fantaguzzi_name => 'Palazzo Fantaguzzi';

  @override
  String get poi_fantaguzzi_desc => 'A historic building in the heart of Cesena, the local headquarters of the National Fascist Party during Mussolini\'s regime. It represents one of the symbols of the Fascist era in the city. During World War II, it was the center of fascist political and administrative power at the city level, likely a place of repression, population control, and the organization of wartime activities in the territory.';

  @override
  String get poi_rifugi_antiaerei_name => 'Air-Raid Shelters of the Fortress';

  @override
  String get poi_rifugi_antiaerei_desc => 'A system of underground tunnels excavated beneath and around the Malatestiana Fortress to protect the civilian population from aerial bombings. During World War II, they were fundamental for the survival of hundreds of citizens: the shelters accommodated entire families, becoming true spaces of temporary underground life during the Allied attacks between 1943 and 1944.';

  @override
  String setupUsernameInvalid(int min, int max) {
    return 'Invalid username (use $min-$max characters: a-z, 0-9, _ or .).';
  }

  @override
  String get setupUsernameOffensive => 'Username contains prohibited terms. Please choose another.';

  @override
  String get setupUsernameTaken => 'Username is already taken. Please choose another.';

  @override
  String setupFirestoreError(Object username) {
    return 'Invalid Firestore configuration: read/write permissions required on usernames/$username.';
  }

  @override
  String get setupPermissionDenied => 'Insufficient Firestore permissions to complete the profile. Check project rules.';

  @override
  String get setupGenericError => 'Unable to save profile. Please try again in a few seconds.';

  @override
  String get setupTitle => 'Create your profile';

  @override
  String get setupSubtitle => 'Choose a unique username (cannot be changed), display name, and avatar.';

  @override
  String get setupNameLabel => 'Display Name';

  @override
  String get setupUsernameLabel => 'Username';

  @override
  String get setupUsernameHint => 'e.g., cesena_explorer';

  @override
  String get setupAvatarLabel => 'Choose avatar';

  @override
  String get setupSubmitButton => 'Confirm Profile';

  @override
  String get creditRoleDiplo => 'German Diplomatic Missions in Italy';

  @override
  String get creditRoleDiploDesc => 'Developed with their valuable contribution';

  @override
  String get sectionSupport => 'Collaborators and Support';

  @override
  String get quiz_fallback_name => 'Standard difficulty (local seed)';

  @override
  String get quiz_fallback_desc => 'Due to a server error, questions are not personalized and use a specific local difficulty.';

  @override
  String get quiz_santa_cristina_q1 => 'Which architectural element characterizes the church?';

  @override
  String get quiz_santa_cristina_q1_o1 => 'A Gothic bell tower';

  @override
  String get quiz_santa_cristina_q1_o2 => 'A hemispherical dome';

  @override
  String get quiz_santa_cristina_q1_o3 => 'A Renaissance rose window';

  @override
  String get quiz_santa_cristina_q2 => 'What role did the church play during World War II?';

  @override
  String get quiz_santa_cristina_q2_o1 => 'It was used as a field hospital';

  @override
  String get quiz_santa_cristina_q2_o2 => 'It was a visual landmark for orientation during bombings';

  @override
  String get quiz_santa_cristina_q2_o3 => 'It was the headquarters of the German military command';

  @override
  String get quiz_rocca_q1 => 'Who had the Fortress built?';

  @override
  String get quiz_rocca_q1_o1 => 'The Visconti';

  @override
  String get quiz_rocca_q1_o2 => 'The Malatesta';

  @override
  String get quiz_rocca_q1_o3 => 'Federico da Montefeltro';

  @override
  String get quiz_rocca_q2 => 'In what year did the Malatestiana Library become a UNESCO World Heritage site?';

  @override
  String get quiz_rocca_q2_o1 => '1995';

  @override
  String get quiz_rocca_q2_o2 => '2005';

  @override
  String get quiz_rocca_q2_o3 => '2015';

  @override
  String get quiz_rocca_q3 => 'How was the Fortress used during World War II?';

  @override
  String get quiz_rocca_q3_o1 => 'As a prison for partisans';

  @override
  String get quiz_rocca_q3_o2 => 'As an air-raid shelter for civilians';

  @override
  String get quiz_rocca_q3_o3 => 'As an ammunition depot';

  @override
  String get quiz_san_rocco_q1 => 'Which saint is the church dedicated to?';

  @override
  String get quiz_san_rocco_q1_o1 => 'Saint Francis';

  @override
  String get quiz_san_rocco_q1_o2 => 'Saint Roch';

  @override
  String get quiz_san_rocco_q1_o3 => 'Saint Anthony';

  @override
  String get quiz_san_rocco_q2 => 'In what kind of neighborhood is the church located?';

  @override
  String get quiz_san_rocco_q2_o1 => 'Noble neighborhood';

  @override
  String get quiz_san_rocco_q2_o2 => 'Working-class neighborhood';

  @override
  String get quiz_san_rocco_q2_o3 => 'University neighborhood';

  @override
  String get quiz_abbazia_monte_q1 => 'Where is the abbey located?';

  @override
  String get quiz_abbazia_monte_q1_o1 => 'On the plain, near the river';

  @override
  String get quiz_abbazia_monte_q1_o2 => 'On a hill overlooking the city';

  @override
  String get quiz_abbazia_monte_q1_o3 => 'In the historical center';

  @override
  String get quiz_abbazia_monte_q2 => 'What advantage did the abbey offer during the war?';

  @override
  String get quiz_abbazia_monte_q2_o1 => 'It housed a military food depot';

  @override
  String get quiz_abbazia_monte_q2_o2 => 'Its elevated position made it useful as an observation point';

  @override
  String get quiz_abbazia_monte_q2_o3 => 'It was the seat of the provisional government';

  @override
  String get quiz_osservanza_q1 => 'To which religious order does the convent belong?';

  @override
  String get quiz_osservanza_q1_o1 => 'Dominicans';

  @override
  String get quiz_osservanza_q1_o2 => 'Franciscans';

  @override
  String get quiz_osservanza_q1_o3 => 'Benedictines';

  @override
  String get quiz_osservanza_q2 => 'Why was the convent less exposed to bombings?';

  @override
  String get quiz_osservanza_q2_o1 => 'It was protected by underground bunkers';

  @override
  String get quiz_osservanza_q2_o2 => 'It was isolated from the urban center';

  @override
  String get quiz_osservanza_q2_o3 => 'It was garrisoned by the Allied army';

  @override
  String get quiz_palazzo_ridotto_q1 => 'What is the name of the fountain in Piazza del Popolo?';

  @override
  String get quiz_palazzo_ridotto_q1_o1 => 'Fountain of Neptune';

  @override
  String get quiz_palazzo_ridotto_q1_o2 => 'Fountain of Masini';

  @override
  String get quiz_palazzo_ridotto_q1_o3 => 'Fountain of the Dolphins';

  @override
  String get quiz_palazzo_ridotto_q2 => 'What military device was installed in the palace?';

  @override
  String get quiz_palazzo_ridotto_q2_o1 => 'An anti-aircraft machine gun';

  @override
  String get quiz_palazzo_ridotto_q2_o2 => 'An air-raid siren';

  @override
  String get quiz_palazzo_ridotto_q2_o3 => 'A spotting radar';

  @override
  String get quiz_stazione_q1 => 'Why was the station a target of Allied bombings?';

  @override
  String get quiz_stazione_q1_o1 => 'It housed the German headquarters';

  @override
  String get quiz_stazione_q1_o2 => 'It was a strategic node for military supplies';

  @override
  String get quiz_stazione_q1_o3 => 'It was the only hospital in the city';

  @override
  String get quiz_stazione_q2 => 'On which railway line is the Cesena station located?';

  @override
  String get quiz_stazione_q2_o1 => 'Bologna–Florence';

  @override
  String get quiz_stazione_q2_o2 => 'Bologna–Rimini (Adriatic line)';

  @override
  String get quiz_stazione_q2_o3 => 'Rimini–Rome';

  @override
  String get quiz_arrigoni_q1 => 'In which sector did the Arrigoni Factory operate?';

  @override
  String get quiz_arrigoni_q1_o1 => 'Textile industry';

  @override
  String get quiz_arrigoni_q1_o2 => 'Canned fish and food';

  @override
  String get quiz_arrigoni_q1_o3 => 'Heavy mechanics';

  @override
  String get quiz_arrigoni_q2 => 'What happened in the factory in 1943–1944?';

  @override
  String get quiz_arrigoni_q2_o1 => 'It was converted into a military hospital';

  @override
  String get quiz_arrigoni_q2_o2 => 'It was the scene of strikes and social tensions';

  @override
  String get quiz_arrigoni_q2_o3 => 'It was used as a prison by the Germans';

  @override
  String get quiz_fantaguzzi_q1 => 'Which organization was headquartered in Palazzo Fantaguzzi during the regime?';

  @override
  String get quiz_fantaguzzi_q1_o1 => 'The Municipality of Cesena';

  @override
  String get quiz_fantaguzzi_q1_o2 => 'The National Fascist Party';

  @override
  String get quiz_fantaguzzi_q1_o3 => 'The Red Cross';

  @override
  String get quiz_fantaguzzi_q2 => 'What role did the palace play during the war?';

  @override
  String get quiz_fantaguzzi_q2_o1 => 'Coordination center for partisan resistance';

  @override
  String get quiz_fantaguzzi_q2_o2 => 'Center of fascist political and administrative power';

  @override
  String get quiz_fantaguzzi_q2_o3 => 'Headquarters of the Allied military tribunal';

  @override
  String get quiz_rifugi_antiaerei_q1 => 'Where were the air-raid shelters excavated?';

  @override
  String get quiz_rifugi_antiaerei_q1_o1 => 'Under the Palazzo del Ridotto';

  @override
  String get quiz_rifugi_antiaerei_q1_o2 => 'Under and around the Malatestiana Fortress';

  @override
  String get quiz_rifugi_antiaerei_q1_o3 => 'Under the railway station';

  @override
  String get quiz_rifugi_antiaerei_q2 => 'In which years were the shelters mainly used?';

  @override
  String get quiz_rifugi_antiaerei_q2_o1 => '1940–1941';

  @override
  String get quiz_rifugi_antiaerei_q2_o2 => '1943–1944';

  @override
  String get quiz_rifugi_antiaerei_q2_o3 => '1945–1946';
}
