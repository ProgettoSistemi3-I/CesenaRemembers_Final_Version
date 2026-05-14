import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';

extension AppLocalizationsExtensions on AppLocalizations {
  String _normalizePoiIdentifier(String raw) {
    if (raw.startsWith('poi_') && raw.endsWith('_name')) {
      return raw.substring(4, raw.length - 5);
    }
    return raw;
  }

  String achievementTitle(String id) {
    switch (id) {
      case 'first_visit':
        return achievement_first_visit_title;
      case 'first_quiz':
        return achievement_first_quiz_title;
      case 'first_tour':
        return achievement_first_tour_title;
      case 'quiz_15':
        return achievement_quiz_15_title;
      case 'perfect_tour':
        return achievement_perfect_tour_title;
      case 'xp_500':
        return achievement_xp_500_title;
      case 'tour_under_1h':
        return achievement_tour_under_1h_title;
      case 'tour_under_30m':
        return achievement_tour_under_30m_title;
      case 'friend_1':
        return achievement_friend_1_title;
      case 'friend_5':
        return achievement_friend_5_title;
      default:
        return id;
    }
  }

  String getPoiName(String id) {
    final normalizedId = _normalizePoiIdentifier(id);
    switch (normalizedId) {
      case 'santa_cristina':
        return poi_santa_cristina_name;
      case 'rocca':
        return poi_rocca_name;
      case 'san_rocco':
        return poi_san_rocco_name;
      case 'abbazia_monte':
        return poi_abbazia_monte_name;
      case 'osservanza':
        return poi_osservanza_name;
      case 'palazzo_ridotto':
        return poi_palazzo_ridotto_name;
      case 'stazione':
        return poi_stazione_name;
      case 'arrigoni':
        return poi_arrigoni_name;
      case 'fantaguzzi':
        return poi_fantaguzzi_name;
      case 'rifugi_antiaerei':
        return poi_rifugi_antiaerei_name;
      default:
        return id;
    }
  }

  String getPoiDescription(String id) {
    final normalizedId = _normalizePoiIdentifier(id);
    switch (normalizedId) {
      case 'santa_cristina':
        return poi_santa_cristina_desc;
      case 'rocca':
        return poi_rocca_desc;
      case 'san_rocco':
        return poi_san_rocco_desc;
      case 'abbazia_monte':
        return poi_abbazia_monte_desc;
      case 'osservanza':
        return poi_osservanza_desc;
      case 'palazzo_ridotto':
        return poi_palazzo_ridotto_desc;
      case 'stazione':
        return poi_stazione_desc;
      case 'arrigoni':
        return poi_arrigoni_desc;
      case 'fantaguzzi':
        return poi_fantaguzzi_desc;
      case 'rifugi_antiaerei':
        return poi_rifugi_antiaerei_desc;
      default:
        return '';
    }
  }

  String achievementDescription(String id) {
    switch (id) {
      case 'first_visit':
        return achievement_first_visit_desc;
      case 'first_quiz':
        return achievement_first_quiz_desc;
      case 'first_tour':
        return achievement_first_tour_desc;
      case 'quiz_15':
        return achievement_quiz_15_desc;
      case 'perfect_tour':
        return achievement_perfect_tour_desc;
      case 'xp_500':
        return achievement_xp_500_desc;
      case 'tour_under_1h':
        return achievement_tour_under_1h_desc;
      case 'tour_under_30m':
        return achievement_tour_under_30m_desc;
      case 'friend_1':
        return achievement_friend_1_desc;
      case 'friend_5':
        return achievement_friend_5_desc;
      default:
        return '';
    }
  }

