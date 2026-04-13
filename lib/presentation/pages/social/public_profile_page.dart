import 'package:flutter/material.dart';

import '../../../domain/entities/userprofile.dart';
import '../../../domain/usecases/user_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/social_controller.dart';
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
    final profile = await sl<UserUseCases>().getUserProfile(widget.uid);
    if (mounted) {
      setState(() {
        _targetProfile = profile;
        _isLoading = false;
      });
    }
  }

  void _onFriendAction(String action) async {
    final myUid = _socialCtrl.currentUserId;

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

    // Chiamata backend tramite controller
    await _socialCtrl.handleFriendAction(action, widget.uid);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: theme.scaffoldBackgroundColor,
          elevation: 0,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    final profile = _targetProfile!;
    final avatar = avatarById(profile.avatarId);
    final myUid = _socialCtrl.currentUserId;

    // --- LOGICA STATO AMICIZIA ---
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
            // --- HERO CARD (Profilo e Azioni) ---
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

                  // --- BOTTONE AMICIZIA DINAMICO ---
                  if (myUid !=
                      profile
                          .uid) // Mostriamo i pulsanti solo se non è il proprio profilo
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
            Align(
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
                    'Statistiche',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // --- GRIGLIA STATISTICHE ---
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
                  'Risposte corrette',
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

  Widget _buildMiniStat(String label, String value, ThemeData theme) {
    return Column(
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
