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
    _profileController = ProfileController(userUseCases: sl());
    _socialController = sl<SocialController>();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _profileController.dispose();
    _socialController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _showAvatarPicker() async {
    final theme = Theme.of(context);
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: theme.colorScheme.surface,
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
          'Il nome contiene termini non consentiti. Inseriscine uno diverso.';
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
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _buildUserListSheet('I tuoi Amici', users, theme),
    );
  }

  void _showRequestsList(UserProfile profile, ThemeData theme) async {
    final users = await _socialController.loadUsersList(
      profile.receivedFriendRequests,
    );
    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) =>
          _buildUserListSheet('Richieste d\'amicizia', users, theme),
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
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AnimatedBuilder(
        animation: _profileController,
        builder: (context, _) {
          if (_profileController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.olive),
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
                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    floating: true,
                    snap: true,
                    title: Text(
                      'Il mio profilo',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                      ),
                    ),
                    centerTitle: true,
                    actions: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.notifications_none,
                              color: theme.colorScheme.onSurface,
                            ),
                            onPressed: () => _showRequestsList(profile, theme),
                          ),
                          if (profile.receivedFriendRequests.isNotEmpty)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppPalette.danger,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${profile.receivedFriendRequests.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 28),
                          _HeroCard(
                            option: selected,
                            nameController: _nameController,
                            isEditingName: _isEditingName,
                            username: '@${profile.username}',
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
                            const Padding(
                              padding: EdgeInsets.only(top: 10),
                              child: LinearProgressIndicator(
                                color: AppPalette.olive,
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
                              _StatCard(
                                icon: Icons.verified_user_outlined,
                                label: 'Traguardi',
                                value: '${profile.achievementsCount}',
                                color: AppPalette.olive,
                              ),
                              _StatCard(
                                icon: Icons.speed_outlined,
                                label: 'Miglior punteggio',
                                value: '${profile.maxQuizScore}%',
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
                                label: 'Miglior tempo',
                                value: profile.bestTourTimeSeconds > 0
                                    ? '${profile.bestTourTimeSeconds ~/ 60}m ${profile.bestTourTimeSeconds % 60}s'
                                    : '--',
                                color: AppPalette.olive,
                              ),
                              _StatCard(
                                icon: Icons.check_circle_outline,
                                label: 'Risposte esatte',
                                value: '${profile.totalCorrectAnswers}',
                                color: AppPalette.moss,
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
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
}
