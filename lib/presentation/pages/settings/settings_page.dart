import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../domain/usecases/auth_use_cases.dart';
import '../../../domain/usecases/user_preferences_use_cases.dart';
import '../../../domain/usecases/user_profile_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/settings_controller.dart';
import '../../controllers/settings_ui_controller.dart';
import '../../services/shell_navigation_store.dart';
import '../../theme/app_palette.dart';
import '../../theme/theme_controller.dart';
import '../credits_page.dart'; // 🔴 IMPORT DEL NUOVO FILE!

// Dichiariamo che la parte visiva dei widget si trova in questo file separato
part 'settings_page_sections.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, this.focusGpsToggle = false});

  final bool focusGpsToggle;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  // --- IL NOSTRO CONTROLLER (MOTORE) ---
  late final SettingsController _controller;
  late final SettingsUiController _uiController;

  // --- VARIABILI VISIVE (Non salvate sul DB per ora) ---
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gpsToggleKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    // INIZIALIZZAZIONE CON IL THEME CONTROLLER GLOBALE!
    _controller = SettingsController(
      signOutUseCase: sl<SignOutUseCase>(),
      deleteCurrentUserUseCase: sl<DeleteCurrentUserUseCase>(),
      profileUseCases: sl<UserProfileUseCases>(),
      preferencesUseCases: sl<UserPreferencesUseCases>(),
      themeController:
          sl<ThemeController>(), // Questo fa la magia in tempo reale
    );

    _controller.addListener(_onControllerError);
    _uiController = sl<SettingsUiController>();
    // Animazioni
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

    if (widget.focusGpsToggle) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToGpsToggle();
      });
    }

    ShellNavigationStore.focusGpsToggleInSettings.addListener(
      _onFocusGpsRequested,
    );
  }

  Future<void> _scrollToGpsToggle() async {
    final contextForGps = _gpsToggleKey.currentContext;
    if (contextForGps == null || !mounted) return;
    await Scrollable.ensureVisible(
      contextForGps,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      alignment: 0.2,
    );
  }

  void _onFocusGpsRequested() {
    if (!ShellNavigationStore.focusGpsToggleInSettings.value) return;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _scrollToGpsToggle();
      ShellNavigationStore.focusGpsToggleInSettings.value = false;
    });
  }

  void _onControllerError() {
    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppPalette.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      _controller.clearError();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerError);
    _controller.dispose();
    _uiController.dispose();
    _animCtrl.dispose();
    _scrollController.dispose();
    ShellNavigationStore.focusGpsToggleInSettings.removeListener(
      _onFocusGpsRequested,
    );
    super.dispose();
  }

  void _showInfoSheet({required String title, required String body}) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              body,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.olive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Chiudi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => _ChoiceSheet(
        title: AppLocalizations.of(context)!.languageTitle,
        options: const ['Italiano', 'English'],
        selected: _uiController.selectedLanguage,
        onSelect: _uiController.setLanguage,
      ),
    );
  }

  void _confirmDeleteAccount() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.deleteAccountDialogTitle,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Questa operazione rimuove account, progressi e dati associati in modo permanente.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
            fontSize: 15,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onSurfaceVariant,
            ),
            child: const Text(
              AppLocalizations.of(context)!.buttonCancel,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.danger,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            child: const Text(
              AppLocalizations.of(context)!.buttonDelete,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAccount() async {
    final deleted = await _controller.handleDeleteAccount();
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          deleted
              ? AppLocalizations.of(context)!.deleteAccountSuccess
              : AppLocalizations.of(context)!.deleteAccountFailure,
        ),
        backgroundColor: deleted ? AppPalette.olive : AppPalette.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showActionSheet(String title, String subtitle) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(28, 16, 28, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.olive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  AppLocalizations.of(context)!.buttonOk,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: ListenableBuilder(
        listenable: Listenable.merge([_controller, _uiController]),
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppPalette.olive),
            );
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    elevation: 0,
                    expandedHeight: 60,
                    pinned: true,
                    centerTitle: false,
                    title: Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: Text(
                        AppLocalizations.of(context)!.settingsTitle,
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w800,
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _HeaderCard(
                            title: AppLocalizations.of(context)!.settingsHeaderTitle,
                            subtitle:
                                AppLocalizations.of(context)!.settingsHeaderSubtitle,
                            icon: Icons.tour_outlined,
                          ),
                          const SizedBox(height: 32),

                          // --- CREDITI E RICONOSCIMENTI ---
                          _SectionLabel(AppLocalizations.of(context)!.sectionCredits),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.stars_rounded,
                                title: AppLocalizations.of(context)!.creditsTitle,
                                subtitle:
                                    AppLocalizations.of(context)!.creditsSubtitle,
                                accent: AppPalette.olive,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const CreditsPage(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // --- ACCOUNT ---
                          _SectionLabel(AppLocalizations.of(context)!.sectionAccount),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: _controller.isLoggingOut
                                    ? Icons.hourglass_top
                                    : Icons.logout,
                                title: AppLocalizations.of(context)!.logoutTitle,
                                subtitle: _controller.isLoggingOut
                                    ? AppLocalizations.of(context)!.loggingOut
                                    : AppLocalizations.of(context)!.logoutSubtitle,
                                accent: AppPalette.olive,
                                onTap: _controller.isLoggingOut
                                    ? () {}
                                    : _controller.handleLogout,
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: _controller.isDeletingAccount
                                    ? Icons.hourglass_top
                                    : Icons.delete_outline,
                                title: AppLocalizations.of(context)!.deleteAccountTitle,
                                subtitle: _controller.isDeletingAccount
                                    ? AppLocalizations.of(context)!.deletingAccount
                                    : AppLocalizations.of(context)!.deleteAccountSubtitle,
                                accent: AppPalette.danger,
                                onTap: _controller.isDeletingAccount
                                    ? () {}
                                    : _confirmDeleteAccount,
                                destructive: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // --- PREFERENZE APP ---
                          _SectionLabel(AppLocalizations.of(context)!.sectionPreferences),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _SwitchRow(
                                icon: Icons.notifications_active_outlined,
                                title: AppLocalizations.of(context)!.notificationsTitle,
                                subtitle: AppLocalizations.of(context)!.notificationsSubtitle,
                                accent: AppPalette.tan,
                                value: _controller.notifiche,
                                onChanged: (v) => _controller.updatePreference(
                                  newNotifiche: v,
                                ),
                              ),
                              const _ThinDivider(),
                              _SwitchRow(
                                icon: Icons.dark_mode_outlined,
                                title: AppLocalizations.of(context)!.darkModeTitle,
                                subtitle: AppLocalizations.of(context)!.darkModeSubtitle,
                                accent: AppPalette.olive,
                                value: _controller.modalitaNotte,
                                onChanged: (v) => _controller.updatePreference(
                                  newModalitaNotte: v,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // --- PRIVACY ---
                          _SectionLabel(AppLocalizations.of(context)!.sectionPrivacy),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              Container(
                                key: _gpsToggleKey,
                                child: _SwitchRow(
                                  icon: Icons.location_on_outlined,
                                  title: AppLocalizations.of(context)!.gpsTitle,
                                  subtitle: AppLocalizations.of(context)!.gpsSubtitle,
                                  accent: AppPalette.moss,
                                  value: _controller.posizione,
                                  onChanged: (v) => _controller
                                      .updatePreference(newPosizione: v),
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.privacy_tip_outlined,
                                title: AppLocalizations.of(context)!.privacyPolicyTitle,
                                subtitle: AppLocalizations.of(context)!.privacyPolicySubtitle,
                                accent: AppPalette.tan,
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    'https://cesenaremembers.pages.dev/privacy',
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // --- GENERALE ---
                          const _SectionLabel(AppLocalizations.of(context)!.sectionGeneral),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.language,
                                title: AppLocalizations.of(context)!.languageTitle,
                                subtitle: _uiController.selectedLanguage,
                                accent: AppPalette.olive,
                                onTap: _showLanguagePicker,
                              ),
                            ],
                          ),
                          const SizedBox(height: 32),

                          // --- INFO ---
                          const _SectionLabel(AppLocalizations.of(context)!.sectionInfo),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.info_outline,
                                title: AppLocalizations.of(context)!.versionTitle,
                                subtitle: '1.0.0',
                                accent: AppPalette.moss,
                                onTap: () => _showActionSheet(
                                  AppLocalizations.of(context)!.versionSheetTitle,
                                  'Build number: 1.0.0',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.description_outlined,
                                title: AppLocalizations.of(context)!.termsTitle,
                                subtitle: AppLocalizations.of(context)!.termsSubtitle,
                                accent: AppPalette.olive,
                                onTap: () => launchUrl(
                                  Uri.parse(
                                    'https://cesenaremembers.pages.dev/terms',
                                  ),
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.mail_outline,
                                title: AppLocalizations.of(context)!.contactsTitle,
                                subtitle: 'cesenaremembers@gmail.com',
                                accent: AppPalette.tan,
                                onTap: () => _showActionSheet(
                                  AppLocalizations.of(context)!.contactsTitle,
                                  'cesenaremembers@gmail.com',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 48),
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