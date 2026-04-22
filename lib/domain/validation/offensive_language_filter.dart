class OffensiveLanguageFilter {
  const OffensiveLanguageFilter._();

  static const Set<String> _blockedTerms = {
    // 🇮🇹 Italiano - Parolacce generali (esteso)
    'merda', 'merd', 'merdaccia', 'cagata', 'cacata', 'cacca', 'cagare', 'cag',
    'cazzo',
    'cazz',
    'cazzone',
    'cazzata',
    'cazzate',
    'testadicazzo',
    'testacazzo',
    'minchia', 'minch', 'minchiata', 'minchiate', 'minchione',
    'stronzo', 'stronz', 'stronza', 'stronzata', 'stronzate',
    'coglione', 'coglion', 'coglioni', 'rompicoglioni', 'rompicoglion',
    'figa', 'fica', 'fregna', 'passera', 'topa', 'fessa', 'fighetta',
    'culo', 'cul', 'culattone', 'bucaiolo', 'busone',
    'palle', 'pall', 'chepalle', 'rompiballe', 'rompiball',
    'puttana', 'puttan', 'putt', 'puttanella',
    'troia',
    'troi',
    'zoccola',
    'zocc',
    'mignotta',
    'mignott',
    'baldracca',
    'bagascia',
    'battona',
    'sgualdrina',
    'bastardo', 'bastard', 'figliodiputtana', 'figlioditroia', 'figlioditroi',
    'vaffanculo',
    'vaffan',
    'fanculo',
    'fanc',
    'vaff',
    'fottiti',
    'fott',
    'fottuto',
    'succhia',
    'suca',
    'pompa',
    'pompino',
    'bocchino',
    'segaiolo',
    'sega',
    'mezzasega',
    'cornuto', 'cornut', 'cuck',
    'sfigato', 'sfigat', 'sfig',

    // Bestemmie e varianti blasfeme (la parte più estesa)
    'porcodio', 'porco dio', 'porcoddio', 'porcadio', 'pordio', 'pordd',
    'dio porco', 'dioporco',
    'porcamadonna', 'porca madonna', 'porcamadonn',
    'madonna puttana', 'madonnputtana', 'madonnatroia', 'madonnatroi',
    'madonna troia', 'madonna zoccola', 'madonna lurida',
    'diocane', 'dio cane', 'dio merda', 'diomerda',
    'dio stronzo', 'diostronzo',
    'dio bastardo', 'diobastardo',
    'dio ladro', 'dioladro',
    'dio boia', 'dioboia',
    'dio maiale', 'diomaiale',
    'dio bestia', 'diobestia',
    'dio vigliacco', 'diovigliacco',
    'gesucristo', 'gesù cane', 'gesucane', 'porcogesù', 'porco gesù',
    'porco cristo', 'porcocristo',
    'mannaggia madonna',
    'mannaggia alla madonna',
    'mannaggia cristo',
    'mannaggia a cristo',
    'mannaggia dio', 'mannaggia',
    'porco iddio', 'porcoiddio', 'porchiddio',
    'porcaccio dio', 'porcacciodio',
    'diocane porco', 'madonna impestata', 'dio schifoso', 'dio lurido',
    'cristo boia', 'cristoboia', 'madonna vacca', 'madonnvacca',

    // Inglese (hai già una buona base, ho aggiunto qualche variante comune)
    'fuck', 'fck', 'fuk', 'fucking', 'fuker',
    'shit', 'sht', 'bullshit',
    'bitch', 'btch', 'sonofabitch',
    'asshole', 'ashole',
    'cunt',
    'dick', 'dickhead',
    'cock',
    'pussy',
    'whore', 'slut',
    'nigger', 'nigga',
    'faggot', 'fag',
    'retard', 'retarded',
    'moron',
    'idiot',
    'stupid',
    'dumbass',
    'jackass',
    'motherfucker',
    'motherfukr',

    'cretino', 'cretin',
    'imbecille', 'imbecil',
    'deficiente', 'defic',
    'ritardato', 'ritard',
    'mongoloide', 'mongol',
    'negro',
    'duce',
    'ebrei',
    'immigrati',
    'finocchio',
    'magrebino',
    'magrebini',
    'frocio',
    'froc',
    'ricchione',
    'ricchion',
    'lesbica',
    'incazzato', 'incazz', 'incaz',
    'testa di minchia', 'testadiminchia',
    'testa di merda', 'testadimerda',
    'pezzo di merda', 'pezzodimerda',
  };

  static bool containsOffensiveLanguage(String value) {
    if (value.trim().isEmpty) return false;

    final words = value.toLowerCase().trim().split(RegExp(r'\s+'));
    for (final word in words) {
      final cleaned = word.replaceAll(RegExp(r'[^\w]'), '');
      if (cleaned.isNotEmpty && _blockedTerms.contains(cleaned)) {
        return true;
      }
    }

    final normalized = _normalize(value);
    if (normalized.isEmpty) return false;

    for (final term in _blockedTerms) {
      if (normalized.contains(term)) return true;
    }

    return false;
  }

  static String _normalize(String value) {
    var result = value.toLowerCase();

    // Rimuovi diacritici (è → e, à → a, ecc.)
    result = _removeDiacritics(result);

    // Leetspeak e sostituzioni comuni
    result = result
        .replaceAll(RegExp(r'[4@à]'), 'a')
        .replaceAll(RegExp(r'[3€è]'), 'e')
        .replaceAll(RegExp(r'[1!|ì]'), 'i')
        .replaceAll(RegExp(r'[0òó]'), 'o')
        .replaceAll(RegExp(r'[5\$]'), 's')
        .replaceAll(RegExp(r'[7]'), 't')
        .replaceAll(RegExp(r'[ùú]'), 'u')
        .replaceAll(RegExp(r'[ç]'), 'c')
        .replaceAll(RegExp(r'[ñ]'), 'n')
        .replaceAll('ph', 'f') // "phuck" → "fuck"
        .replaceAll('ck', 'k'); // opzionale, riduce falsi negativi

    // Rimuovi caratteri ripetuti (fuuuck → fuk, merdaaa → merda)
    result = result.replaceAllMapped(RegExp(r'(.)\1{2,}'), (m) => m.group(1)!);

    // Rimuovi tutto tranne lettere e numeri
    result = result.replaceAll(RegExp(r'[^a-z0-9]'), '');

    return result;
  }

  static String _removeDiacritics(String input) {
    const diacritics = 'ÀÁÂÃÄÅàáâãäåÈÉÊËèéêëÌÍÎÏìíîïÒÓÔÕÖØòóôõöøÙÚÛÜùúûüÝýÑñÇç';
    const replacement =
        'AAAAAAaaaaaaEEEEeeeeIIIIiiiiOOOOOOooooooUUUUuuuuYyNnCc';

    var result = input;
    for (var i = 0; i < diacritics.length; i++) {
      result = result.replaceAll(diacritics[i], replacement[i]);
    }
    return result;
  }
}