  /// Restituisce la stringa tradotta per i quiz (fallback locali).
  /// Se [key] non è una chiave nota (es. quiz generato dall'API), la restituisce così com'è.
  String getQuizString(String key) {
    switch (key) {
      case 'quiz_fallback_name':
        return quiz_fallback_name;
      case 'quiz_fallback_desc':
        return quiz_fallback_desc;
      case 'quiz_santa_cristina_q1':
        return quiz_santa_cristina_q1;
      case 'quiz_santa_cristina_q1_o1':
        return quiz_santa_cristina_q1_o1;
      case 'quiz_santa_cristina_q1_o2':
        return quiz_santa_cristina_q1_o2;
      case 'quiz_santa_cristina_q1_o3':
        return quiz_santa_cristina_q1_o3;
      case 'quiz_santa_cristina_q2':
        return quiz_santa_cristina_q2;
      case 'quiz_santa_cristina_q2_o1':
        return quiz_santa_cristina_q2_o1;
      case 'quiz_santa_cristina_q2_o2':
        return quiz_santa_cristina_q2_o2;
      case 'quiz_santa_cristina_q2_o3':
        return quiz_santa_cristina_q2_o3;
      case 'quiz_rocca_q1':
        return quiz_rocca_q1;
      case 'quiz_rocca_q1_o1':
        return quiz_rocca_q1_o1;
      case 'quiz_rocca_q1_o2':
        return quiz_rocca_q1_o2;
      case 'quiz_rocca_q1_o3':
        return quiz_rocca_q1_o3;
      case 'quiz_rocca_q2':
        return quiz_rocca_q2;
      case 'quiz_rocca_q2_o1':
        return quiz_rocca_q2_o1;
      case 'quiz_rocca_q2_o2':
        return quiz_rocca_q2_o2;
      case 'quiz_rocca_q2_o3':
        return quiz_rocca_q2_o3;
      case 'quiz_rocca_q3':
        return quiz_rocca_q3;
      case 'quiz_rocca_q3_o1':
        return quiz_rocca_q3_o1;
      case 'quiz_rocca_q3_o2':
        return quiz_rocca_q3_o2;
      case 'quiz_rocca_q3_o3':
        return quiz_rocca_q3_o3;
      case 'quiz_san_rocco_q1':
        return quiz_san_rocco_q1;
      case 'quiz_san_rocco_q1_o1':
        return quiz_san_rocco_q1_o1;
      case 'quiz_san_rocco_q1_o2':
        return quiz_san_rocco_q1_o2;
      case 'quiz_san_rocco_q1_o3':
        return quiz_san_rocco_q1_o3;
      case 'quiz_san_rocco_q2':
        return quiz_san_rocco_q2;
      case 'quiz_san_rocco_q2_o1':
        return quiz_san_rocco_q2_o1;
      case 'quiz_san_rocco_q2_o2':
        return quiz_san_rocco_q2_o2;
      case 'quiz_san_rocco_q2_o3':
        return quiz_san_rocco_q2_o3;
      case 'quiz_abbazia_monte_q1':
        return quiz_abbazia_monte_q1;
      case 'quiz_abbazia_monte_q1_o1':
        return quiz_abbazia_monte_q1_o1;
      case 'quiz_abbazia_monte_q1_o2':
        return quiz_abbazia_monte_q1_o2;
      case 'quiz_abbazia_monte_q1_o3':
        return quiz_abbazia_monte_q1_o3;
      case 'quiz_abbazia_monte_q2':
        return quiz_abbazia_monte_q2;
      case 'quiz_abbazia_monte_q2_o1':
        return quiz_abbazia_monte_q2_o1;
      case 'quiz_abbazia_monte_q2_o2':
        return quiz_abbazia_monte_q2_o2;
      case 'quiz_abbazia_monte_q2_o3':
        return quiz_abbazia_monte_q2_o3;
      case 'quiz_osservanza_q1':
        return quiz_osservanza_q1;
      case 'quiz_osservanza_q1_o1':
        return quiz_osservanza_q1_o1;
      case 'quiz_osservanza_q1_o2':
        return quiz_osservanza_q1_o2;
      case 'quiz_osservanza_q1_o3':
        return quiz_osservanza_q1_o3;
      case 'quiz_osservanza_q2':
        return quiz_osservanza_q2;
      case 'quiz_osservanza_q2_o1':
        return quiz_osservanza_q2_o1;
      case 'quiz_osservanza_q2_o2':
        return quiz_osservanza_q2_o2;
      case 'quiz_osservanza_q2_o3':
        return quiz_osservanza_q2_o3;
      case 'quiz_palazzo_ridotto_q1':
        return quiz_palazzo_ridotto_q1;
      case 'quiz_palazzo_ridotto_q1_o1':
        return quiz_palazzo_ridotto_q1_o1;
      case 'quiz_palazzo_ridotto_q1_o2':
        return quiz_palazzo_ridotto_q1_o2;
      case 'quiz_palazzo_ridotto_q1_o3':
        return quiz_palazzo_ridotto_q1_o3;
      case 'quiz_palazzo_ridotto_q2':
        return quiz_palazzo_ridotto_q2;
      case 'quiz_palazzo_ridotto_q2_o1':
        return quiz_palazzo_ridotto_q2_o1;
      case 'quiz_palazzo_ridotto_q2_o2':
        return quiz_palazzo_ridotto_q2_o2;
      case 'quiz_palazzo_ridotto_q2_o3':
        return quiz_palazzo_ridotto_q2_o3;
      case 'quiz_stazione_q1':
        return quiz_stazione_q1;
      case 'quiz_stazione_q1_o1':
        return quiz_stazione_q1_o1;
      case 'quiz_stazione_q1_o2':
        return quiz_stazione_q1_o2;
      case 'quiz_stazione_q1_o3':
        return quiz_stazione_q1_o3;
      case 'quiz_stazione_q2':
        return quiz_stazione_q2;
      case 'quiz_stazione_q2_o1':
        return quiz_stazione_q2_o1;
      case 'quiz_stazione_q2_o2':
        return quiz_stazione_q2_o2;
      case 'quiz_stazione_q2_o3':
        return quiz_stazione_q2_o3;
      case 'quiz_arrigoni_q1':
        return quiz_arrigoni_q1;
      case 'quiz_arrigoni_q1_o1':
        return quiz_arrigoni_q1_o1;
      case 'quiz_arrigoni_q1_o2':
        return quiz_arrigoni_q1_o2;
      case 'quiz_arrigoni_q1_o3':
        return quiz_arrigoni_q1_o3;
      case 'quiz_arrigoni_q2':
        return quiz_arrigoni_q2;
      case 'quiz_arrigoni_q2_o1':
        return quiz_arrigoni_q2_o1;
      case 'quiz_arrigoni_q2_o2':
        return quiz_arrigoni_q2_o2;
      case 'quiz_arrigoni_q2_o3':
        return quiz_arrigoni_q2_o3;
      case 'quiz_fantaguzzi_q1':
        return quiz_fantaguzzi_q1;
      case 'quiz_fantaguzzi_q1_o1':
        return quiz_fantaguzzi_q1_o1;
      case 'quiz_fantaguzzi_q1_o2':
        return quiz_fantaguzzi_q1_o2;
      case 'quiz_fantaguzzi_q1_o3':
        return quiz_fantaguzzi_q1_o3;
      case 'quiz_fantaguzzi_q2':
        return quiz_fantaguzzi_q2;
      case 'quiz_fantaguzzi_q2_o1':
        return quiz_fantaguzzi_q2_o1;
      case 'quiz_fantaguzzi_q2_o2':
        return quiz_fantaguzzi_q2_o2;
      case 'quiz_fantaguzzi_q2_o3':
        return quiz_fantaguzzi_q2_o3;
      case 'quiz_rifugi_antiaerei_q1':
        return quiz_rifugi_antiaerei_q1;
      case 'quiz_rifugi_antiaerei_q1_o1':
        return quiz_rifugi_antiaerei_q1_o1;
      case 'quiz_rifugi_antiaerei_q1_o2':
        return quiz_rifugi_antiaerei_q1_o2;
      case 'quiz_rifugi_antiaerei_q1_o3':
        return quiz_rifugi_antiaerei_q1_o3;
      case 'quiz_rifugi_antiaerei_q2':
        return quiz_rifugi_antiaerei_q2;
      case 'quiz_rifugi_antiaerei_q2_o1':
        return quiz_rifugi_antiaerei_q2_o1;
      case 'quiz_rifugi_antiaerei_q2_o2':
        return quiz_rifugi_antiaerei_q2_o2;
      case 'quiz_rifugi_antiaerei_q2_o3':
        return quiz_rifugi_antiaerei_q2_o3;
      default:
        return key; // Se non è una chiave, restituisci la stringa così com'è (API)
    }
  }
}
