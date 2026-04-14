class OffensiveLanguageFilter {
  const OffensiveLanguageFilter._();

  static const Set<String> _blockedTerms = {
    'merda',
    'cazzo',
    'stronzo',
    'vaffanculo',
    'troia',
    'puttana',
    'bastardo',
    'fuck',
    'shit',
    'bitch',
    'asshole',
    'nigger',
    'faggot',
    'retard',
  };

  static bool containsOffensiveLanguage(String value) {
    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;

    for (final term in _blockedTerms) {
      if (normalized.contains(term)) {
        return true;
      }
    }
    return false;
  }

  static String _normalize(String value) {
    final lower = value.toLowerCase();
    final compact = lower.replaceAll(RegExp(r'[\s\W_]+'), '');
    return compact;
  }
}
