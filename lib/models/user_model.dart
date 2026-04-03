import '../domain/entities/userprofile.dart';

class UserModel extends UserProfile {
  UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.xp,
    super.visitedPoiIds,
    super.unlockedAchievements,
    super.notificheEnabled,
    super.darkModeEnabled,
    super.gpsEnabled,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      uid: documentId,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Utente',
      xp: json['xp'] ?? 0,
      visitedPoiIds: List<String>.from(json['visitedPoiIds'] ?? []),
      unlockedAchievements: List<String>.from(
        json['unlockedAchievements'] ?? [],
      ),
      notificheEnabled: json['preferences']?['notifiche'] ?? true,
      darkModeEnabled: json['preferences']?['modalitaNotte'] ?? false,
      gpsEnabled: json['preferences']?['posizioneGps'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'xp': xp,
      'visitedPoiIds': visitedPoiIds,
      'unlockedAchievements': unlockedAchievements,
      'preferences': {
        'notifiche': notificheEnabled,
        'modalitaNotte': darkModeEnabled,
        'posizioneGps': gpsEnabled,
      },
    };
  }
}
