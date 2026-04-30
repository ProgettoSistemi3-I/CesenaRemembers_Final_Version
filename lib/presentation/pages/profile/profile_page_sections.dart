part of 'profile_page.dart';

class _HeroCard extends StatelessWidget {
  final AvatarOption option;

  final TextEditingController nameController;

  final bool isEditingName;

  final String username;

  final String points;

  final String friendsCount;

  final String level;

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

    required this.level,

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
                // Modern gradient ring around the avatar
                Container(
                  padding: const EdgeInsets.all(4),

                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,

                    gradient: LinearGradient(
                      colors: [AppPalette.olive, AppPalette.tan],

                      begin: Alignment.topLeft,

                      end: Alignment.bottomRight,
                    ),
                  ),

                  child: Container(
                    padding: const EdgeInsets.all(4),

                    decoration: BoxDecoration(
                      shape: BoxShape.circle,

                      color: theme.colorScheme.surface,
                    ),

                    child: CircleAvatar(
                      radius: 56,

                      backgroundColor: option.background,

                      child: Icon(
                        option.icon,

                        size: 60,

                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
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
                  label: 'Amici',

                  value: friendsCount,

                  onTap: onFriendsTap,

                  highlightColor: AppPalette.tan,
                ),

                const _VerticalDivider(),

                _MiniStat(
                  label: 'Punti',

                  value: points,

                  highlightColor: AppPalette.olive,
                ),

                const _VerticalDivider(),

                _MiniStat(
                  label: 'Livello',

                  value: level,

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

class _BadgesRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,

      children: [
        const Expanded(
          child: _BadgeTile(
            icon: Icons.military_tech_rounded,

            label: 'Pioniere',

            color: AppPalette.olive,
          ),
        ),

        const Expanded(
          child: _BadgeTile(
            icon: Icons.explore_rounded,

            label: 'Esploratore',

            color: AppPalette.tan,
          ),
        ),

        const Expanded(
          child: _BadgeTile(
            icon: Icons.history_edu_rounded,

            label: 'Storico',

            color: AppPalette.moss,
          ),
        ),

        Expanded(
          child: _BadgeTile(
            icon: Icons.lock_outline_rounded,

            label: 'Segreto',

            color: Colors.grey.withValues(alpha: 0.5),

            isLocked: true,
          ),
        ),
      ],
    );
  }
}

class _BadgeTile extends StatelessWidget {
  final IconData icon;

  final String label;

  final Color color;

  final bool isLocked;

  const _BadgeTile({
    required this.icon,

    required this.label,

    required this.color,

    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 64,

          height: 64,

          decoration: BoxDecoration(
            shape: BoxShape.circle,

            color: isLocked
                ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
                : color.withValues(alpha: 0.12),
          ),

          child: Icon(
            icon,

            color: isLocked
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : color,

            size: 30,
          ),
        ),

        const SizedBox(height: 10),

        Text(
          label,

          style: TextStyle(
            fontSize: 12,

            fontWeight: isLocked ? FontWeight.w500 : FontWeight.w700,

            color: isLocked
                ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
                : theme.colorScheme.onSurface,
          ),

          textAlign: TextAlign.center,
        ),
      ],
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
            'Scegli il tuo Avatar',

            style: TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.w800,

              color: theme.colorScheme.onSurface,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Personalizza il tuo profilo',

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
                      Icon(
                        opt.icon,

                        size: isSelected ? 38 : 34,

                        color: Colors.black.withValues(alpha: 0.6),
                      ),

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
