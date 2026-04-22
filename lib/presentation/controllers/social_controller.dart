import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../domain/usecases/user_progress_use_cases.dart';
import '../../domain/usecases/user_social_use_cases.dart';

class LeaderboardEntry {
  final String uid;
  final String displayName;
  final String username;
  final String avatarId;
  final int xp;
  final int rank;

  const LeaderboardEntry({
    required this.uid,
    required this.displayName,
    required this.username,
    required this.avatarId,
    required this.xp,
    required this.rank,
  });

  factory LeaderboardEntry.fromMap(Map<String, dynamic> data, int rank) {
    return LeaderboardEntry(
      uid: data['uid'] as String,
      displayName: (data['displayName'] as String?)?.trim().isNotEmpty == true
          ? (data['displayName'] as String).trim()
          : 'Utente',
      username: (data['username'] as String?)?.trim() ?? '',
      avatarId: (data['avatarId'] as String?)?.trim().isNotEmpty == true
          ? (data['avatarId'] as String).trim()
          : 'military_tech',
      xp: (data['xp'] as num?)?.toInt() ?? 0,
      rank: rank,
    );
  }
}

class SocialController extends ChangeNotifier {
  SocialController({
    required UserProfileUseCases profileUseCases,
    required UserProgressUseCases progressUseCases,
    required UserSocialUseCases socialUseCases,
  }) : _profileUseCases = profileUseCases,
       _progressUseCases = progressUseCases,
       _socialUseCases = socialUseCases {
    _startLeaderboardListener();
  }

  final UserProfileUseCases _profileUseCases;
  final UserProgressUseCases _progressUseCases;
  final UserSocialUseCases _socialUseCases;
  StreamSubscription<List<Map<String, dynamic>>>? _leaderboardSub;
  Timer? _searchDebounce;
  bool _isDisposed = false;

  List<LeaderboardEntry> leaderboard = [];
  LeaderboardEntry? currentUserEntry;

  List<UserProfile> searchResults = [];
  bool isSearching = false;
  String? errorMessage;
  bool requiresMoreSearchChars = false;
  String _lastIssuedQuery = '';
  int _searchSequence = 0;

  // Esponiamo l'ID corrente alla UI senza usare FirebaseAuth
  String get currentUserId => _profileUseCases.getCurrentUserUid() ?? '';

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  void _startLeaderboardListener() {
    final myUid = _profileUseCases.getCurrentUserUid();

    _leaderboardSub = _progressUseCases
        .getLeaderboardStream(limit: 50)
        .listen(
          (docsData) {
            leaderboard = docsData
                .asMap()
                .entries
                .map((entry) {
                  return LeaderboardEntry.fromMap(entry.value, entry.key + 1);
                })
                .toList(growable: false);

            if (myUid != null) {
              try {
                currentUserEntry = leaderboard.firstWhere(
                  (e) => e.uid == myUid,
                );
              } catch (_) {
                currentUserEntry = null;
              }
            }

            _safeNotifyListeners();
          },
          onError: (error) {
            errorMessage = 'Impossibile caricare la classifica.';
            _safeNotifyListeners();
          },
        );
  }

  Future<void> search(String query) async {
    _searchDebounce?.cancel();
    final normalizedQuery = query.trim().toLowerCase();

    if (normalizedQuery.isEmpty || normalizedQuery.length < 2) {
      _lastIssuedQuery = '';
      searchResults = [];
      isSearching = false;
      errorMessage = null;
      requiresMoreSearchChars =
          normalizedQuery.isNotEmpty && normalizedQuery.length < 2;
      _safeNotifyListeners();
      return;
    }
    requiresMoreSearchChars = false;

    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (_isDisposed) return;
      if (normalizedQuery == _lastIssuedQuery) return;

      _lastIssuedQuery = normalizedQuery;
      isSearching = true;
      errorMessage = null;
      _safeNotifyListeners();

      final searchId = ++_searchSequence;
      try {
        final results = await _socialUseCases.searchUsers(normalizedQuery);
        if (_isDisposed || searchId != _searchSequence) return;
        searchResults = results;
      } catch (e) {
        if (_isDisposed || searchId != _searchSequence) return;
        errorMessage = 'Errore durante la ricerca.';
      } finally {
        if (_isDisposed || searchId != _searchSequence) return;
        isSearching = false;
        _safeNotifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _searchDebounce?.cancel();
    _leaderboardSub?.cancel();
    super.dispose();
  }

  Future<List<UserProfile>> loadUsersList(List<String> uids) async {
    if (uids.isEmpty) return [];
    return await _socialUseCases.getUsersByIds(uids);
  }

  Future<bool> handleFriendAction(String action, String targetUid) async {
    final cUid = currentUserId;
    if (cUid.isEmpty) return false;

    try {
      switch (action) {
        case 'send':
          await _socialUseCases.sendFriendRequest(cUid, targetUid);
          break;
        case 'cancel':
          await _socialUseCases.cancelFriendRequest(cUid, targetUid);
          break;
        case 'accept':
          await _socialUseCases.acceptFriendRequest(cUid, targetUid);
          break;
        case 'reject':
          await _socialUseCases.rejectFriendRequest(cUid, targetUid);
          break;
        case 'remove':
          await _socialUseCases.removeFriend(cUid, targetUid);
          break;
      }
      return true;
    } catch (e) {
      errorMessage = 'Errore durante l\'azione.';
      _safeNotifyListeners();
      return false;
    }
  }
}
