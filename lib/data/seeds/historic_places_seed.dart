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
      name: 'poi_santa_cristina_name',
      latitude: 44.14100,
      longitude: 12.24236,
      type: 'church',
      period: '17th Century',
      description:
          'poi_santa_cristina_description',
      icon: Icons.church_outlined,
      iconBackground: Color(0xFFE1BEE7),
      questions: [
        QuizQuestion(
          question: 'quiz_santa_cristina_q1',
          options: [
            'quiz_santa_cristina_q1_o1',
            'quiz_santa_cristina_q1_o2',
            'quiz_santa_cristina_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'quiz_santa_cristina_q2',
          options: [
            'quiz_santa_cristina_q2_o1',
            'quiz_santa_cristina_q2_o2',
            'quiz_santa_cristina_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 2. Rocca Malatestiana ─────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'rocca',
      name: 'poi_rocca_name',
      latitude: 44.13619,
      longitude: 12.23989,
      type: 'monument',
      period: '14th Century',
      description:
          'poi_rocca_description',
      icon: Icons.castle_outlined,
      iconBackground: Color(0xFFC8E6C9),
      questions: [
        QuizQuestion(
          question: 'quiz_rocca_q1',
          options: ['quiz_rocca_q1_o1', 'quiz_rocca_q1_o2', 'quiz_rocca_q1_o3'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'quiz_rocca_q2',
          options: ['quiz_rocca_q2_o1', 'quiz_rocca_q2_o2', 'quiz_rocca_q2_o3'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'quiz_rocca_q3',
          options: [
            'quiz_rocca_q3_o1',
            'quiz_rocca_q3_o2',
            'quiz_rocca_q3_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 3. Chiesa di San Rocco ────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'san_rocco',
      name: 'poi_san_rocco_name',
      latitude: 44.14022,
      longitude: 12.24072,
      type: 'church',
      period: '16th Century',
      description:
          'poi_san_rocco_description',
      icon: Icons.church_outlined,
      iconBackground: Color(0xFFFFCCBC),
      questions: [
        QuizQuestion(
          question: 'quiz_san_rocco_q1',
          options: ['quiz_san_rocco_q1_o1', 'quiz_san_rocco_q1_o2', 'quiz_san_rocco_q1_o3'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_san_rocco_q2',
          options: [
            'quiz_san_rocco_q2_o1',
            'quiz_san_rocco_q2_o2',
            'quiz_san_rocco_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 4. Abbazia di Santa Maria del Monte ──────────────────────────────
    HistoricPlaceSeedItem(
      id: 'abbazia_monte',
      name: 'poi_abbazia_monte_name',
      latitude: 44.13164,
      longitude: 12.25486,
      type: 'monument',
      period: '11th Century',
      description:
          'poi_abbazia_monte_description',
      icon: Icons.terrain,
      iconBackground: Color(0xFFD7CCC8),
      questions: [
        QuizQuestion(
          question: 'quiz_abbazia_monte_q1',
          options: [
            'quiz_abbazia_monte_q1_o1',
            'quiz_abbazia_monte_q1_o2',
            'quiz_abbazia_monte_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_abbazia_monte_q2',
          options: [
            'quiz_abbazia_monte_q2_o1',
            'quiz_abbazia_monte_q2_o2',
            'quiz_abbazia_monte_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 5. Chiesa e Convento dell'Osservanza ─────────────────────────────
    HistoricPlaceSeedItem(
      id: 'osservanza',
      name: 'poi_osservanza_name',
      latitude: 44.13277,
      longitude: 12.24424,
      type: 'church',
      period: '15th Century',
      description:
          'poi_osservanza_description',
      icon: Icons.fort,
      iconBackground: Color(0xFFC5CAE9),
      questions: [
        QuizQuestion(
          question: 'quiz_osservanza_q1',
          options: ['quiz_osservanza_q1_o1', 'quiz_osservanza_q1_o2', 'quiz_osservanza_q1_o3'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_osservanza_q2',
          options: [
            'quiz_osservanza_q2_o1',
            'quiz_osservanza_q2_o2',
            'quiz_osservanza_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 6. Palazzo del Ridotto (ex Piazza del Popolo) ────────────────────
    HistoricPlaceSeedItem(
      id: 'palazzo_ridotto',
      name: 'poi_palazzo_ridotto_name',
      latitude: 44.13819,
      longitude: 12.24361,
      type: 'square',
      period: 'Medioevo',
      description:
          'poi_palazzo_ridotto_description',
      icon: Icons.account_balance_outlined,
      iconBackground: Color(0xFFBBDEFB),
      questions: [
        QuizQuestion(
          question: 'quiz_palazzo_ridotto_q1',
          options: [
            'quiz_palazzo_ridotto_q1_o1',
            'quiz_palazzo_ridotto_q1_o2',
            'quiz_palazzo_ridotto_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_palazzo_ridotto_q2',
          options: [
            'quiz_palazzo_ridotto_q2_o1',
            'quiz_palazzo_ridotto_q2_o2',
            'quiz_palazzo_ridotto_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 7. Stazione ferroviaria di Cesena ────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'stazione',
      name: 'poi_stazione_name',
      latitude: 44.14525,
      longitude: 12.24956,
      type: 'monument',
      period: '19th Century',
      description:
          'poi_stazione_description',
      icon: Icons.train_outlined,
      iconBackground: Color(0xFFFFECB3),
      questions: [
        QuizQuestion(
          question:
              'quiz_stazione_q1',
          options: [
            'quiz_stazione_q1_o1',
            'quiz_stazione_q1_o2',
            'quiz_stazione_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question:
              'quiz_stazione_q2',
          options: [
            'quiz_stazione_q2_o1',
            'quiz_stazione_q2_o2',
            'quiz_stazione_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 8. Stabilimento Arrigoni ─────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'arrigoni',
      name: 'poi_arrigoni_name',
      latitude: 44.14400,
      longitude: 12.24753,
      type: 'monument',
      period: '20th Century',
      description:
          'poi_arrigoni_description',
      icon: Icons.factory_outlined,
      iconBackground: Color(0xFFB2EBF2),
      questions: [
        QuizQuestion(
          question: 'quiz_arrigoni_q1',
          options: [
            'quiz_arrigoni_q1_o1',
            'quiz_arrigoni_q1_o2',
            'quiz_arrigoni_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_arrigoni_q2',
          options: [
            'quiz_arrigoni_q2_o1',
            'quiz_arrigoni_q2_o2',
            'quiz_arrigoni_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 9. Palazzo Fantaguzzi ────────────────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'fantaguzzi',
      name: 'poi_fantaguzzi_name',
      latitude: 44.13822,
      longitude: 12.24531,
      type: 'monument',
      period: '20th Century',
      description:
          'poi_fantaguzzi_description',
      icon: Icons.domain_outlined,
      iconBackground: Color(0xFFFFCDD2),
      questions: [
        QuizQuestion(
          question:
              'quiz_fantaguzzi_q1',
          options: [
            'quiz_fantaguzzi_q1_o1',
            'quiz_fantaguzzi_q1_o2',
            'quiz_fantaguzzi_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_fantaguzzi_q2',
          options: [
            'quiz_fantaguzzi_q2_o1',
            'quiz_fantaguzzi_q2_o2',
            'quiz_fantaguzzi_q2_o3',
          ],
          correctIndex: 1,
        ),
      ],
    ),

    // ─── 10. Rifugi antiaerei della Rocca ─────────────────────────────────
    HistoricPlaceSeedItem(
      id: 'rifugi_antiaerei',
      name: 'poi_rifugi_antiaerei_name',
      latitude: 44.13703,
      longitude: 12.23931,
      type: 'monument',
      period: '20th Century',
      description:
          'poi_rifugi_antiaerei_description',
      icon: Icons.safety_divider_outlined,
      iconBackground: Color(0xFFCFD8DC),
      questions: [
        QuizQuestion(
          question: 'quiz_rifugi_antiaerei_q1',
          options: [
            'quiz_rifugi_antiaerei_q1_o1',
            'quiz_rifugi_antiaerei_q1_o2',
            'quiz_rifugi_antiaerei_q1_o3',
          ],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'quiz_rifugi_antiaerei_q2',
          options: ['quiz_rifugi_antiaerei_q2_o1', 'quiz_rifugi_antiaerei_q2_o2', 'quiz_rifugi_antiaerei_q2_o3'],
          correctIndex: 1,
        ),
      ],
    ),
  ];
}
