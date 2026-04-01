import 'package:flutter/material.dart';

part 'profile/profile_page_sections.dart';

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
//  Design tokens
// ─────────────────────────────────────────────
const _cream = Color(0xFFF7F3EE); // sfondo principale
const _warmWhite = Color(0xFFFFFFFF);
const _olive = Color(0xFF5C6B3A); // verde oliva – accento primario
const _moss = Color(0xFF8A9E5B); // verde chiaro
const _tan = Color(0xFFB5885A); // marrone/arancione – accento secondario
const _tanLight = Color(0xFFE8D4BE); // tan chiarissimo per superfici
const _textDark = Color(0xFF2C2C2C);
const _textMid = Color(0xFF7A7A7A);

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
      backgroundColor: _warmWhite,
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
      backgroundColor: _cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              // ── App bar
              SliverAppBar(
                backgroundColor: _cream,
                elevation: 0,
                expandedHeight: 0,
                floating: true,
                snap: true,
                title: const Text(
                  'Il mio profilo',
                  style: TextStyle(
                    color: _textDark,
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
                            color: _olive,
                          ),
                          _StatCard(
                            icon: Icons.emoji_events_outlined,
                            label: 'Classifica',
                            value: '# 1',
                            color: _tan,
                          ),
                          _StatCard(
                            icon: Icons.location_on_outlined,
                            label: 'Siti Visitati',
                            value: '67',
                            color: _moss,
                          ),
                          _StatCard(
                            icon: Icons.quiz_outlined,
                            label: 'Quiz Superati',
                            value: '34',
                            color: _tan,
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
