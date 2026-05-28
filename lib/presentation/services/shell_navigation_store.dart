import 'package:flutter/foundation.dart';

class ShellNavigationStore {
  ShellNavigationStore._();

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  static final ValueNotifier<bool> focusGpsToggleInSettings =
      ValueNotifier<bool>(false);
  static final ValueNotifier<bool> openFriendRequestsPanel =
      ValueNotifier<bool>(false);

  static void goToTab(int index) {
    if (tabIndex.value != index) {
      tabIndex.value = index;
    }
  }

  /// When set to true, ProfilePage scrolls to the achievements section.
  static final ValueNotifier<bool> scrollToAchievements =
      ValueNotifier<bool>(false);

  static void openSettingsAndFocusGpsToggle() {
    focusGpsToggleInSettings.value = true;
    goToTab(3);
  }

  /// Navigates to the Profile tab and scrolls to the achievements section.
  static void goToAchievements() {
    goToTab(2);
    // Post-frame so the tab switch completes before scroll is triggered.
    scrollToAchievements.value = false;
    Future.microtask(() => scrollToAchievements.value = true);
  }
}
