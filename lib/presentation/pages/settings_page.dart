import 'package:flutter/material.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../injection_container.dart';
import '../theme/app_palette.dart';
import 'settings/widgets/settings_sections.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  final _signOut = sl<SignOutUseCase>();

  bool _isLoggingOut = false;
  bool _notificationsEnabled = true;
  bool _offlineDownloadsEnabled = true;
  String _selectedLanguage = 'Italiano';
  String _selectedTheme = 'Chiaro';

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

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _signOut();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout fallito: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  void _showInfo(String title, String body) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppPalette.warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppPalette.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(color: AppPalette.textMid, height: 1.45),
            ),
          ],
        ),
      ),
    );
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
                  'Impostazioni',
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
                      const SizedBox(height: 18),
                      const SettingsSectionTitle(title: 'Account'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsActionRow(
                            icon: _isLoggingOut
                                ? Icons.hourglass_top
                                : Icons.logout,
                            title: 'Logout',
                            subtitle: _isLoggingOut
                                ? 'Uscita in corso...'
                                : 'Esci dall’account corrente',
                            onTap: _isLoggingOut ? () {} : _handleLogout,
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SettingsSectionTitle(title: 'Privacy'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsActionRow(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Informativa privacy',
                            subtitle: 'Gestione dati e trattamento',
                            onTap: () => _showInfo(
                              'Informativa privacy',
                              'Questa sezione descrive quali dati vengono raccolti e perché.',
                            ),
                          ),
                          const SettingsDivider(),
                          SettingsActionRow(
                            icon: Icons.description_outlined,
                            title: 'Termini di servizio',
                            subtitle: 'Regole d’uso della piattaforma',
                            onTap: () => _showInfo(
                              'Termini di servizio',
                              'Uso corretto, responsabilità e sicurezza durante il percorso.',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SettingsSectionTitle(title: 'Notifiche'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsSwitchRow(
                            icon: Icons.notifications_active_outlined,
                            title: 'Attiva notifiche',
                            subtitle: 'Avvisi su tappe, premi e missioni',
                            value: _notificationsEnabled,
                            onChanged: (value) =>
                                setState(() => _notificationsEnabled = value),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SettingsSectionTitle(title: 'Generale'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsActionRow(
                            icon: Icons.language,
                            title: 'Lingua',
                            subtitle: _selectedLanguage,
                            onTap: () {
                              setState(() => _selectedLanguage =
                                  _selectedLanguage == 'Italiano'
                                      ? 'English'
                                      : 'Italiano');
                            },
                          ),
                          const SettingsDivider(),
                          SettingsActionRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Tema',
                            subtitle: _selectedTheme,
                            onTap: () {
                              setState(() => _selectedTheme =
                                  _selectedTheme == 'Chiaro'
                                      ? 'Scuro'
                                      : 'Chiaro');
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SettingsSectionTitle(title: 'Dati'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsSwitchRow(
                            icon: Icons.download_for_offline_outlined,
                            title: 'Download offline',
                            subtitle: 'Scarica mappe e contenuti',
                            value: _offlineDownloadsEnabled,
                            onChanged: (value) => setState(
                              () => _offlineDownloadsEnabled = value,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      const SettingsSectionTitle(title: 'Info'),
                      const SizedBox(height: 12),
                      SettingsCard(
                        children: [
                          SettingsActionRow(
                            icon: Icons.info_outline,
                            title: 'Versione',
                            subtitle: '1.0.0',
                            onTap: () {},
                          ),
                          const SettingsDivider(),
                          SettingsActionRow(
                            icon: Icons.mail_outline,
                            title: 'Contatti',
                            subtitle: 'supporto@cesenaremembers.it',
                            onTap: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 36),
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
