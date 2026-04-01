class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final int xp;
  final List<String> visitedPoiIds;
  final List<String> unlockedAchievements;
  final bool notificheEnabled;
  final bool darkModeEnabled;
  final bool gpsEnabled;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.xp = 0,
    this.visitedPoiIds = const [],
    this.unlockedAchievements = const [],
    this.notificheEnabled = true,
    this.darkModeEnabled = false,
    this.gpsEnabled = true,
  });

  // Getter comodi per la UI
  int get visitedCount => visitedPoiIds.length;
  int get achievementsCount => unlockedAchievements.length;
}