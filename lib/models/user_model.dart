import '../domain/entities/userprofile.dart';

class UserModel extends UserProfile {
  UserModel({
    required super.uid,
    required super.email,
    required super.displayName,
    super.username,
    super.avatarId,
    super.profileCompleted,
    super.xp,
    super.visitedPoiIds,
    super.unlockedAchievements,
    super.notificheEnabled,
    super.darkModeEnabled,
    super.gpsEnabled,
    super.maxQuizScore,
    super.totalQuizCompleted,
    super.totalCorrectAnswers,
    super.bestTourTimeSeconds,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String documentId) {
    return UserModel(
      uid: documentId,
      email: json['email'] ?? '',
      displayName: json['displayName'] ?? 'Utente',
      username: json['username'] ?? '',
      avatarId: json['avatarId'] ?? 'military_tech',
      profileCompleted: json['profileCompleted'] ?? false,
      xp: json['xp'] ?? 0,
      visitedPoiIds: List<String>.from(json['visitedPoiIds'] ?? []),
      unlockedAchievements: List<String>.from(json['unlockedAchievements'] ?? []),
      notificheEnabled: json['preferences']?['notifiche'] ?? true,
      darkModeEnabled: json['preferences']?['modalitaNotte'] ?? false,
      gpsEnabled: json['preferences']?['posizioneGps'] ?? true,
      maxQuizScore: json['maxQuizScore'] ?? 0,
      totalQuizCompleted: json['totalQuizCompleted'] ?? 0,
      totalCorrectAnswers: json['totalCorrectAnswers'] ?? 0,
      bestTourTimeSeconds: json['bestTourTimeSeconds'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'displayName': displayName,
      'username': username,
      'usernameNormalized': username.toLowerCase(),
      'avatarId': avatarId,
      'profileCompleted': profileCompleted,
      'xp': xp,
      'leaderboardScore': xp,
      'visitedPoiIds': visitedPoiIds,
      'unlockedAchievements': unlockedAchievements,
      'maxQuizScore': maxQuizScore,
      'totalQuizCompleted': totalQuizCompleted,
      'totalCorrectAnswers': totalCorrectAnswers,
      'bestTourTimeSeconds': bestTourTimeSeconds,
      'preferences': {
        'notifiche': notificheEnabled,
        'modalitaNotte': darkModeEnabled,
        'posizioneGps': gpsEnabled,
      }
    };
  }
}
