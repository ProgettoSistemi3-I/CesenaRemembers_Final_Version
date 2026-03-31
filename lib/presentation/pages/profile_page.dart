import 'package:flutter/material.dart';

import '../theme/app_palette.dart';

// ─────────────────────────────────────────────
//  Avatar options
// ─────────────────────────────────────────────
const List<_AvatarOption> _avatarOptions = [
  _AvatarOption(Icons.person, Color(0xFFEEEEEE)),
  _AvatarOption(Icons.military_tech, Color(0xFFFFECB3)),
  _AvatarOption(Icons.local_fire_department, Color(0xFFFFCDD2)),
  _AvatarOption(Icons.bolt, Color(0xFFFFF9C4)),
  _AvatarOption(Icons.shield, Color(0xFFBBDEFB)),
  _AvatarOption(Icons.star, Color(0xFFC8E6C9)),
  _AvatarOption(Icons.emoji_events, Color(0xFFE1BEE7)),
  _AvatarOption(Icons.public, Color(0xFFB2EBF2)),
  _AvatarOption(Icons.psychology, Color(0xFFD7CCC8)),
  _AvatarOption(Icons.auto_awesome, Color(0xFFF8BBD0)),
];

class _AvatarOption {
  final IconData icon;
  final Color background;
  const _AvatarOption(this.icon, this.background);
}

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
  final TextEditingController _nameController = TextEditingController(
    text: 'Alessandro',
  );

  // username non modificabile dall'utente (generato dal sistema)
  final String _username = '@cesena_explorer_42';

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

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
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ── Avatar picker ─────────────────────────
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _AvatarPickerSheet(
        selected: _selectedAvatarIndex,
        onSelect: (i) => setState(() => _selectedAvatarIndex = i),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _avatarOptions[_selectedAvatarIndex];

    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── App bar
              SliverAppBar(
                backgroundColor: AppPalette.cream,
                elevation: 0,
                expandedHeight: 0,
                floating: true,
                snap: true,
                title: const Text(
                  'Il mio profilo',
                  style: TextStyle(
                    color: AppPalette.textDark,
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
                        username: _username,
                        onAvatarTap: _showAvatarPicker,
                        onEditToggle: () =>
                            setState(() => _isEditingName = !_isEditingName),
                      ),

                      const SizedBox(height: 28),

                      // ── Divisore sezione stats
                      _SectionLabel('Statistiche'),

                      const SizedBox(height: 14),

                      // ── Stats grid 2×2
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.55,
                        children: const [
                          _StatCard(
                            icon: Icons.verified_user_outlined,
                            label: 'Traguardi',
                            value: '3 / 11',
                            color: AppPalette.olive,
                          ),
                          _StatCard(
                            icon: Icons.emoji_events_outlined,
                            label: 'Classifica',
                            value: '# 1',
                            color: AppPalette.tan,
                          ),
                          _StatCard(
                            icon: Icons.location_on_outlined,
                            label: 'Siti Visitati',
                            value: '67',
                            color: AppPalette.moss,
                          ),
                          _StatCard(
                            icon: Icons.quiz_outlined,
                            label: 'Quiz Superati',
                            value: '34',
                            color: AppPalette.tan,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // ── Divisore sezione badges
                      _SectionLabel('Ultimi badge'),

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
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Hero card
// ─────────────────────────────────────────────
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppPalette.tan.withOpacity(0.08),
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
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
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
                      color: Colors.black.withOpacity(0.5),
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppPalette.textDark,
                      letterSpacing: 0.2,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppPalette.olive.withOpacity(0.4)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: AppPalette.olive, width: 1.5),
                      ),
                    ),
                  ),
                )
              else
                Text(
                  nameController.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppPalette.textDark,
                    letterSpacing: 0.2,
                  ),
                ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onEditToggle,
                child: Icon(
                  isEditingName ? Icons.check_circle : Icons.edit_outlined,
                  size: 18,
                  color: isEditingName ? AppPalette.olive : AppPalette.textMid,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            username,
            style: const TextStyle(
              fontSize: 13,
              color: AppPalette.textMid,
              letterSpacing: 0.3,
            ),
          ),

          const SizedBox(height: 18),

          // Divisore
          Container(height: 1, color: AppPalette.tanLight),

          const SizedBox(height: 16),

          // Mini stats inline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: const [
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
          style: const TextStyle(
            fontSize: 11,
            color: AppPalette.textMid,
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
  Widget build(BuildContext context) =>
      Container(height: 28, width: 1, color: AppPalette.tanLight);
}

// ─────────────────────────────────────────────
//  Stat card
// ─────────────────────────────────────────────
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.07),
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
              color: color.withOpacity(0.12),
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
                style: const TextStyle(
                  fontSize: 11.5,
                  color: AppPalette.textMid,
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

// ─────────────────────────────────────────────
//  Badges row
// ─────────────────────────────────────────────
class _BadgesRow extends StatelessWidget {
  final List<_BadgeData> badges = const [
    _BadgeData(Icons.military_tech, 'Pioniere', AppPalette.olive),
    _BadgeData(Icons.explore, 'Esploratore', AppPalette.tan),
    _BadgeData(Icons.history_edu, 'Storico', AppPalette.moss),
    _BadgeData(Icons.lock_outline, '?', AppPalette.textMid),
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
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppPalette.warmWhite,
            shape: BoxShape.circle,
            border: Border.all(color: data.color.withOpacity(0.35), width: 2),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Icon(data.icon, color: data.color, size: 26),
        ),
        const SizedBox(height: 6),
        Text(
          data.label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppPalette.textMid,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Section label
// ─────────────────────────────────────────────
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
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppPalette.textDark,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Avatar picker bottom sheet
// ─────────────────────────────────────────────
class _AvatarPickerSheet extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _AvatarPickerSheet({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
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
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          const Text(
            'Scegli avatar',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppPalette.textDark,
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
                              color: AppPalette.olive.withOpacity(0.25),
                              blurRadius: 8,
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    opt.icon,
                    size: 30,
                    color: Colors.black.withOpacity(0.5),
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
