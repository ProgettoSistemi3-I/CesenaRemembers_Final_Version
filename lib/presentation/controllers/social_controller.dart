import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_use_cases.dart';

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
  final UserUseCases _userUseCases;
  StreamSubscription<List<Map<String, dynamic>>>? _leaderboardSub;
  bool _isDisposed = false;

  List<LeaderboardEntry> leaderboard = [];
  LeaderboardEntry? currentUserEntry;

  List<UserProfile> searchResults = [];
  bool isSearching = false;
  String? errorMessage;

  // Esponiamo l'ID corrente alla UI senza usare FirebaseAuth
  String get currentUserId => _userUseCases.getCurrentUserUid() ?? '';

  SocialController({required UserUseCases userUseCases})
    : _userUseCases = userUseCases {
    _startLeaderboardListener();
  }

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  void _startLeaderboardListener() {
    final myUid = _userUseCases.getCurrentUserUid();

    _leaderboardSub = _userUseCases
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
    if (query.trim().isEmpty) {
      searchResults = [];
      _safeNotifyListeners();
      return;
    }

    isSearching = true;
    errorMessage = null;
    _safeNotifyListeners();

    try {
      searchResults = await _userUseCases.searchUsers(query);
    } catch (e) {
      errorMessage = 'Errore durante la ricerca.';
    } finally {
      isSearching = false;
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _leaderboardSub?.cancel();
    super.dispose();
  }

  Future<List<UserProfile>> loadUsersList(List<String> uids) async {
    if (uids.isEmpty) return [];
    return await _userUseCases.getUsersByIds(uids);
  }

  Future<void> handleFriendAction(String action, String targetUid) async {
    final cUid = currentUserId;
    if (cUid.isEmpty) return;

    try {
      switch (action) {
        case 'send':
          await _userUseCases.sendFriendRequest(cUid, targetUid);
          break;
        case 'cancel':
          await _userUseCases.cancelFriendRequest(cUid, targetUid);
          break;
        case 'accept':
          await _userUseCases.acceptFriendRequest(cUid, targetUid);
          break;
        case 'reject':
          await _userUseCases.rejectFriendRequest(cUid, targetUid);
          break;
        case 'remove':
          await _userUseCases.removeFriend(cUid, targetUid);
          break;
      }
    } catch (e) {
      errorMessage = 'Errore durante l\'azione.';
      _safeNotifyListeners();
    }
  }
}
