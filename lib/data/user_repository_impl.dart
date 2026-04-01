import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/repositories/user_repository.dart';
import '../models/user_model.dart';

class UserRepositoryImpl implements IUserRepository {
  final FirebaseFirestore firestore;

  UserRepositoryImpl({required this.firestore});

  @override
  Future<UserProfile> getUserProfile(String uid) async {
    final docRef = firestore.collection('users').doc(uid);
    final snapshot = await docRef.get();

    if (snapshot.exists && snapshot.data() != null) {
      // L'utente esiste, restituiamo i suoi dati
      return UserModel.fromJson(snapshot.data()!, snapshot.id);
    } else {
      // È il primo login! Creiamo un profilo base sul momento
      final newUser = UserModel(
        uid: uid,
        email: '', // Idealmente dovresti passarla, ma la gestiamo basica per ora
        displayName: 'Nuovo Utente',
      );
      await docRef.set(newUser.toJson());
      return newUser;
    }
  }

  @override
  Future<void> updatePreferences({
    required String uid,
    bool? notifiche,
    bool? darkMode,
    bool? gps,
  }) async {
    final Map<String, dynamic> updates = {};
    
    // Aggiorniamo solo i campi che ci vengono passati
    if (notifiche != null) updates['preferences.notifiche'] = notifiche;
    if (darkMode != null) updates['preferences.modalitaNotte'] = darkMode;
    if (gps != null) updates['preferences.posizioneGps'] = gps;

    if (updates.isNotEmpty) {
      await firestore.collection('users').doc(uid).update(updates);
    }
  }

  @override
  Future<void> markPoiAsVisited({
    required String uid,
    required String poiId,
    required int xpGained,
  }) async {
    // Usiamo FieldValue per operazioni atomiche sicure
    // Questo previene bug se l'utente clicca molto velocemente
    await firestore.collection('users').doc(uid).update({
      'visitedPoiIds': FieldValue.arrayUnion([poiId]),
      'xp': FieldValue.increment(xpGained),
    });
  }
}