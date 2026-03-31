import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import 'profile/widgets/profile_sections.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  int _selectedAvatarIndex = 0;
  String _displayName = 'Alessandro';
  final String _username = '@cesena_explorer_42';

  static const List<IconData> _avatarOptions = [
    Icons.person,
    Icons.military_tech,
    Icons.local_fire_department,
    Icons.shield,
    Icons.star,
    Icons.public,
  ];

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
    super.dispose();
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: List.generate(_avatarOptions.length, (index) {
            return ChoiceChip(
              selected: _selectedAvatarIndex == index,
              onSelected: (_) {
                setState(() => _selectedAvatarIndex = index);
                Navigator.pop(context);
              },
              label: Icon(_avatarOptions[index]),
            );
          }),
        ),
      ),
    );
  }

  void _editName() async {
    final controller = TextEditingController(text: _displayName);
    final value = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Modifica nome'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Salva'),
          ),
        ],
      ),
    );

    if (value != null && value.isNotEmpty) {
      setState(() => _displayName = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.cream,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: AppPalette.cream,
                elevation: 0,
                expandedHeight: 0,
                floating: true,
                snap: true,
                centerTitle: true,
                title: const Text(
                  'Il mio profilo',
                  style: TextStyle(
                    color: AppPalette.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 28),
                      ProfileHeaderSection(
                        avatar: _avatarOptions[_selectedAvatarIndex],
                        displayName: _displayName,
                        username: _username,
                        onAvatarTap: _showAvatarPicker,
                        onEditName: _editName,
                      ),
                      const SizedBox(height: 28),
                      const ProfileSectionTitle(title: 'Statistiche'),
                      const SizedBox(height: 14),
                      const ProfileStatsSection(),
                      const SizedBox(height: 28),
                      const ProfileSectionTitle(title: 'Ultimi badge'),
                      const SizedBox(height: 14),
                      const ProfileBadgesSection(),
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
