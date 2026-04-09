class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String avatarId;
  final bool profileCompleted;
  final int xp;
  final List<String> visitedPoiIds;
  final List<String> unlockedAchievements;
  final bool notificheEnabled;
  final bool darkModeEnabled;
  final bool gpsEnabled;
  final int maxQuizScore;
  final int totalQuizCompleted;
  final int totalCorrectAnswers;
  final int bestTourTimeSeconds;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username = '',
    this.avatarId = 'military_tech',
    this.profileCompleted = false,
    this.xp = 0,
    this.visitedPoiIds = const [],
    this.unlockedAchievements = const [],
    this.notificheEnabled = true,
    this.darkModeEnabled = false,
    this.gpsEnabled = true,
    this.maxQuizScore = 0,
    this.totalQuizCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.bestTourTimeSeconds = 0,
  });

  // Getter comodi per la UI
  int get visitedCount => visitedPoiIds.length;
  int get achievementsCount => unlockedAchievements.length;
  int get level => (xp ~/ 250) + 1;
}
