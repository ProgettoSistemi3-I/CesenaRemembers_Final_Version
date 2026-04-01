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
    HistoricPlaceSeedItem(
      id: 'rocca',
      name: 'Rocca Malatestiana',
      latitude: 44.1441,
      longitude: 12.2428,
      type: 'monument',
      period: 'XIV sec.',
      description:
          'La Rocca Malatestiana è una fortezza medievale che domina il centro storico di Cesena. Costruita dai Malatesta nel 1380, ospita la Biblioteca Malatestiana, patrimonio UNESCO dal 2005.',
      icon: Icons.castle_outlined,
      iconBackground: Color(0xFFC8E6C9),
      questions: [
        QuizQuestion(
          question: 'Chi ha fatto costruire la Rocca?',
          options: ['I Visconti', 'I Malatesta', 'Federico da Montefeltro'],
          correctIndex: 1,
        ),
        QuizQuestion(
          question: 'In quale anno la Biblioteca è diventata patrimonio UNESCO?',
          options: ['1995', '2005', '2015'],
          correctIndex: 1,
        ),
      ],
    ),
    HistoricPlaceSeedItem(
      id: 'duomo',
      name: 'Cattedrale di S. Giovanni',
      latitude: 44.1435,
      longitude: 12.2442,
      type: 'church',
      period: 'XII sec.',
      description:
          'La cattedrale di San Giovanni Battista è il principale luogo di culto cattolico di Cesena. La facciata neoclassica cela un interno ricco di opere d\'arte dal Medioevo al Barocco.',
      icon: Icons.church_outlined,
      iconBackground: Color(0xFFFFECB3),
      questions: [
        QuizQuestion(
          question: 'A quale santo è dedicata la cattedrale?',
          options: ['San Pietro', 'San Giovanni Battista', 'San Francesco'],
          correctIndex: 1,
        ),
      ],
    ),
    HistoricPlaceSeedItem(
      id: 'piazza',
      name: 'Piazza del Popolo',
      latitude: 44.1438,
      longitude: 12.2455,
      type: 'square',
      period: 'Medioevo',
      description:
          'Il cuore pulsante di Cesena fin dal Medioevo. La piazza è dominata dal Palazzo del Ridotto e dalla fontana del Masini, punto di ritrovo storico per cesenati e visitatori.',
      icon: Icons.account_balance_outlined,
      iconBackground: Color(0xFFBBDEFB),
      questions: [
        QuizQuestion(
          question: 'Come si chiama la fontana in piazza?',
          options: [
            'Fontana di Nettuno',
            'Fontana del Masini',
            'Fontana dei Delfini',
          ],
          correctIndex: 1,
        ),
      ],
    ),
  ];
}
