class UserProfile {
  final String uid;
  final String email;
  final String displayName;
  final String username;
  final String avatarId;
  final bool profileCompleted;
  final bool onboardingCompleted;
  final int xp;
  final List<String> visitedPoiIds;
  final List<String> unlockedAchievements;
  final List<String> pendingAchievements;
  final bool notificheEnabled;
  final bool darkModeEnabled;
  final bool gpsEnabled;
  final int maxQuizScore;
  final int totalQuizCompleted;
  final int totalToursCompleted;
  final int totalCorrectAnswers;
  final int bestTourTimeSeconds;
  final int maxSingleTourXp;
  final List<String> friends;
  final List<String> sentFriendRequests;
  final List<String> receivedFriendRequests;
  final List<String> fcmTokens;

  UserProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.username = '',
    this.avatarId = 'soldier',
    this.profileCompleted = false,
    this.onboardingCompleted = false,
    this.xp = 0,
    this.visitedPoiIds = const [],
    this.unlockedAchievements = const [],
    this.pendingAchievements = const [],
    this.notificheEnabled = true,
    this.darkModeEnabled = false,
    this.gpsEnabled = true,
    this.maxQuizScore = 0,
    this.totalQuizCompleted = 0,
    this.totalToursCompleted = 0,
    this.totalCorrectAnswers = 0,
    this.bestTourTimeSeconds = 0,
    this.maxSingleTourXp = 0,
    this.friends = const [],
    this.sentFriendRequests = const [],
    this.receivedFriendRequests = const [],
    this.fcmTokens = const [],
  });

  // Getter comodi per la UI
  int get visitedCount => visitedPoiIds.length;
  int get achievementsCount => unlockedAchievements.length;
  int get pendingAchievementsCount => pendingAchievements.length;
  int get level => (xp ~/ 250) + 1;

  UserProfile copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? username,
    String? avatarId,
    bool? profileCompleted,
    bool? onboardingCompleted,
    int? xp,
    List<String>? visitedPoiIds,
    List<String>? unlockedAchievements,
    List<String>? pendingAchievements,
    bool? notificheEnabled,
    bool? darkModeEnabled,
    bool? gpsEnabled,
    int? maxQuizScore,
    int? totalQuizCompleted,
    int? totalToursCompleted,
    int? totalCorrectAnswers,
    int? bestTourTimeSeconds,
    int? maxSingleTourXp,
    List<String>? friends,
    List<String>? sentFriendRequests,
    List<String>? receivedFriendRequests,
    List<String>? fcmTokens,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      avatarId: avatarId ?? this.avatarId,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      xp: xp ?? this.xp,
      visitedPoiIds: visitedPoiIds ?? this.visitedPoiIds,
      unlockedAchievements: unlockedAchievements ?? this.unlockedAchievements,
      pendingAchievements: pendingAchievements ?? this.pendingAchievements,
      notificheEnabled: notificheEnabled ?? this.notificheEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      gpsEnabled: gpsEnabled ?? this.gpsEnabled,
      maxQuizScore: maxQuizScore ?? this.maxQuizScore,
      totalQuizCompleted: totalQuizCompleted ?? this.totalQuizCompleted,
      totalToursCompleted: totalToursCompleted ?? this.totalToursCompleted,
      totalCorrectAnswers: totalCorrectAnswers ?? this.totalCorrectAnswers,
      bestTourTimeSeconds: bestTourTimeSeconds ?? this.bestTourTimeSeconds,
      maxSingleTourXp: maxSingleTourXp ?? this.maxSingleTourXp,
      friends: friends ?? this.friends,
      sentFriendRequests: sentFriendRequests ?? this.sentFriendRequests,
      receivedFriendRequests:
          receivedFriendRequests ?? this.receivedFriendRequests,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}

