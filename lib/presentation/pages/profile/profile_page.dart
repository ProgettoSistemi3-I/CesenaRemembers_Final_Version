import 'package:flutter/material.dart';

import '../../../domain/entities/userprofile.dart';
import '../../../domain/validation/profile_validation.dart';
import '../../../injection_container.dart';
import '../../controllers/profile_controller.dart';
import '../../theme/app_palette.dart'; // Import vitale per i colori base (olive, tan)
import 'avatar_catalog.dart';

part 'profile_page_sections.dart';

// ─────────────────────────────────────────────
//  Page
// ─────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _selectedAvatarIndex = 1;

  bool _isEditingName = false;
  bool _isSavingBasics = false;
  final TextEditingController _nameController = TextEditingController();

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fadeAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOut,
    ).drive(Tween(begin: 0.0, end: 1.0));
    _slideAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: Curves.easeOutCubic,
    ).drive(Tween(begin: const Offset(0, 0.06), end: Offset.zero));
    _animCtrl.forward();
    _profileController = ProfileController(userUseCases: sl());
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _profileController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Avatar picker ─────────────────────────
  Future<void> _showAvatarPicker() async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor:
          theme.colorScheme.surface, // ADATTIVO: Sostituito _warmWhite
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AvatarPickerSheet(
        selected: _selectedAvatarIndex,
        onSelect: (i) => setState(() => _selectedAvatarIndex = i),
      ),
    );
  }

  Future<void> _toggleNameEdit(UserProfile profile) async {
    if (_isEditingName) {
      await _saveProfileBasics(profile);
    }
    setState(() => _isEditingName = !_isEditingName);
  }

  Future<void> _saveProfileBasics(UserProfile profile) async {
    final updatedName = _nameController.text.trim();
    final selectedAvatarId = avatarOptions[_selectedAvatarIndex].id;

    if (updatedName.isEmpty) {
      setState(() => _nameController.text = profile.displayName);
      return;
    }
    if (!ProfileValidation.isValidDisplayName(updatedName)) {
      _profileController.errorMessage =
          'Il nome in app deve avere ${ProfileValidation.minDisplayNameLength}-${ProfileValidation.maxDisplayNameLength} caratteri.';
      _profileController.notifyListeners();
      setState(() => _nameController.text = profile.displayName);
      return;
    }

    final shouldUpdateName = updatedName != profile.displayName;
    final shouldUpdateAvatar = selectedAvatarId != profile.avatarId;

    if (!shouldUpdateName && !shouldUpdateAvatar) return;

    setState(() => _isSavingBasics = true);
    try {
      await _profileController.updateProfileBasics(
        displayName: shouldUpdateName ? updatedName : null,
        avatarId: shouldUpdateAvatar ? selectedAvatarId : null,
      );
    } finally {
      if (mounted) setState(() => _isSavingBasics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // TEMA ADATTIVO
    return Scaffold(
      backgroundColor:
          theme.scaffoldBackgroundColor, // ADATTIVO: Sostituito _cream
      body: AnimatedBuilder(
        animation: _profileController,
        builder: (context, _) {
          if (_profileController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.olive),
            );
          }

          final dynamicProfile = _profileController.profile;
          final profile = dynamicProfile ?? _buildFallbackProfile();
          final selected = avatarById(profile.avatarId);
          final selectedIndex = avatarOptions.indexWhere(
            (option) => option.id == profile.avatarId,
          );
          if (selectedIndex >= 0 && selectedIndex != _selectedAvatarIndex) {
            _selectedAvatarIndex = selectedIndex;
          }
          if (!_isEditingName && _nameController.text != profile.displayName) {
            _nameController.text = profile.displayName;
          }
          final pointsLabel = _formatPoints(profile.xp);
          final bestScoreLabel = '${profile.maxQuizScore}%';
          final bestTourTimeLabel = profile.bestTourTimeSeconds > 0
              ? _formatDuration(profile.bestTourTimeSeconds)
              : '--';

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  // ── App bar
                  SliverAppBar(
                    backgroundColor: theme
                        .scaffoldBackgroundColor, // ADATTIVO: Sostituito _cream
                    elevation: 0,
                    expandedHeight: 0,
                    floating: true,
                    snap: true,
                    title: Text(
                      'Il mio profilo',
                      style: TextStyle(
                        color: theme
                            .colorScheme
                            .onSurface, // ADATTIVO: Sostituito _textDark
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        letterSpacing: 0.3,
                      ),
                    ),
                    centerTitle: true,
                  ),

                  // ── Body
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),

                          // ── Hero card (avatar + nome + username)
                          _HeroCard(
                            option: selected,
                            nameController: _nameController,
                            isEditingName: _isEditingName,
                            username: '@${profile.username}',
                            points: pointsLabel,
                            level: profile.level.toString(),
                            toursCompleted: profile.visitedCount.toString(),
                            onAvatarTap: () async {
                              await _showAvatarPicker();
                              await _saveProfileBasics(profile);
                            },
                            onEditToggle: () => _toggleNameEdit(profile),
                          ),

                          if (_isSavingBasics)
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: LinearProgressIndicator(
                                color: AppPalette.olive,
                              ),
                            ),

                          if (_profileController.errorMessage != null) ...[
                            const SizedBox(height: 10),
                            Text(
                              _profileController.errorMessage!,
                              style: const TextStyle(
                                color: AppPalette.danger,
                                fontSize: 12,
                              ),
                            ),
                          ],

                          const SizedBox(height: 28),

                          // ── Divisore sezione stats
                          const _SectionLabel('Statistiche'),

                          const SizedBox(height: 14),

                          // ── Stats grid 2×2
                          GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: 1.55,
                            children: [
                              _StatCard(
                                icon: Icons.verified_user_outlined,
                                label: 'Traguardi',
                                value: '${profile.achievementsCount}',
                                color: AppPalette
                                    .olive, // Manteniamo i colori del brand
                              ),
                              _StatCard(
                                icon: Icons.speed_outlined,
                                label: 'Miglior punteggio',
                                value: bestScoreLabel,
                                color: AppPalette.tan,
                              ),
                              _StatCard(
                                icon: Icons.location_on_outlined,
                                label: 'Siti Visitati',
                                value: '${profile.visitedCount}',
                                color: AppPalette.moss,
                              ),
                              _StatCard(
                                icon: Icons.quiz_outlined,
                                label: 'Quiz Superati',
                                value: '${profile.totalQuizCompleted}',
                                color: AppPalette.tan,
                              ),
                              _StatCard(
                                icon: Icons.timer_outlined,
                                label: 'Miglior tempo tour',
                                value: bestTourTimeLabel,
                                color: AppPalette.olive,
                              ),
                              _StatCard(
                                icon: Icons.check_circle_outline,
                                label: 'Risposte corrette',
                                value: '${profile.totalCorrectAnswers}',
                                color: AppPalette.moss,
                              ),
                            ],
                          ),

                          const SizedBox(height: 28),
                          const _SectionLabel('Classifica globale XP'),
                          const SizedBox(height: 14),
                          _LeaderboardCard(
                            entries: _profileController.leaderboard,
                            currentUserId: profile.uid,
                          ),

                          const SizedBox(height: 28),

                          // ── Divisore sezione badges
                          const _SectionLabel('Ultimi badge'),

                          const SizedBox(height: 14),

                          _BadgesRow(),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  UserProfile _buildFallbackProfile() {
    return UserProfile(uid: '', email: '', displayName: _nameController.text);
  }

  String _formatPoints(int xp) {
    return xp.toString();
  }

  String _formatDuration(int seconds) {
    final mins = seconds ~/ 60;
    final sec = seconds % 60;
    return '${mins}m ${sec.toString().padLeft(2, '0')}s';
  }
}
