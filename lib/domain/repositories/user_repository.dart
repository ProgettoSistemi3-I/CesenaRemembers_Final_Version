import '../entities/userprofile.dart';

abstract class IUserRepository {
  // Recupera il profilo. Se non esiste (primo login), dovrebbe crearlo.
  Future<UserProfile> getUserProfile(String uid);
  
  // Aggiorna le preferenze dalla pagina Settings
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  });

  // Aggiunge un POI alla lista dei visitati e aggiorna gli XP
  Future<void> markPoiAsVisited({
    required String uid, 
    required String poiId, 
    required int xpGained
  });
}