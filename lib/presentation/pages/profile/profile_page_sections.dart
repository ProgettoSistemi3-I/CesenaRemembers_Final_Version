part of 'profile_page.dart';

class _HeroCard extends StatelessWidget {
  final AvatarOption option;

  final TextEditingController nameController;

  final bool isEditingName;

  final String username;

  final String points;

  final String friendsCount;

  final String toursCount;

  final VoidCallback onAvatarTap;

  final VoidCallback onEditToggle;

  final VoidCallback onFriendsTap;

  const _HeroCard({
    required this.option,

    required this.nameController,

    required this.isEditingName,

    required this.username,

    required this.points,

    required this.friendsCount,

    required this.toursCount,

    required this.onAvatarTap,

    required this.onEditToggle,

    required this.onFriendsTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),

      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: BorderRadius.circular(32),

        boxShadow: [
          BoxShadow(
            color: AppPalette.tan.withValues(
              alpha: theme.brightness == Brightness.light ? 0.12 : 0.02,
            ),

            blurRadius: 32,

            offset: const Offset(0, 12),
          ),
        ],
      ),

      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,

            child: Stack(
              alignment: Alignment.bottomRight,

              children: [
                CircleAvatar(
                  radius: 56,

                  backgroundColor: option.background,
                  backgroundImage: AssetImage(option.assetPath),
                ),

                // Modern Edit Badge
                Container(
                  margin: const EdgeInsets.only(bottom: 4, right: 4),

                  padding: const EdgeInsets.all(8),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: AppPalette.olive,

                    border: Border.all(
                      color: theme.colorScheme.surface,

                      width: 3,
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.olive.withValues(alpha: 0.3),

                        blurRadius: 8,

                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: const Icon(
                    Icons.edit_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              if (isEditingName)
                Container(
                  width: 180,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),

                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.05),

                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: TextField(
                    controller: nameController,

                    autofocus: true,

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 24,

                      fontWeight: FontWeight.w800,

                      color: theme.colorScheme.onSurface,

                      letterSpacing: -0.5,
                    ),

                    decoration: const InputDecoration(
                      isDense: true,

                      contentPadding: EdgeInsets.zero,

                      border: InputBorder.none,
                    ),
                  ),
                )
              else
                Text(
                  nameController.text,

                  style: TextStyle(
                    fontSize: 24,

                    fontWeight: FontWeight.w800,

                    color: theme.colorScheme.onSurface,

                    letterSpacing: -0.5,
                  ),
                ),

              const SizedBox(width: 8),

              GestureDetector(
                onTap: onEditToggle,

                child: Container(
                  padding: const EdgeInsets.all(6),

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: isEditingName
                        ? AppPalette.olive.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),

                  child: Icon(
                    isEditingName
                        ? Icons.check_circle_rounded
                        : Icons.edit_outlined,

                    size: 22,

                    color: isEditingName
                        ? AppPalette.olive
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.6,
                          ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 2),

          Text(
            '@$username',

            style: TextStyle(
              fontSize: 14,

              fontWeight: FontWeight.w500,

              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),

              letterSpacing: 0.2,
            ),
          ),

          const SizedBox(height: 32),

          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),

            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.03),

