import 'package:flutter/material.dart';

import '../../../domain/entities/userprofile.dart';
import '../../../domain/usecases/user_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/social_controller.dart';
import '../../services/shell_navigation_store.dart'; // NUOVO IMPORT
import '../../theme/app_palette.dart';
import '../profile/avatar_catalog.dart';

class PublicProfilePage extends StatefulWidget {
  final String uid;
  final String fallbackName;
  final String fallbackUsername;

  const PublicProfilePage({
    super.key,
    required this.uid,
    required this.fallbackName,
    required this.fallbackUsername,
  });

  @override
  State<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends State<PublicProfilePage> {
  UserProfile? _targetProfile;
  bool _isLoading = true;
  late final SocialController _socialCtrl;

  @override
  void initState() {
    super.initState();
    _socialCtrl = sl<SocialController>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await sl<UserUseCases>().getUserProfile(widget.uid);
      if (mounted) {
        setState(() {
          _targetProfile = profile;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Errore nel caricamento del profilo.')),
        );
      }
    }
  }

  void _onFriendAction(String action) async {
    final myUid = _socialCtrl.currentUserId;
    if (_targetProfile == null) return;

    // Aggiornamento ottimistico della UI
    setState(() {
      if (action == 'send') {
        _targetProfile!.receivedFriendRequests.add(myUid);
      } else if (action == 'cancel') {
        _targetProfile!.receivedFriendRequests.remove(myUid);
      } else if (action == 'remove') {
        _targetProfile!.friends.remove(myUid);
      } else if (action == 'accept') {
        _targetProfile!.sentFriendRequests.remove(myUid);
        _targetProfile!.friends.add(myUid);
      } else if (action == 'reject') {
        _targetProfile!.sentFriendRequests.remove(myUid);
      }
    });

    await _socialCtrl.handleFriendAction(action, widget.uid);
  }

  // Visualizza la lista amici dell'utente
  void _showFriendsList(List<String> friendUids, ThemeData theme) async {
    final users = await _socialCtrl.loadUsersList(friendUids);
    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildUserListSheet(
        'Amici di ${_targetProfile!.displayName}',
        users,
        theme,
      ),
    );
  }

  Widget _buildUserListSheet(
    String title,
    List<UserProfile> users,
    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 10),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Nessun utente trovato.',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, i) {
                  final u = users[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppPalette.tan,
                      child: Icon(
                        avatarById(u.avatarId).icon,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ),
                    title: Text(
                      u.displayName,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '@${u.username}',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // Chiude la bottom sheet

                      // --- LA TUA LOGICA CORRETTA ---
                      if (u.uid == _socialCtrl.currentUserId) {
                        // Chiudiamo tutte le eventuali pagine pubbliche in sovraimpressione...
                        Navigator.of(
                          context,
                        ).popUntil((route) => route.isFirst);
                        // ...e cambiamo la tab in basso per mostrare il tuo profilo personale (indice 2)
                        ShellNavigationStore.goToTab(2);
                        return;
                      }

                      // Navigazione ricorsiva per gli ALTRI utenti
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PublicProfilePage(
                            uid: u.uid,
                            fallbackName: u.displayName,
                            fallbackUsername: u.username,
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),
        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    final profile = _targetProfile!;
    final avatar = avatarById(profile.avatarId);
    final myUid = _socialCtrl.currentUserId;

    bool isFriend = profile.friends.contains(myUid);
    bool requestSent = profile.receivedFriendRequests.contains(myUid);
    bool requestReceived = profile.sentFriendRequests.contains(myUid);

    final bestTourTimeLabel = profile.bestTourTimeSeconds > 0
        ? '${profile.bestTourTimeSeconds ~/ 60}m ${profile.bestTourTimeSeconds % 60}s'
        : '--';

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          widget.fallbackUsername.startsWith('@')
              ? widget.fallbackUsername
              : '@${widget.fallbackUsername}',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(
                      alpha: theme.brightness == Brightness.light ? 0.05 : 0.2,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppPalette.olive, AppPalette.tan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 52,
                      backgroundColor: avatar.background,
                      child: Icon(
                        avatar.icon,
                        size: 58,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profile.displayName,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '@${profile.username}',
                    style: TextStyle(
                      fontSize: 13,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottoni Amicizia
                  if (myUid != profile.uid)
                    if (isFriend)
                      OutlinedButton.icon(
                        onPressed: () => _onFriendAction('remove'),
                        icon: const Icon(
                          Icons.person_remove,
                          color: AppPalette.danger,
                          size: 18,
                        ),
                        label: const Text(
                          'Rimuovi amicizia',
                          style: TextStyle(color: AppPalette.danger),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppPalette.danger),
                        ),
                      )
                    else if (requestSent)
                      FilledButton.icon(
                        onPressed: () => _onFriendAction('cancel'),
                        icon: const Icon(
                          Icons.how_to_reg,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Richiesta inviata',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.tan,
                        ),
                      )
                    else if (requestReceived)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton(
                            onPressed: () => _onFriendAction('accept'),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppPalette.olive,
                            ),
                            child: const Text('Accetta'),
                          ),
                          const SizedBox(width: 10),
                          OutlinedButton(
                            onPressed: () => _onFriendAction('reject'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.danger,
                              side: const BorderSide(color: AppPalette.danger),
                            ),
                            child: const Text('Rifiuta'),
                          ),
                        ],
                      )
                    else
                      FilledButton.icon(
                        onPressed: () => _onFriendAction('send'),
                        icon: const Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: 18,
                        ),
                        label: const Text(
                          'Invia richiesta',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppPalette.olive,
                        ),
                      ),

