import '../entities/userprofile.dart';
import '../repositories/user_repository.dart';

class UserUseCases {
  final IUserRepository repository;

  const UserUseCases(this.repository);

  // 1. Ottieni il profilo
  Future<UserProfile> getUserProfile(String uid) async {
    return await repository.getUserProfile(uid);
  }

  // 2. Aggiorna le preferenze
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    return await repository.updatePreferences(
      uid: uid,
      notifiche: notifiche,
      darkMode: darkMode,
      gps: gps,
    );
  }

  // 3. Segna un POI come visitato e aggiungi XP
  Future<void> markPoiAsVisited({
    required String uid,
    required String poiId,
    required int xpGained,
  }) async {
    return await repository.markPoiAsVisited(
      uid: uid,
      poiId: poiId,
      xpGained: xpGained,
    );
  }
  
}