              borderRadius: BorderRadius.circular(24),
            ),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                _MiniStat(
                  label: AppLocalizations.of(context)!.profileFriends,

                  value: friendsCount,

                  onTap: onFriendsTap,

                  highlightColor: AppPalette.tan,
                ),

                const _VerticalDivider(),

                _MiniStat(
                  label: AppLocalizations.of(context)!.profilePoints,

                  value: points,

                  highlightColor: AppPalette.olive,
                ),

                const _VerticalDivider(),

                _MiniStat(
                  label: AppLocalizations.of(context)!.tourLabel,

                  value: toursCount,

                  highlightColor: AppPalette.moss,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;

  final String value;

  final VoidCallback? onTap;

  final Color highlightColor;

  const _MiniStat({
    required this.label,

    required this.value,

    this.onTap,

    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,

      behavior: HitTestBehavior.opaque,

      child: Column(
        children: [
          Text(
            value,

            style: TextStyle(
              fontSize: 22,

              fontWeight: FontWeight.w900,

              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label.toUpperCase(),

            style: TextStyle(
              fontSize: 12,

              fontWeight: FontWeight.w600,

              color: highlightColor,

              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 36,

    width: 2,

    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.08),

      borderRadius: BorderRadius.circular(2),
    ),
  );
}

class _StatCard extends StatelessWidget {
  final IconData icon;

  final String label;

  final String value;

  final Color color;

  const _StatCard({
    required this.icon,

    required this.label,

    required this.value,

    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),

        borderRadius: BorderRadius.circular(24),

        border: Border.all(color: color.withValues(alpha: 0.15), width: 1.5),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        mainAxisSize: MainAxisSize.min,

        children: [
          Container(
            padding: const EdgeInsets.all(6),

            decoration: BoxDecoration(
              color: theme.colorScheme.surface,

              borderRadius: BorderRadius.circular(14),

              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),

                  blurRadius: 10,

                  offset: const Offset(0, 4),
                ),
              ],
            ),

            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(height: 6),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,

            children: [
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 18,

                  fontWeight: FontWeight.w900,

                  color: theme.colorScheme.onSurface,

                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,

                style: TextStyle(
                  fontSize: 11.5,

                  color: theme.colorScheme.onSurfaceVariant,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<String> unlockedIds;
  final List<String> pendingIds;
  final Function(String) onUnlock;

  const _AchievementsGrid({
    required this.unlockedIds,
    required this.pendingIds,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final achievements = AchievementService.all;

    return GridView.builder(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 20,
        childAspectRatio: 0.78,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, i) {
        final achievement = achievements[i];
        final isUnlocked = unlockedIds.contains(achievement.id);
        final isPending = pendingIds.contains(achievement.id);
        return _AchievementTile(
          achievement: achievement,
          isUnlocked: isUnlocked,
          isPending: isPending,
          onUnlock: () => onUnlock(achievement.id),
        );
      },
    );
  }
}

class _AchievementTile extends StatefulWidget {
  final AchievementDefinition achievement;
  final bool isUnlocked;
  final bool isPending;
  final VoidCallback onUnlock;

  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
    required this.isPending,
    required this.onUnlock,
  });

  @override
  State<_AchievementTile> createState() => _AchievementTileState();
}

class _AchievementTileState extends State<_AchievementTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _spinAnim;
  late Animation<double> _glowAnim;
  bool _isAnimating = false;
  bool _justUnlocked = false;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnim = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.25)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.25),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.25, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 30,
      ),
    ]).animate(_animCtrl);

    _spinAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOutCubic),
    ).drive(Tween(begin: 0.0, end: 2.0)); // 2 turns

    _glowAnim = CurvedAnimation(
      parent: _animCtrl,
      curve: const Interval(0.2, 0.8, curve: Curves.easeInOut),
    ).drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _handleTap() async {
    final canUnlock = widget.isPending && !_justUnlocked;

    if (canUnlock && !_isAnimating) {
      setState(() => _isAnimating = true);
      await _animCtrl.forward();
      widget.onUnlock();
      setState(() {
        _isAnimating = false;
        _justUnlocked = true;
      });
      _animCtrl.reset();
    } else {
      _showDetailsDialog();
    }
  }

  void _showDetailsDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: SizedBox(
                width: 80,
                height: 80,
                child: widget.isUnlocked
                    ? Image.asset(widget.achievement.assetPath, fit: BoxFit.cover)
                    : ColorFiltered(
                        colorFilter: const ColorFilter.matrix([
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0.2126, 0.7152, 0.0722, 0, 0,
                          0, 0, 0, 1, 0,
                        ]),
                        child: Image.asset(
                          widget.achievement.assetPath,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isUnlocked
                  ? AppLocalizations.of(context)!.achievementTitle(widget.achievement.id)
                  : '???',
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          widget.isUnlocked
              ? AppLocalizations.of(context)!.achievementDescription(widget.achievement.id)
              : '\u{1F512}  ${AppLocalizations.of(context)!.achievementDescription(widget.achievement.id)}',
          style: TextStyle(
            color: widget.isUnlocked
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.buttonOk),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveUnlocked = widget.isUnlocked || _justUnlocked;

    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animCtrl,
        builder: (context, child) {
          final scale = _scaleAnim.value;
          final turns = _spinAnim.value;
          final glow = _glowAnim.value;

          return Transform.scale(
            scale: scale,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      // Glow effect during animation
                      if (_isAnimating)
                        OverflowBox(
                          maxWidth: 160,
                          maxHeight: 160,
                          child: Container(
                            width: 80 + (glow * 40),
                            height: 80 + (glow * 40),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppPalette.olive.withValues(alpha: glow * 0.8),
                                  blurRadius: 20 * glow,
                                  spreadRadius: 10 * glow,
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Badge Image
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 250),
                        opacity: effectiveUnlocked || _isAnimating ? 1.0 : (widget.isPending ? 0.9 : 0.55),
                        child: Transform.rotate(
                          angle: turns * 3.1415926535 * 2,
                          child: ClipOval(
                            child: effectiveUnlocked || _isAnimating
                                ? Image.asset(
                                    widget.achievement.assetPath,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  )
                                : ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0.2126, 0.7152, 0.0722, 0, 0,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: Image.asset(
                                      widget.achievement.assetPath,
                                      width: 80,
                                      height: 80,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                        ),
                      ),

                      // Pending Overlay
                      if (widget.isPending && !effectiveUnlocked && !_isAnimating)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.3),
                              border: Border.all(
                                color: AppPalette.olive.withValues(alpha: 0.8),
                                width: 3,
                              ),
                            ),
                            child: Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppPalette.olive,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'SBLOCCA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  effectiveUnlocked || widget.isPending
                      ? AppLocalizations.of(context)!.achievementTitle(widget.achievement.id)
                      : '???',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: effectiveUnlocked ? FontWeight.w700 : FontWeight.w500,
                    color: effectiveUnlocked || widget.isPending
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,

          height: 22,

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

            color: Theme.of(context).colorScheme.onSurface,

            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  final int selected;

  final ValueChanged<int> onSelect;

  const _AvatarPickerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,

        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),

      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),

      child: Column(
        mainAxisSize: MainAxisSize.min,

        children: [
          // Modern Drag Handle
          Container(
            width: 48,

            height: 5,

            margin: const EdgeInsets.only(bottom: 24),

            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.15),

              borderRadius: BorderRadius.circular(10),
            ),
          ),

          Text(
            AppLocalizations.of(context)!.avatarPickerTitle,

            style: TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.w800,

              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            AppLocalizations.of(context)!.avatarPickerSubtitle,

            style: TextStyle(
              fontSize: 14,

              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 32),

          GridView.builder(
            shrinkWrap: true,

            physics: const NeverScrollableScrollPhysics(),

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount:
                  4, // Ridotto per fare avatar più grandi e visibili

              crossAxisSpacing: 20,

              mainAxisSpacing: 20,
            ),

            itemCount: avatarOptions.length,

            itemBuilder: (context, i) {
              final opt = avatarOptions[i];

              final isSelected = selected == i;

              return GestureDetector(
                onTap: () {
                  onSelect(i);

                  Navigator.pop(context);
                },

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),

                  curve: Curves.easeOutCubic,

                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    color: opt.background,
                    image: DecorationImage(
                      image: AssetImage(opt.assetPath),
                      fit: BoxFit.cover,
                    ),

                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppPalette.olive.withValues(alpha: 0.4),

                              blurRadius: 16,

                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],

                    border: Border.all(
                      color: isSelected ? AppPalette.olive : Colors.transparent,

                      width: 3,
                    ),
                  ),

                  child: Stack(
                    alignment: Alignment.center,

                    children: [
                      if (isSelected)
                        Positioned(
                          right: 0,

                          bottom: 0,

                          child: Container(
                            padding: const EdgeInsets.all(4),

                            decoration: BoxDecoration(
                              color: AppPalette.olive,

                              shape: BoxShape.circle,

                              border: Border.all(
                                color: theme.colorScheme.surface,
                                width: 2,
                              ),
                            ),

                            child: const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
