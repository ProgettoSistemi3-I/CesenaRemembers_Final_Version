import 'package:flutter/foundation.dart';

class ShellNavigationStore {
  ShellNavigationStore._();

  static final ValueNotifier<int> tabIndex = ValueNotifier<int>(0);
  static final ValueNotifier<bool> focusGpsToggleInSettings =
      ValueNotifier<bool>(false);

  static void goToTab(int index) {
    if (tabIndex.value != index) {
      tabIndex.value = index;
    }
  }

  static void openSettingsAndFocusGpsToggle() {
    focusGpsToggleInSettings.value = true;
    goToTab(2);
  }
}
