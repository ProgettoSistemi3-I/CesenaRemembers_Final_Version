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
  final List<String> friends;
  final List<String> sentFriendRequests;
  final List<String> receivedFriendRequests;

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
    this.friends = const [],
    this.sentFriendRequests = const [],
    this.receivedFriendRequests = const [],
  });

  // Getter comodi per la UI
  int get visitedCount => visitedPoiIds.length;
  int get achievementsCount => unlockedAchievements.length;
  int get level => (xp ~/ 250) + 1;

  // METODO AGGIUNTO: Permette di clonare l'oggetto modificando solo i campi necessari
  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? avatarId,
    bool? profileCompleted,
    int? xp,
    List<String>? visitedPoiIds,
    List<String>? unlockedAchievements,
    bool? notificheEnabled,
    bool? darkModeEnabled,
    bool? gpsEnabled,
    int? maxQuizScore,
    int? totalQuizCompleted,
    int? totalCorrectAnswers,
    int? bestTourTimeSeconds,
    List<String>? friends,
    List<String>? sentFriendRequests,
    List<String>? receivedFriendRequests,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      xp: xp ?? this.xp,
      visitedPoiIds: visitedPoiIds ?? this.visitedPoiIds,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      notificheEnabled: notificheEnabled ?? this.notificheEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      maxQuizScore: maxQuizScore ?? this.maxQuizScore,
      totalQuizCompleted: totalQuizCompleted ?? this.totalQuizCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      bestTourTimeSeconds: bestTourTimeSeconds ?? this.bestTourTimeSeconds,
      friends: friends ?? this.friends,
      sentFriendRequests: sentFriendRequests ?? this.sentFriendRequests,
      receivedFriendRequests:
          receivedFriendRequests ?? this.receivedFriendRequests,
    );
  }
}
