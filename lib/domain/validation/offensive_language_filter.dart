class OffensiveLanguageFilter {
  const OffensiveLanguageFilter._();

  // ─────────────────────────────────────────────────────────────────────────
  // LISTA TERMINI BLOCCATI
  //
  // IMPORTANTE – logica di matching:
  //   • I termini vengono confrontati SOLO come parole intere (word-boundary).
  //   • "bazzocchi" NON viene bloccato perché "cazzo" non è una parola intera
  //     all'interno di "bazzocchi"; il confronto avviene token per token.
  //   • Per i display name (con spazi) ogni parola viene testata separatamente.
  //   • Per gli username (singolo token) si controlla il token normalizzato
  //     nella sua interezza E se inizia/termina con un termine bloccato.
  // ─────────────────────────────────────────────────────────────────────────

  static const Set<String> _blockedTerms = {
    // 🇮🇹 Italiano – parolacce
    'merda', 'merdaccia', 'cagata', 'cacata', 'cagare',
    'cazzo', 'cazzone', 'cazzata', 'cazzate', 'testadicazzo', 'testacazzo',
    'minchia', 'minchiata', 'minchiate', 'minchione',
    'stronzo', 'stronza', 'stronzata', 'stronzate',
    'coglione', 'coglioni', 'rompicoglioni',
    'figa', 'fica', 'fregna', 'passera', 'topa', 'fessa', 'fighetta',
    'culo', 'culattone', 'bucaiolo', 'busone',
    'palle', 'chepalle', 'rompiballe',
    'puttana', 'puttanella',
    'troia',
    'zoccola',
    'mignotta',
    'baldracca',
    'bagascia',
    'battona',
    'sgualdrina',
    'bastardo', 'figliodiputtana', 'figlioditroia',
    'vaffanculo', 'fanculo', 'fottiti', 'fottuto',
    'succhia', 'suca', 'pompino', 'bocchino',
    'segaiolo', 'mezzasega',
    'cornuto',
    'sfigato',
    'incazzato',

    // 🇮🇹 Bestemmie
    'porcodio', 'porcoddio', 'porcadio',
    'dioporco', 'diocane', 'diomerda', 'diostronzo', 'diobastardo',
    'dioladro', 'dioboia', 'diomaiale', 'diobestia',
    'porcamadonna', 'porcamadonn',
    'madonnputtana', 'madonnatroia', 'madonnvacca',
    'gesucane', 'porcocristo', 'cristoboia',
    'porcoiddio', 'porchiddio', 'porcacciodio',

    // 🇬🇧 Inglese
    'fuck', 'fucking', 'shit', 'bullshit',
    'bitch', 'sonofabitch',
    'asshole', 'cunt', 'dick', 'dickhead', 'cock', 'pussy',
    'whore', 'slut', 'nigger', 'nigga', 'faggot',
    'retard', 'retarded', 'motherfucker',

    // Insulti generici
    'cretino', 'imbecille', 'deficiente', 'ritardato',
    'mongoloide', 'negro', 'frocio', 'ricchione', 'finocchio',
  };

  // Frasi multi-parola (controllate come substring sull'input completo)
  static const Set<String> _blockedPhrases = {
    'porco dio', 'dio porco', 'dio cane', 'dio merda', 'dio stronzo',
    'dio bastardo', 'dio ladro', 'dio boia', 'dio maiale', 'dio bestia',
    'porca madonna', 'madonna puttana', 'madonna troia',
    'madonna zoccola', 'madonna lurida', 'madonna vacca',
    'gesù cane', 'porco gesù', 'porco cristo', 'porco iddio',
    'mannaggia madonna', 'mannaggia cristo', 'mannaggia dio',
    'testa di minchia', 'testa di merda', 'pezzo di merda',
  };

  // ─────────────────────────────────────────────────────────────────────────
  // API PUBBLICA
  // ─────────────────────────────────────────────────────────────────────────

  /// Controlla un **display name** (può avere spazi).
  /// Ogni parola viene confrontata individualmente – i cognomi/nomi
  /// che contengono sequenze simili a parolacce NON vengono bloccati
  /// perché il confronto è word-boundary.
  static bool isOffensiveDisplayName(String value) {
    final clean = value.trim().toLowerCase();
    if (clean.isEmpty) return false;

    // 1. Frasi multi-parola
    if (_containsBlockedPhrase(clean)) return true;

    // 2. Ogni token individuale
    final tokens = clean.split(RegExp(r'[^a-zàáâãäåèéêëìíîïòóôõöùúûüýñç]+'));
    for (final token in tokens) {
      if (token.length < 3) continue;
      final norm = _normalize(token);
      if (norm.isNotEmpty && _blockedTerms.contains(norm)) return true;
      // Controlla anche il token non normalizzato per catturare varianti dirette
      if (_blockedTerms.contains(token)) return true;
    }
    return false;
  }

  /// Controlla uno **username** (singolo token, già normalizzato a-z0-9._).
  /// Blocca solo se:
  ///   (a) l'username coincide esattamente con un termine bloccato, OPPURE
  ///   (b) l'username inizia O termina con un termine bloccato
  ///       (es. "cazzomio" o "miocazzo" → bloccati; "bazzocchi" → OK).
  static bool isOffensiveUsername(String value) {
    final norm = _normalize(value.toLowerCase().trim());
    if (norm.isEmpty) return false;

    for (final term in _blockedTerms) {
      if (term.length < 4) continue; // ignora abbreviazioni di 1-3 lettere

      // (a) match esatto
      if (norm == term) return true;

      // (b) inizia o finisce con il termine (es. "cazzoXYZ" o "XYZcazzo")
      if (norm.startsWith(term) || norm.endsWith(term)) return true;
    }
    return false;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Retrocompatibilità – usata internamente da ProfileValidation
  // ─────────────────────────────────────────────────────────────────────────
  static bool containsOffensiveLanguage(String value) =>
      isOffensiveDisplayName(value);

  // ─────────────────────────────────────────────────────────────────────────
  // HELPERS PRIVATI
  // ─────────────────────────────────────────────────────────────────────────

  static bool _containsBlockedPhrase(String normalized) {
    for (final phrase in _blockedPhrases) {
      if (normalized.contains(phrase)) return true;
    }
    return false;
  }

  static String _normalize(String value) {
    var r = value.toLowerCase();
    r = _removeDiacritics(r);
    r = r
        .replaceAll(RegExp(r'[4@]'), 'a')
        .replaceAll(RegExp(r'[3€]'), 'e')
        .replaceAll(RegExp(r'[1!|]'), 'i')
        .replaceAll(RegExp(r'[0]'), 'o')
        .replaceAll(RegExp(r'[5\$]'), 's')
        .replaceAll('7', 't')
        .replaceAll('ph', 'f');

    // Rimuovi caratteri tripli ripetuti (fuuuck → fuk)
    r = r.replaceAllMapped(RegExp(r'(.)\1{2,}'), (m) => m.group(1)!);

    // Tieni solo lettere
    r = r.replaceAll(RegExp(r'[^a-z]'), '');
    return r;
  }

  static String _removeDiacritics(String input) {
    const diacritics =
        'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÑñÇç';
    const replacement =
        'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuYyNnCc';
    var result = input;
    for (var i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacement[i]);
    }
    return result;
  }
}
