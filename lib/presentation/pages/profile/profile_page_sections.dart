part of 'profile_page.dart';

class _HeroCard extends StatelessWidget {
  final _AvatarOption option;
  final TextEditingController nameController;
  final bool isEditingName;
  final String username;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditToggle;

  const _HeroCard({
    required this.option,
    required this.nameController,
    required this.isEditingName,
    required this.username,
    required this.onAvatarTap,
    required this.onEditToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // TEMA ADATTIVO

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ADATTIVO
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppPalette.tan.withValues(
              alpha: theme.brightness == Brightness.light ? 0.08 : 0.01,
            ),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          GestureDetector(
            onTap: onAvatarTap,
            child: Stack(
              alignment: Alignment.bottomRight,
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
                    backgroundColor: option.background,
                    child: Icon(
                      option.icon,
                      size: 58,
                      color: Colors.black.withValues(
                        alpha: 0.5,
                      ), // Le icone restano scure sul bg colorato
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppPalette.tan,
                  ),
                  child: const Icon(Icons.edit, size: 13, color: Colors.white),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nome modificabile
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isEditingName)
                SizedBox(
                  width: 160,
                  child: TextField(
                    controller: nameController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface, // ADATTIVO
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppPalette.olive.withValues(alpha: 0.4),
                        ),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: AppPalette.olive,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  nameController.text,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface, // ADATTIVO
                    letterSpacing: 0.2,
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onEditToggle,
                child: Icon(
                  isEditingName ? Icons.check_circle : Icons.edit_outlined,
                  size: 18,
                  color: isEditingName
                      ? AppPalette.olive
                      : theme.colorScheme.onSurfaceVariant, // ADATTIVO
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            username,
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurfaceVariant, // ADATTIVO
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 18),

          // Divisore
          Container(
            height: 1,
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
          ), // ADATTIVO

          const SizedBox(height: 16),

          // Mini stats inline
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MiniStat(label: 'Punti', value: '1.240'),
              _VerticalDivider(),
              _MiniStat(label: 'Giorni attivi', value: '14'),
              _VerticalDivider(),
              _MiniStat(label: 'Livello', value: '4'),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: AppPalette.olive,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant, // ADATTIVO
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) => Container(
    height: 28,
    width: 1,
    color: Theme.of(
      context,
    ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
  ); // ADATTIVO
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface, // ADATTIVO
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: theme.brightness == Brightness.light
                ? color.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.2), // ADATTIVO
            blurRadius: 12,
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
                  letterSpacing: 0.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.5,
                  color: theme.colorScheme.onSurfaceVariant, // ADATTIVO
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

class _BadgesRow extends StatelessWidget {
  final List<_BadgeData> badges = const [
    _BadgeData(Icons.military_tech, 'Pioniere', AppPalette.olive),
    _BadgeData(Icons.explore, 'Esploratore', AppPalette.tan),
    _BadgeData(Icons.history_edu, 'Storico', AppPalette.moss),
    _BadgeData(
      Icons.lock_outline,
      '?',
      Colors.grey,
    ), // Usa un grigio standard per il placeholder
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: badges
          .map(
            (b) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: _BadgeTile(data: b),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  const _BadgeData(this.icon, this.label, this.color);
}

class _BadgeTile extends StatelessWidget {
  final _BadgeData data;
  const _BadgeTile({required this.data});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Logica per adattare il grigio del lucchetto al tema corrente
    final isPlaceholder = data.label == '?';
    final iconColor = isPlaceholder
        ? theme.colorScheme.onSurfaceVariant
        : data.color;

    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface, // ADATTIVO
            shape: BoxShape.circle,
            border: Border.all(
              color: iconColor.withValues(alpha: 0.35),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.brightness == Brightness.light
                    ? iconColor.withValues(alpha: 0.08)
                    : Colors.transparent, // ADATTIVO
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(data.icon, color: iconColor, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: TextStyle(
            fontSize: 10.5,
            color: theme.colorScheme.onSurfaceVariant, // ADATTIVO
            fontWeight: FontWeight.w500,
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
              color: Theme.of(context).colorScheme.onSurface, // ADATTIVO
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPickerSheet extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _AvatarPickerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // ADATTIVO

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(
                  alpha: 0.1,
                ), // ADATTIVO
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text(
            'Scegli avatar',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface, // ADATTIVO
            ),
          ),

          const SizedBox(height: 20),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: _avatarOptions.length,
            itemBuilder: (context, i) {
              final opt = _avatarOptions[i];
              final isSel = selected == i;
              return GestureDetector(
                onTap: () {
                  onSelect(i);
                  Navigator.pop(context);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: opt.background,
                    border: Border.all(
                      color: isSel ? AppPalette.olive : Colors.transparent,
                      width: 2.5,
                    ),
                    boxShadow: isSel
                        ? [
                            BoxShadow(
                              color: AppPalette.olive.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    opt.icon,
                    size: 30,
                    color: Colors.black.withValues(
                      alpha: 0.5,
                    ), // Le icone restano scure
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
