import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../domain/entities/quiz_question.dart';
import '../../../domain/entities/tour_stop.dart';

class TourStopsSeed {
  const TourStopsSeed._();

  static const List<TourStop> cesena = [
    TourStop(
      id: 'rocca',
      name: 'Rocca Malatestiana',
      period: 'XIV sec.',
      description:
          'La Rocca Malatestiana è una fortezza medievale che domina il centro storico di Cesena. Costruita dai Malatesta nel 1380, ospita la Biblioteca Malatestiana, patrimonio UNESCO dal 2005.',
      position: LatLng(44.1441, 12.2428),
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
              'In quale anno la Biblioteca è diventata patrimonio UNESCO?',
          options: ['1995', '2005', '2015'],
          correctIndex: 1,
        ),
      ],
    ),
    TourStop(
      id: 'duomo',
      name: 'Cattedrale di S. Giovanni',
      period: 'XII sec.',
      description:
          'La cattedrale di San Giovanni Battista è il principale luogo di culto cattolico di Cesena. La facciata neoclassica cela un interno ricco di opere d\'arte dal Medioevo al Barocco.',
      position: LatLng(44.1435, 12.2442),
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
    TourStop(
      id: 'piazza',
      name: 'Piazza del Popolo',
      period: 'Medioevo',
      description:
          'Il cuore pulsante di Cesena fin dal Medioevo. La piazza è dominata dal Palazzo del Ridotto e dalla fontana del Masini, punto di ritrovo storico per cesenati e visitatori.',
      position: LatLng(44.1438, 12.2455),
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
