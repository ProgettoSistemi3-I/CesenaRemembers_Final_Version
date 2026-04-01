import 'package:flutter/material.dart';

import '../../domain/entities/quiz_question.dart';

class HistoricPlaceSeedItem {
  const HistoricPlaceSeedItem({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.period,
    required this.description,
    required this.icon,
    required this.iconBackground,
    required this.questions,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String type;
  final String period;
  final String description;
  final IconData icon;
  final Color iconBackground;
  final List<QuizQuestion> questions;
}

class HistoricPlacesSeed {
  const HistoricPlacesSeed._();

  static const List<HistoricPlaceSeedItem> items = [
    // ─── 1. Chiesa di Santa Cristina ───────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'santa_cristina',
      name: 'Chiesa di Santa Cristina',
      latitude: 44.14100,
      longitude: 12.24236,
      type: 'church',
      period: 'XVII sec.',
      description:
          'Chiesa storica con cupola emisferica e campanile, inserita nel tessuto urbano residenziale di Cesena. Rappresenta l\'equilibrio tra architettura religiosa e sviluppo cittadino. Durante la Seconda Guerra Mondiale fu un probabile punto di riferimento visivo durante i bombardamenti, utile per l\'orientamento della popolazione. L\'area circostante venne parzialmente colpita o modificata nel dopoguerra, con spazi urbani ridefiniti.',
      icon: Icons.church_outlined,
      iconBackground: Color(0xFFE1BEE7),
      questions: [
        QuizQuestion(
          question: 'Quale elemento architettonico caratterizza la chiesa?',
          options: [
            'Un campanile gotico',
            'Una cupola emisferica',
            'Un rosone rinascimentale',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'Quale ruolo ebbe la chiesa durante la Seconda Guerra Mondiale?',
          options: [
            'Fu usata come ospedale da campo',
            'Fu un riferimento visivo per orientarsi durante i bombardamenti',
            'Fu sede del comando militare tedesco',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 2. Rocca Malatestiana ─────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'rocca',
      name: 'Rocca Malatestiana',
      latitude: 44.13619,
      longitude: 12.23989,
      type: 'monument',
      period: 'XIV sec.',
      description:
          'Fortezza medievale dominante sulla città, con mura merlate e torrioni; elemento difensivo e simbolico centrale di Cesena. Costruita dai Malatesta nel 1380, ospita la Biblioteca Malatestiana, patrimonio UNESCO dal 2005. Durante la Seconda Guerra Mondiale fu riutilizzata come rifugio naturale grazie alla sua struttura massiccia: il colle ospitò gallerie e rifugi antiaerei per la protezione della popolazione civile durante i bombardamenti.',
      icon: Icons.castle_outlined,
      iconBackground: Color(0xFFC8E6C9),
      questions: [
        QuizQuestion(
          question: 'Chi ha fatto costruire la Rocca?',
          options: ['I Visconti', 'I Malatesta', 'Federico da Montefeltro'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'In quale anno la Biblioteca Malatestiana è diventata patrimonio UNESCO?',
          options: ['1995', '2005', '2015'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'Come fu usata la Rocca durante la Seconda Guerra Mondiale?',
          options: [
            'Come prigione per i partigiani',
            'Come rifugio antiaereo per i civili',
            'Come deposito di munizioni',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 3. Chiesa di San Rocco ────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'san_rocco',
      name: 'Chiesa di San Rocco',
      latitude: 44.14022,
      longitude: 12.24072,
      type: 'church',
      period: 'XVI sec.',
      description:
          'Chiesa situata in un quartiere popolare di Cesena, con edifici semplici e strade storicamente sterrate. Dedicata a San Rocco, patrono degli appestati, è da secoli un punto di riferimento spirituale per le classi lavoratrici. Durante la Seconda Guerra Mondiale il quartiere, abitato da famiglie operaie, fu direttamente esposto alle difficoltà dei bombardamenti e la chiesa rappresentò un possibile luogo di raccolta e transito verso i rifugi durante gli allarmi aerei.',
      icon: Icons.church_outlined,
      iconBackground: Color(0xFFFFCCBC),
      questions: [
        QuizQuestion(
          question: 'A quale santo è dedicata la chiesa?',
          options: ['San Francesco', 'San Rocco', 'Sant\'Antonio'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'In quale tipo di quartiere sorge la chiesa?',
          options: [
            'Quartiere nobiliare',
            'Quartiere popolare operaio',
            'Quartiere universitario',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 4. Abbazia di Santa Maria del Monte ──────────────────────────────
    HistoricPlaceSeedItem(
      id: 'abbazia_monte',
      name: 'Abbazia di Santa Maria del Monte',
      latitude: 44.13164,
      longitude: 12.25486,
      type: 'monument',
      period: 'XI sec.',
      description:
          'Complesso monastico su un colle dominante la città, circondato da campagna coltivata; forte simbolo religioso e territoriale di Cesena da oltre mille anni. La sua posizione elevata la rese strategicamente significativa durante la Seconda Guerra Mondiale: fu usata come punto di osservazione o riferimento visivo per le operazioni militari. L\'area collinare offrì rifugio e isolamento rispetto ai bombardamenti del centro urbano.',
      icon: Icons.terrain,
      iconBackground: Color(0xFFD7CCC8),
      questions: [
        QuizQuestion(
          question: 'Dove sorge l\'abbazia?',
          options: [
            'In pianura, vicino al fiume',
            'Su un colle dominante la città',
            'Nel centro storico',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Quale vantaggio offrì l\'abbazia durante la guerra?',
          options: [
            'Ospitava un deposito di viveri militari',
            'La posizione elevata la rendeva utile come punto di osservazione',
            'Era sede del governo provvisorio',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 5. Chiesa e Convento dell'Osservanza ─────────────────────────────
    HistoricPlaceSeedItem(
      id: 'osservanza',
      name: 'Chiesa e Convento dell\'Osservanza',
      latitude: 44.13277,
      longitude: 12.24424,
      type: 'church',
      period: 'XV sec.',
      description:
          'Complesso religioso francescano immerso nella campagna cesenate, storicamente separato dal centro urbano. La chiesa conserva pregevoli opere d\'arte del Quattrocento e Cinquecento. Durante la Seconda Guerra Mondiale l\'isolamento rispetto alla città lo rendeva meno esposto agli attacchi diretti, diventando un possibile luogo di rifugio e assistenza spirituale per sfollati e popolazione rurale in fuga dai bombardamenti.',
      icon: Icons.fort,
      iconBackground: Color(0xFFC5CAE9),
      questions: [
        QuizQuestion(
          question: 'A quale ordine religioso appartiene il convento?',
          options: ['Domenicani', 'Francescani', 'Benedettini'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Perché il convento era meno esposto ai bombardamenti?',
          options: [
            'Era protetto da bunker sotterranei',
            'Era isolato rispetto al centro urbano',
            'Era presidiato dall\'esercito alleato',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 6. Palazzo del Ridotto (ex Piazza del Popolo) ────────────────────
    HistoricPlaceSeedItem(
      id: 'palazzo_ridotto',
      name: 'Palazzo del Ridotto',
      latitude: 44.13819,
      longitude: 12.24361,
      type: 'square',
      period: 'Medioevo',
      description:
          'Edificio storico con torre civica, simbolo del centro cittadino e della vita pubblica di Cesena. Affaccia sulla Piazza del Popolo, cuore della città fin dal Medioevo, dominata anche dalla fontana del Masini. Durante la Seconda Guerra Mondiale ospitava una sirena antiaerea fondamentale per segnalare l\'arrivo dei bombardamenti, costituendo un nodo vitale nel sistema di allarme e coordinamento della popolazione civile.',
      icon: Icons.account_balance_outlined,
      iconBackground: Color(0xFFBBDEFB),
      questions: [
        QuizQuestion(
          question: 'Come si chiama la fontana in Piazza del Popolo?',
          options: [
            'Fontana di Nettuno',
            'Fontana del Masini',
            'Fontana dei Delfini',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Quale dispositivo bellico era installato nel palazzo?',
          options: [
            'Una mitragliatrice antiaerea',
            'Una sirena antiaerea',
            'Un radar di avvistamento',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 7. Stazione ferroviaria di Cesena ────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'stazione',
      name: 'Stazione Ferroviaria di Cesena',
      latitude: 44.14525,
      longitude: 12.24956,
      type: 'monument',
      period: 'XIX sec.',
      description:
          'Importante nodo ferroviario per il trasporto merci e passeggeri tra l\'Ottocento e il Novecento, sulla linea adriatica Bologna–Rimini. Durante la Seconda Guerra Mondiale fu uno degli obiettivi strategici primari dei bombardamenti alleati, poiché interromperne i rifornimenti era essenziale per bloccare l\'avanzata tedesca. Subì gravi distruzioni, diventando uno dei punti più colpiti della città.',
      icon: Icons.train_outlined,
      iconBackground: Color(0xFFFFECB3),
      questions: [
        QuizQuestion(
          question:
              'Perché la stazione era un obiettivo dei bombardamenti alleati?',
          options: [
            'Ospitava il quartier generale tedesco',
            'Era un nodo strategico per i rifornimenti militari',
            'Era l\'unico ospedale della città',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'Su quale linea ferroviaria si trova la stazione di Cesena?',
          options: [
            'Bologna–Firenze',
            'Bologna–Rimini (linea adriatica)',
            'Rimini–Roma',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 8. Stabilimento Arrigoni ─────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'arrigoni',
      name: 'Stabilimento Arrigoni',
      latitude: 44.14400,
      longitude: 12.24753,
      type: 'monument',
      period: 'XX sec.',
      description:
          'Grande industria conserviera fondata nel 1880, cuore dell\'economia locale e del lavoro operaio cesenate per oltre un secolo. Specializzata in conserve ittiche, fu tra le più importanti aziende della Romagna. Durante la Seconda Guerra Mondiale la struttura produttiva era strategicamente rilevante per la logistica alimentare, e fu teatro di scioperi e forti tensioni sociali, soprattutto nel biennio 1943–1944.',
      icon: Icons.factory_outlined,
      iconBackground: Color(0xFFB2EBF2),
      questions: [
        QuizQuestion(
          question: 'In quale settore operava lo Stabilimento Arrigoni?',
          options: [
            'Industria tessile',
            'Conserve ittiche e alimentari',
            'Meccanica pesante',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Cosa accadde nello stabilimento nel 1943–1944?',
          options: [
            'Fu convertito in ospedale militare',
            'Fu teatro di scioperi e tensioni sociali',
            'Fu utilizzato come prigione dai tedeschi',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 9. Palazzo Fantaguzzi ────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'fantaguzzi',
      name: 'Palazzo Fantaguzzi',
      latitude: 44.13822,
      longitude: 12.24531,
      type: 'monument',
      period: 'XX sec.',
      description:
          'Palazzo storico nel cuore di Cesena, sede del Partito Nazionale Fascista locale durante il regime mussoliniano. Rappresenta uno dei simboli del ventennio fascista in città. Durante la Seconda Guerra Mondiale fu il centro del potere politico e amministrativo fascista a livello cittadino, probabile luogo di repressione, controllo della popolazione e organizzazione delle attività belliche sul territorio.',
      icon: Icons.domain_outlined,
      iconBackground: Color(0xFFFFCDD2),
      questions: [
        QuizQuestion(
          question:
              'Quale organizzazione aveva sede nel Palazzo Fantaguzzi durante il regime?',
          options: [
            'Il Comune di Cesena',
            'Il Partito Nazionale Fascista',
            'La Croce Rossa',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'Quale ruolo ebbe il palazzo durante la guerra?',
          options: [
            'Centro di coordinamento della resistenza partigiana',
            'Centro del potere politico e amministrativo fascista',
            'Sede del tribunale militare alleato',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 10. Rifugi antiaerei della Rocca ─────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'rifugi_antiaerei',
      name: 'Rifugi Antiaerei della Rocca',
      latitude: 44.13703,
      longitude: 12.23931,
      type: 'monument',
      period: 'XX sec.',
      description:
          'Sistema di tunnel sotterranei scavati sotto e intorno alla Rocca Malatestiana per proteggere la popolazione civile dai bombardamenti aerei. Durante la Seconda Guerra Mondiale furono fondamentali per la sopravvivenza di centinaia di cesenati: i rifugi accolsero famiglie intere, diventando veri e propri spazi di vita temporanea sotterranea durante gli attacchi alleati tra il 1943 e il 1944.',
      icon: Icons.safety_divider_outlined,
      iconBackground: Color(0xFFCFD8DC),
      questions: [
        QuizQuestion(
          question: 'Dove erano scavati i rifugi antiaerei?',
          options: [
            'Sotto il Palazzo del Ridotto',
            'Sotto e intorno alla Rocca Malatestiana',
            'Sotto la stazione ferroviaria',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'In quali anni furono principalmente utilizzati i rifugi?',
          options: ['1940–1941', '1943–1944', '1945–1946'],
          correctIndex: 1,
        ),
      ],
    ),
  ];
}
