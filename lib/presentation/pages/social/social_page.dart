import 'package:flutter/material.dart';
import '../../../injection_container.dart';
import '../../controllers/social_controller.dart';
import '../../services/shell_navigation_store.dart';
import '../../theme/app_palette.dart';
import '../profile/avatar_catalog.dart';
import 'public_profile_page.dart';

class SocialPage extends StatefulWidget {
  const SocialPage({super.key});

  @override
  State<SocialPage> createState() => _SocialPageState();
}

class _SocialPageState extends State<SocialPage> {
  late final SocialController _controller;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = sl<SocialController>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openProfile(String uid, String name, String username) {
    if (uid == _controller.currentUserId) {
      ShellNavigationStore.goToTab(2);
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PublicProfilePage(
          uid: uid,
          fallbackName: name,
          fallbackUsername: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Text(
          'Community',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Column(
            children: [
              // Barra di Ricerca
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cerca utente...',
                    prefixIcon: Icon(
                      Icons.search,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              _controller.search('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(
                        color: theme.colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.5),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: const BorderSide(
                        color: AppPalette.olive,
                        width: 1.5,
                      ),
                    ),
                  ),
                  onChanged: (val) => _controller.search(val),
                ),
              ),

              const SizedBox(height: 10),

              Expanded(
                child: _searchController.text.isNotEmpty
                    ? _buildSearchResults(theme)
                    : _buildLeaderboard(theme),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLeaderboard(ThemeData theme) {
    if (_controller.leaderboard.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppPalette.olive),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
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
                'Classifica Globale XP',
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

        // UTENTE CORRENTE FISSATO
        if (_controller.currentUserEntry != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: _buildLeaderboardTile(
              _controller.currentUserEntry!,
              theme,
              isPinned: true,
            ),
          ),
        if (_controller.currentUserEntry != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Divider(
              color: theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.5,
              ),
            ),
          ),

        // LISTA NORMALE
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _controller.leaderboard.length,
            itemBuilder: (context, index) {
              final entry = _controller.leaderboard[index];
              return _buildLeaderboardTile(entry, theme, isPinned: false);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardTile(
    LeaderboardEntry entry,
    ThemeData theme, {
    required bool isPinned,
  }) {
    final isCurrentUser = entry.uid == _controller.currentUserId;
    final avatar = avatarById(entry.avatarId);

    final backgroundColor = isCurrentUser
        ? AppPalette.olive.withValues(alpha: 0.25)
        : theme.colorScheme.surface;

    final borderColor = isCurrentUser
        ? AppPalette.olive.withValues(alpha: 0.5)
        : Colors.transparent;

    return Container(
      margin: EdgeInsets.symmetric(vertical: isPinned ? 0 : 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: !isCurrentUser && !isPinned
            ? [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: theme.brightness == Brightness.light ? 0.04 : 0.16,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () =>
              _openProfile(entry.uid, entry.displayName, entry.username),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    '#${entry.rank}',
                    style: TextStyle(
                      color: isCurrentUser
                          ? AppPalette.olive
                          : theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
                CircleAvatar(
                  radius: 18,
                  backgroundColor: avatar.background,
                  child: Icon(
                    avatar.icon,
                    size: 18,
                    color: Colors.black.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCurrentUser && isPinned
                            ? "${entry.displayName} (Tu)"
                            : entry.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        entry.username.isNotEmpty
                            ? '@${entry.username}'
                            : '@utente',
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${entry.xp} XP',
                  style: const TextStyle(
                    color: AppPalette.olive,
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(ThemeData theme) {
    if (_controller.isSearching) {
      return const Center(
        child: CircularProgressIndicator(color: AppPalette.olive),
      );
    }
    if (_controller.requiresMoreSearchChars) {
      return Center(
        child: Text(
          'Digita almeno 2 caratteri per cercare.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }
    if (_controller.searchResults.isEmpty) {
      return Center(
        child: Text(
          'Nessun utente trovato.',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _controller.searchResults.length,
      itemBuilder: (context, index) {
        final user = _controller.searchResults[index];
        final avatar = avatarById(user.avatarId);

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: theme.brightness == Brightness.light ? 0.04 : 0.16,
                ),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () =>
                  _openProfile(user.uid, user.displayName, user.username),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: avatar.background,
                      child: Icon(
                        avatar.icon,
                        size: 18,
                        color: Colors.black.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '@${user.username}',
                            style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${user.xp} XP',
                          style: const TextStyle(
                            color: AppPalette.olive,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          'Lvl ${user.level}',
                          style: TextStyle(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