                  const SizedBox(height: 18),
                  Container(
                    height: 1,
                    color: theme.colorScheme.surfaceContainerHighest.withValues(
                      alpha: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildMiniStat(
                        'Amici',
                        profile.friends.length.toString(),
                        theme,
                        onTap: isFriend
                            ? () => _showFriendsList(profile.friends, theme)
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Devi essere amico per vedere la sua lista amici.',
                                    ),
                                  ),
                                );
                              },
                      ),
                      Container(
                        height: 28,
                        width: 1,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      _buildMiniStat('Punti', profile.xp.toString(), theme),
                      Container(
                        height: 28,
                        width: 1,
                        color: theme.colorScheme.surfaceContainerHighest,
                      ),
                      _buildMiniStat(
                        'Livello',
                        profile.level.toString(),
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),
            const _SectionLabel('Statistiche'),
            const SizedBox(height: 14),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.55,
              children: [
                _buildStatCard(
                  'Traguardi',
                  '${profile.achievementsCount}',
                  Icons.verified_user_outlined,
                  AppPalette.olive,
                  theme,
                ),
                _buildStatCard(
                  'Miglior punteggio',
                  '${profile.maxQuizScore}%',
                  Icons.speed_outlined,
                  AppPalette.tan,
                  theme,
                ),
                _buildStatCard(
                  'Siti Visitati',
                  '${profile.visitedCount}',
                  Icons.location_on_outlined,
                  AppPalette.moss,
                  theme,
                ),
                _buildStatCard(
                  'Quiz Superati',
                  '${profile.totalQuizCompleted}',
                  Icons.quiz_outlined,
                  AppPalette.tan,
                  theme,
                ),
                _buildStatCard(
                  'Miglior tempo',
                  bestTourTimeLabel,
                  Icons.timer_outlined,
                  AppPalette.olive,
                  theme,
                ),
                _buildStatCard(
                  'Risposte esatte',
                  '${profile.totalCorrectAnswers}',
                  Icons.check_circle_outline,
                  AppPalette.moss,
                  theme,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    ThemeData theme, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppPalette.olive,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: theme.brightness == Brightness.light ? 0.04 : 0.15,
            ),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppPalette.olive,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
