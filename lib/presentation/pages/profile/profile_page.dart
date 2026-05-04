import 'package:flutter/material.dart';

import '../../../domain/entities/userprofile.dart';

import '../../../domain/validation/profile_validation.dart';

import '../../../injection_container.dart';

import '../../controllers/profile_controller.dart';

import '../../controllers/social_controller.dart';

import '../../theme/app_palette.dart';

import '../social/public_profile_page.dart';

import 'avatar_catalog.dart';

part 'profile_page_sections.dart';

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

  late final SocialController _socialController;

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

    _profileController = ProfileController(profileUseCases: sl());

    _socialController = sl<SocialController>();
  }

  @override
  void dispose() {
    _animCtrl.dispose();

    _profileController.dispose();

    _nameController.dispose();

    super.dispose();
  }

  Future<void> _showAvatarPicker() async {
    final theme = Theme.of(context);

    await showModalBottomSheet<void>(
      context: context,

      backgroundColor: theme.colorScheme.surface,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),

      builder: (_) => _AvatarPickerSheet(
        selected: _selectedAvatarIndex,

        onSelect: (i) => setState(() => _selectedAvatarIndex = i),
      ),
    );
  }

  Future<void> _toggleNameEdit(UserProfile profile) async {
    if (_isEditingName) await _saveProfileBasics(profile);

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
          'Il nome deve avere ${ProfileValidation.minDisplayNameLength}-${ProfileValidation.maxDisplayNameLength} caratteri.';

      _profileController.notifyListeners();

      setState(() => _nameController.text = profile.displayName);

      return;
    }

    if (ProfileValidation.hasOffensiveDisplayName(updatedName)) {
      _profileController.errorMessage =
          'Il nome contiene termini non consentiti.\nInseriscine uno diverso.';

      _profileController.notifyListeners();

      setState(() => _nameController.text = profile.displayName);

      return;
    }

    if (updatedName == profile.displayName &&
        selectedAvatarId == profile.avatarId) {
      return;
    }

    setState(() => _isSavingBasics = true);

    try {
      await _profileController.updateProfileBasics(
        displayName: updatedName != profile.displayName ? updatedName : null,

        avatarId: selectedAvatarId != profile.avatarId
            ? selectedAvatarId
            : null,
      );
    } finally {
      if (mounted) setState(() => _isSavingBasics = false);
    }
  }

  // --- AMICIZIE E NOTIFICHE ---

  void _showFriendsList(UserProfile profile, ThemeData theme) async {
    final users = await _socialController.loadUsersList(profile.friends);

    if (!mounted) return;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: theme.colorScheme.surface,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),

      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,

        child: _buildUserListSheet('I tuoi Amici', users, theme),
      ),
    );
  }

  void _showRequestsList(UserProfile profile, ThemeData theme) async {
    final users = await _socialController.loadUsersList(
      profile.receivedFriendRequests,
    );

    if (!mounted) return;

    showModalBottomSheet(
      context: context,

      isScrollControlled: true,

      backgroundColor: theme.colorScheme.surface,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),

      builder: (_) => FractionallySizedBox(
        heightFactor: 0.8,

        child: _buildUserListSheet('Richieste d\'amicizia', users, theme),
      ),
    );
  }

  Widget _buildUserListSheet(
    String title,

    List<UserProfile> users,

    ThemeData theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 24),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // Drag handle moderno
          Container(
            width: 48,

            height: 5,

            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.3),

              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 20),

          Text(
            title,

            style: TextStyle(
              fontSize: 22,

              fontWeight: FontWeight.w800,

              letterSpacing: -0.5,

              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 16),

          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.people_outline_rounded,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Nessuna richiesta al momento.',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),

                itemCount: users.length,

                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),

                itemBuilder: (context, i) {
                  final u = users[i];

                  return Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),

                      borderRadius: BorderRadius.circular(20),

                      border: Border.all(
                        color: theme.colorScheme.outline.withOpacity(0.1),
                      ),
                    ),

                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      leading: Container(
                        padding: const EdgeInsets.all(2),

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          border: Border.all(
                            color: theme.colorScheme.primary.withOpacity(0.2),

                            width: 2,
                          ),
                        ),

                        child: CircleAvatar(
                          backgroundColor: AppPalette.tan,

                          radius: 22,

                          child: Icon(
                            avatarById(u.avatarId).icon,

                            size: 22,

                            color: Colors.black87,
                          ),
                        ),
                      ),

                      title: Text(
                        u.displayName,

                        style: TextStyle(
                          color: theme.colorScheme.onSurface,

                          fontWeight: FontWeight.w700,

                          fontSize: 16,
                        ),
                      ),

                      subtitle: Text(
                        '@${u.username}',

                        style: TextStyle(
                          color: theme.colorScheme.primary,

                          fontWeight: FontWeight.w500,

                          fontSize: 13,
                        ),
                      ),

                      trailing: Icon(
                        Icons.chevron_right_rounded,

                        color: theme.colorScheme.onSurfaceVariant,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),

                      onTap: () {
                        Navigator.pop(context);

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
                    ),
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

    return Scaffold(
      backgroundColor: theme.colorScheme.surface, // Sfondo più moderno

      body: AnimatedBuilder(
        animation: _profileController,

        builder: (context, _) {
          if (_profileController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppPalette.olive,

                strokeWidth: 3,
              ),
            );
          }

          final dynamicProfile = _profileController.profile;

          final profile =
              dynamicProfile ??
              UserProfile(
                uid: '',

                email: '',

                displayName: _nameController.text,
              );

          final selected = avatarById(profile.avatarId);

          if (!_isEditingName && _nameController.text != profile.displayName) {
            _nameController.text = profile.displayName;
          }

          return FadeTransition(
            opacity: _fadeAnim,

            child: SlideTransition(
              position: _slideAnim,

              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),

                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.colorScheme.surface,

                    surfaceTintColor: Colors.transparent,

                    elevation: 0,

                    pinned: true,

                    title: Text(
                      'Il mio profilo',

                      style: TextStyle(
                        color: theme.colorScheme.onSurface,

                        fontWeight: FontWeight.w800,

                        letterSpacing: -0.5,

                        fontSize: 22,
                      ),
                    ),

                    centerTitle:
                        false, // Design più moderno allineato a sinistra

                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16.0),

                        child: Stack(
                          alignment: Alignment.center,

                          clipBehavior: Clip.none,

                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant
                                    .withOpacity(0.4),

                                shape: BoxShape.circle,
                              ),

                              child: IconButton(
                                icon: Icon(
                                  Icons.notifications_outlined,

                                  color: theme.colorScheme.onSurface,

                                  size: 24,
                                ),

                                onPressed: () =>
                                    _showRequestsList(profile, theme),
                              ),
                            ),

                            if (profile.receivedFriendRequests.isNotEmpty)
                              Positioned(
                                right: -2,

                                top: -2,

                                child: Container(
                                  padding: const EdgeInsets.all(6),

                                  decoration: BoxDecoration(
                                    color: AppPalette.danger,

                                    shape: BoxShape.circle,

                                    border: Border.all(
                                      color: theme.colorScheme.surface,

                                      width: 2.5, // Effetto cutout
                                    ),
                                  ),

                                  child: Text(
                                    '${profile.receivedFriendRequests.length}',

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 10,

                                      fontWeight: FontWeight.w900,

                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const SizedBox(height: 20),

                          _HeroCard(
                            option: selected,

                            nameController: _nameController,

                            isEditingName: _isEditingName,

                            username: profile.username,

                            points: profile.xp.toString(),

                            level: profile.level.toString(),

                            friendsCount: profile.friends.length.toString(),

                            onAvatarTap: () async {
                              await _showAvatarPicker();

                              await _saveProfileBasics(profile);
                            },

                            onEditToggle: () => _toggleNameEdit(profile),

                            onFriendsTap: () =>
                                _showFriendsList(profile, theme),
                          ),

                          if (_isSavingBasics)
                            Padding(
                              padding: const EdgeInsets.only(top: 16),

                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),

                                child: const LinearProgressIndicator(
                                  color: AppPalette.olive,

                                  minHeight: 6,
                                ),
                              ),
                            ),

                          const SizedBox(height: 32),

                          const _SectionLabel('Statistiche'),

                          const SizedBox(height: 16),

                          GridView.count(
                            crossAxisCount: 2,

                            shrinkWrap: true,

                            physics: const NeverScrollableScrollPhysics(),

                            crossAxisSpacing: 16,

                            mainAxisSpacing: 16,

                            childAspectRatio:
                                1.4, // Card leggermente più alte per un look arioso

                            children: [
                              _StatCard(
                                icon: Icons
                                    .emoji_events_outlined, // Icona aggiornata

                                label: 'Traguardi',

                                value: '${profile.achievementsCount}',

                                color: AppPalette.olive,
                              ),

                              _StatCard(
                                icon: Icons.speed_rounded,

                                label: 'Miglior punteggio',

                                value: '${profile.maxQuizScore}%',

                                color: AppPalette.tan,
                              ),

                              _StatCard(
                                icon: Icons.map_outlined,

                                label: 'Siti Visitati',

                                value: '${profile.visitedCount}',

                                color: AppPalette.moss,
                              ),

                              _StatCard(
                                icon: Icons
                                    .psychology_outlined, // Icona più pertinente al quiz

                                label: 'Quiz Superati',

                                value: '${profile.totalQuizCompleted}',

                                color: AppPalette.tan,
                              ),

                              _StatCard(
                                icon: Icons.timer_outlined,

                                label: 'Miglior tempo',

                                value: profile.bestTourTimeSeconds > 0
                                    ? '${profile.bestTourTimeSeconds ~/ 60}m ${profile.bestTourTimeSeconds % 60}s'
                                    : '--',

                                color: AppPalette.olive,
                              ),

                              _StatCard(
                                icon: Icons.check_circle_outline_rounded,

                                label: 'Risposte esatte',

                                value: '${profile.totalCorrectAnswers}',

                                color: AppPalette.moss,
                              ),
                            ],
                          ),

                          const SizedBox(height: 36),

                          const _SectionLabel('Ultimi badge'),

                          const SizedBox(height: 16),

                          _BadgesRow(),

                          const SizedBox(height: 48), // Padding finale generoso
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
}
