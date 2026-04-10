class ProfileValidation {
  static const int minDisplayNameLength = 2;
  static const int maxDisplayNameLength = 30;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 20;

  static String normalizeUsername(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.replaceAll(RegExp(r'[^a-z0-9_.]'), '');
  }

  static bool isValidDisplayName(String value) {
    final length = value.trim().length;
    return length >= minDisplayNameLength && length <= maxDisplayNameLength;
  }

  static bool isValidUsername(String value) {
    final normalized = normalizeUsername(value);
    return normalized.length >= minUsernameLength &&
        normalized.length <= maxUsernameLength;
  }
}
