import 'package:flutter/material.dart';

import 'package:cesena_remembers/l10n/app_localizations.dart';



import '../../../domain/entities/userprofile.dart';



import '../../../domain/usecases/user_profile_use_cases.dart';



import '../../../injection_container.dart';



import '../../controllers/social_controller.dart';



import '../../services/shell_navigation_store.dart';



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



  String? _loadError;



  late final SocialController _socialCtrl;



  @override

  void initState() {

    super.initState();



    _socialCtrl = sl<SocialController>();



    _loadProfile();

  }



  Future<void> _loadProfile() async {

    setState(() {

      _isLoading = true;



      _loadError = null;

    });



    try {

      final profile = await sl<UserProfileUseCases>().getUserProfile(

        widget.uid,

      );



      if (!mounted) return;



      setState(() {

        _targetProfile = profile;



        _isLoading = false;



        _loadError = null;

      });

    } catch (_) {

      if (!mounted) return;



      setState(() {

        _isLoading = false;



        _loadError = 'error_load_profile';

      });

    }

  }



  void _onFriendAction(String action) async {

    final myUid = _socialCtrl.currentUserId;



    if (_targetProfile == null) return;



    final previousFriends = List<String>.from(_targetProfile!.friends);



    final previousSent = List<String>.from(_targetProfile!.sentFriendRequests);



    final previousReceived = List<String>.from(

      _targetProfile!.receivedFriendRequests,

    );



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



    final success = await _socialCtrl.handleFriendAction(action, widget.uid);



    if (success || !mounted) return;



    setState(() {

      _targetProfile!.friends

        ..clear()

        ..addAll(previousFriends);



      _targetProfile!.sentFriendRequests

        ..clear()

        ..addAll(previousSent);



      _targetProfile!.receivedFriendRequests

        ..clear()

        ..addAll(previousReceived);

    });



    ScaffoldMessenger.of(context).showSnackBar(

      SnackBar(

        content: Text(AppLocalizations.of(context)!.errorOperationFailed),



        backgroundColor: AppPalette.danger,



        behavior: SnackBarBehavior.floating,

      ),

    );

  }



  // Visualizza la lista amici dell'utente



  void _showFriendsList(List<String> friendUids, ThemeData theme) async {

    final users = await _socialCtrl.loadUsersList(friendUids);



    if (!mounted) return;



    showModalBottomSheet(

      context: context,



      backgroundColor: theme.colorScheme.surface,



      isScrollControlled: true,



      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),

      ),



      builder: (_) => _buildUserListSheet(

        AppLocalizations.of(context)!.socialFriendsOf(_targetProfile!.displayName),



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

    return DraggableScrollableSheet(

      initialChildSize: 0.5,



      minChildSize: 0.3,



      maxChildSize: 0.9,



      expand: false,



      builder: (_, scrollController) {

        return Column(

          children: [

            const SizedBox(height: 12),



            // Drag handle

            Container(

              width: 40,



              height: 4,



              decoration: BoxDecoration(

                color: theme.colorScheme.onSurfaceVariant.withValues(

                  alpha: 0.4,

                ),



                borderRadius: BorderRadius.circular(2),

              ),

            ),



            const SizedBox(height: 16),



            Text(

              title,



              style: TextStyle(

                fontSize: 20,



                fontWeight: FontWeight.bold,



                color: theme.colorScheme.onSurface,

              ),

            ),



            const SizedBox(height: 16),



            Divider(

              color: theme.colorScheme.surfaceContainerHighest,

              height: 1,

            ),



            if (users.isEmpty)

              Expanded(

                child: Center(

                  child: Text(

                    AppLocalizations.of(context)!.socialNoUserFound,



                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),

                  ),

                ),

              )

            else

              Expanded(

                child: ListView.builder(

                  controller: scrollController,



                  itemCount: users.length,



                  padding: const EdgeInsets.symmetric(vertical: 8),



                  itemBuilder: (context, i) {

                    final u = users[i];



                    return ListTile(

                      contentPadding: const EdgeInsets.symmetric(

                        horizontal: 24,

                        vertical: 4,

                      ),



                      leading: CircleAvatar(

                        radius: 24,



                        backgroundColor: AppPalette.tan.withValues(alpha: 0.2),



                        child: Icon(

                          avatarById(u.avatarId).icon,



                          size: 24,



                          color: AppPalette.olive,

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



                      trailing: Icon(

                        Icons.chevron_right,



                        color: theme.colorScheme.onSurfaceVariant.withValues(

                          alpha: 0.5,

                        ),

                      ),



                      onTap: () {

                        Navigator.pop(context); // Chiude la bottom sheet



                        if (u.uid == _socialCtrl.currentUserId) {

                          Navigator.of(

                            context,

                          ).popUntil((route) => route.isFirst);



                          ShellNavigationStore.goToTab(2);



                          return;

                        }



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

        );

      },

    );

  }



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);



    if (_isLoading) {

      return Scaffold(

        backgroundColor: theme.colorScheme.surface,



        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),



        body: const Center(

          child: CircularProgressIndicator(color: AppPalette.olive),

        ),

      );

    }



    if (_loadError != null) {

      return Scaffold(

        backgroundColor: theme.colorScheme.surface,



        appBar: AppBar(backgroundColor: Colors.transparent, elevation: 0),



        body: Center(

          child: Padding(

            padding: const EdgeInsets.symmetric(horizontal: 24),



            child: Container(

              padding: const EdgeInsets.all(24),



              decoration: BoxDecoration(

                color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),



                borderRadius: BorderRadius.circular(24),

              ),



              child: Column(

                mainAxisSize: MainAxisSize.min,



                children: [

                  Icon(

                    Icons.error_outline,

                    color: theme.colorScheme.error,

                    size: 48,

                  ),



                  const SizedBox(height: 16),



                  Text(

                    AppLocalizations.of(context)!.errorLoadProfile,



                    textAlign: TextAlign.center,



                    style: TextStyle(

                      color: theme.colorScheme.onErrorContainer,



                      fontSize: 16,

                    ),

                  ),



                  const SizedBox(height: 24),



                  FilledButton.icon(

                    onPressed: _loadProfile,



                    icon: const Icon(Icons.refresh),



                    label: Text(AppLocalizations.of(context)!.buttonRetry),



                    style: FilledButton.styleFrom(

                      backgroundColor: theme.colorScheme.error,



                      foregroundColor: theme.colorScheme.onError,



                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(16),

                      ),

                    ),

                  ),

                ],

              ),

            ),

          ),

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

      backgroundColor: theme.colorScheme.surface,



      appBar: AppBar(

        backgroundColor: Colors.transparent,



        elevation: 0,



        scrolledUnderElevation: 0,



        title: Text(

          widget.fallbackUsername.startsWith('@')

              ? widget.fallbackUsername

              : '@${widget.fallbackUsername}',



          style: TextStyle(

            color: theme.colorScheme.onSurface,



            fontWeight: FontWeight.bold,



            letterSpacing: 0.5,

          ),

        ),



        centerTitle: true,



        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),

      ),



      body: SingleChildScrollView(

        physics: const BouncingScrollPhysics(),



        padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),



        child: Column(

          children: [

            // Header Profilo

            Container(

              width: double.infinity,



              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),



              decoration: BoxDecoration(

                color: theme.brightness == Brightness.light

                    ? Colors.white

                    : theme.colorScheme.surfaceContainerHighest.withValues(

                        alpha: 0.3,

                      ),



                borderRadius: BorderRadius.circular(32),



                boxShadow: [

                  BoxShadow(

                    color: Colors.black.withValues(

                      alpha: theme.brightness == Brightness.light ? 0.04 : 0.2,

                    ),



                    blurRadius: 24,



                    offset: const Offset(0, 8),

                  ),

                ],

              ),



              child: Column(

                children: [

                  // Avatar con anello decorativo

                  Container(

                    padding: const EdgeInsets.all(4),



                    decoration: BoxDecoration(

                      shape: BoxShape.circle,



                      border: Border.all(

                        color: AppPalette.olive.withValues(alpha: 0.3),



                        width: 3,

                      ),

                    ),



                    child: CircleAvatar(

                      radius: 56,



                      backgroundColor: avatar.background,



                      child: Icon(

                        avatar.icon,



                        size: 64,



                        color: Colors.black.withValues(alpha: 0.6),

                      ),

                    ),

                  ),



                  const SizedBox(height: 20),



                  Text(

                    profile.displayName,



                    style: TextStyle(

                      fontSize: 26,



                      fontWeight: FontWeight.w800,



                      color: theme.colorScheme.onSurface,



                      letterSpacing: -0.5,

                    ),

                  ),



                  const SizedBox(height: 4),



                  Container(

                    padding: const EdgeInsets.symmetric(

                      horizontal: 12,

                      vertical: 4,

                    ),



                    decoration: BoxDecoration(

                      color: theme.colorScheme.surfaceContainerHighest,



                      borderRadius: BorderRadius.circular(12),

                    ),



                    child: Text(

                      '@${profile.username}',



                      style: TextStyle(

                        fontSize: 14,



                        fontWeight: FontWeight.w600,



                        color: theme.colorScheme.onSurfaceVariant,

                      ),

                    ),

                  ),



                  const SizedBox(height: 28),



                  // Bottoni Amicizia

                  if (myUid != profile.uid) ...[

                    if (isFriend)

                      FilledButton.tonalIcon(

                        onPressed: () => _onFriendAction('remove'),



                        icon: const Icon(Icons.person_remove_rounded, size: 20),



                        label: Text(

                          AppLocalizations.of(context)!.removeFriendship,

                          style: const TextStyle(fontWeight: FontWeight.bold),

                        ),



                        style: FilledButton.styleFrom(

                          backgroundColor: AppPalette.danger.withValues(

                            alpha: 0.1,

                          ),



                          foregroundColor: AppPalette.danger,



                          padding: const EdgeInsets.symmetric(

                            horizontal: 24,

                            vertical: 12,

                          ),



                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),

                          ),

                        ),

                      )

                    else if (requestSent)

                      FilledButton.tonalIcon(

                        onPressed: () => _onFriendAction('cancel'),



                        icon: const Icon(Icons.how_to_reg_rounded, size: 20),



                        label: Text(

                          AppLocalizations.of(context)!.socialRequestSent,

                          style: const TextStyle(fontWeight: FontWeight.bold),

                        ),



                        style: FilledButton.styleFrom(

                          backgroundColor: AppPalette.tan.withValues(

                            alpha: 0.2,

                          ),



                          foregroundColor: AppPalette.olive,



                          padding: const EdgeInsets.symmetric(

                            horizontal: 24,

                            vertical: 12,

                          ),



                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),

                          ),

                        ),

                      )

                    else if (requestReceived)

                      Row(

                        mainAxisAlignment: MainAxisAlignment.center,



                        children: [

                          Expanded(

                            child: FilledButton(

                              onPressed: () => _onFriendAction('accept'),



                              style: FilledButton.styleFrom(

                                backgroundColor: AppPalette.olive,



                                padding: const EdgeInsets.symmetric(

                                  vertical: 12,

                                ),



                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(16),

                                ),

                              ),



                              child: Text(

                                AppLocalizations.of(context)!.socialAccept,

                                style: const TextStyle(fontWeight: FontWeight.bold),

                              ),

                            ),

                          ),



                          const SizedBox(width: 12),



                          Expanded(

                            child: OutlinedButton(

                              onPressed: () => _onFriendAction('reject'),



                              style: OutlinedButton.styleFrom(

                                foregroundColor: AppPalette.danger,



                                side: BorderSide(

                                  color: AppPalette.danger.withValues(

                                    alpha: 0.5,

                                  ),

                                  width: 1.5,

                                ),



                                padding: const EdgeInsets.symmetric(

                                  vertical: 12,

                                ),



                                shape: RoundedRectangleBorder(

                                  borderRadius: BorderRadius.circular(16),

                                ),

                              ),



                              child: Text(

                                AppLocalizations.of(context)!.socialReject,

                                style: const TextStyle(fontWeight: FontWeight.bold),

                              ),

                            ),

                          ),

                        ],

                      )

                    else

                      FilledButton.icon(

                        onPressed: () => _onFriendAction('send'),



                        icon: const Icon(Icons.person_add_rounded, size: 20),



                        label: Text(

                          AppLocalizations.of(context)!.socialAddFriend,

                          style: const TextStyle(fontWeight: FontWeight.bold),

                        ),



                        style: FilledButton.styleFrom(

                          backgroundColor: AppPalette.olive,



                          padding: const EdgeInsets.symmetric(

                            horizontal: 24,

                            vertical: 12,

                          ),



                          elevation: 2,



                          shape: RoundedRectangleBorder(

                            borderRadius: BorderRadius.circular(16),

                          ),

                        ),

                      ),



                    const SizedBox(height: 28),

                  ],



                  // Statistiche Rapide (Amici, Punti, Livello)

                  Container(

                    padding: const EdgeInsets.symmetric(vertical: 16),



                    decoration: BoxDecoration(

                      color: theme.colorScheme.surfaceContainerHighest

                          .withValues(alpha: 0.4),



                      borderRadius: BorderRadius.circular(20),

                    ),



                    child: Row(

                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,



                      children: [

                        Expanded(

                          child: _buildMiniStat(

                            AppLocalizations.of(context)!.publicStatFriends,



                            profile.friends.length.toString(),



                            theme,



                            onTap: isFriend

                                ? () => _showFriendsList(profile.friends, theme)

                                : () {

                                    ScaffoldMessenger.of(context).showSnackBar(

                                      SnackBar(

                                        content: Text(

                                          AppLocalizations.of(context)!.socialMustBeFriend,

                                        ),



                                        behavior: SnackBarBehavior.floating,



                                        shape: RoundedRectangleBorder(

                                          borderRadius: BorderRadius.circular(

                                            10,

                                          ),

                                        ),

                                      ),

                                    );

                                  },

                          ),

                        ),



                        Container(

                          height: 32,



                          width: 1.5,



                          color: theme.colorScheme.onSurfaceVariant.withValues(

                            alpha: 0.2,

                          ),

                        ),



                        Expanded(

                          child: _buildMiniStat(

                            AppLocalizations.of(context)!.publicStatPoints,

                            profile.xp.toString(),

                            theme,

                          ),

                        ),



                        Container(

                          height: 32,



                          width: 1.5,



                          color: theme.colorScheme.onSurfaceVariant.withValues(

                            alpha: 0.2,

                          ),

                        ),



                        Expanded(

                          child: _buildMiniStat(

                            AppLocalizations.of(context)!.publicStatLevel,

                            profile.level.toString(),

                            theme,

                          ),

                        ),

                      ],

                    ),

                  ),

                ],

              ),

            ),



            const SizedBox(height: 32),



            _SectionLabel(AppLocalizations.of(context)!.publicStatDetailed),



            const SizedBox(height: 16),



            // Grid Statistiche

            GridView.count(

              crossAxisCount: 2,



              shrinkWrap: true,



              physics: const NeverScrollableScrollPhysics(),



              crossAxisSpacing: 16,



              mainAxisSpacing: 16,



              childAspectRatio: 1.25,



              children: [

                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatAchievements,



                  '${profile.achievementsCount}',



                  Icons.emoji_events_rounded,



                  AppPalette.olive,



                  theme,

                ),



                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatBestScore,



                  '${profile.maxQuizScore}%',



                  Icons.bolt_rounded,



                  Colors.orange.shade400,



                  theme,

                ),



                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatSites,



                  '${profile.visitedCount}',



                  Icons.map_rounded,



                  AppPalette.moss,



                  theme,

                ),



                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatQuiz,



                  '${profile.totalQuizCompleted}',



                  Icons.fact_check_rounded,



                  AppPalette.tan,



                  theme,

                ),



                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatBestTime,



                  bestTourTimeLabel,



                  Icons.timer_rounded,



                  Colors.blue.shade400,



                  theme,

                ),



                _buildStatCard(

                  AppLocalizations.of(context)!.publicStatCorrectAnswers,



                  '${profile.totalCorrectAnswers}',



                  Icons.check_circle_rounded,



                  AppPalette.moss,



                  theme,

                ),

              ],

            ),

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

    return InkWell(

      onTap: onTap,



      borderRadius: BorderRadius.circular(12),



      child: Column(

        children: [

          Text(

            value,



            style: TextStyle(

              fontSize: 20,



              fontWeight: FontWeight.w900,



              color: theme.colorScheme.onSurface,

            ),

          ),



          const SizedBox(height: 4),



          Text(

            label,



            style: TextStyle(

              fontSize: 12,



              fontWeight: FontWeight.w600,



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

      padding: const EdgeInsets.all(16),



      decoration: BoxDecoration(

        color: theme.brightness == Brightness.light

            ? Colors.white

            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),



        borderRadius: BorderRadius.circular(24),



        border: Border.all(color: color.withValues(alpha: 0.1), width: 1.5),



        boxShadow: [

          BoxShadow(

            color: color.withValues(alpha: 0.05),



            blurRadius: 16,



            offset: const Offset(0, 4),

          ),

        ],

      ),



      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,



        mainAxisAlignment: MainAxisAlignment.spaceBetween,



        children: [

          Container(

            padding: const EdgeInsets.all(8),



            decoration: BoxDecoration(

              color: color.withValues(alpha: 0.15),



              borderRadius: BorderRadius.circular(12),

            ),



            child: Icon(icon, color: color, size: 22),

          ),



          Column(

            crossAxisAlignment: CrossAxisAlignment.start,



            children: [

              Text(

                value,



                style: TextStyle(

                  fontSize: 22,



                  fontWeight: FontWeight.w800,



                  color: theme.colorScheme.onSurface,

                ),

              ),



              const SizedBox(height: 2),



              Text(

                label,



                style: TextStyle(

                  fontSize: 13,



                  color: theme.colorScheme.onSurfaceVariant,



                  fontWeight: FontWeight.w600,

                ),



                maxLines: 1,



                overflow: TextOverflow.ellipsis,

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

            width: 4,



            height: 20,



            margin: const EdgeInsets.only(right: 12),



            decoration: BoxDecoration(

              color: AppPalette.olive,



              borderRadius: BorderRadius.circular(4),

            ),

          ),



          Text(

            text,



            style: TextStyle(

              fontSize: 18,



              fontWeight: FontWeight.w800,



              color: theme.colorScheme.onSurface,



              letterSpacing: -0.3,

            ),

          ),

        ],

      ),

    );

  }

}

