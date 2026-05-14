import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
    _uiController = SettingsUiController(sl<ValueNotifier<Locale>>());
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

  // ─────────────────────────────────────────────
  //  METODI PER I POPUP (BOTTOM SHEETS) ADATTIVI
  // ─────────────────────────────────────────────
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
                child: Text(
                  AppLocalizations.of(context)!.buttonClose,
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
          AppLocalizations.of(context)!.deleteAccountDialogBody,
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
            child: Text(
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
            child: Text(
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
                  'Perfetto',
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
                        'Impostazioni',
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
                          const _HeaderCard(
                            title: 'Tour interattivo WWII',
                            subtitle:
                                'Gestisci privacy, notifiche e lingua in un unico posto.',
                            icon: Icons.tour_outlined,
                          ),
                          const SizedBox(height: 32),

                          // --- CREDITI E RICONOSCIMENTI ---
                          const _SectionLabel('Crediti'),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.stars_rounded,
                                title: 'Crediti e Riconoscimenti',
                                subtitle:
                                    'Scopri il team dietro Cesena Remembers',
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
                          const _SectionLabel('Account'),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: _controller.isLoggingOut
                                    ? Icons.hourglass_top
                                    : Icons.logout,
                                title: 'Logout',
                                subtitle: _controller.isLoggingOut
                                    ? 'Uscita in corso...'
                                    : 'Esci dall’account corrente',
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
                                title: 'Elimina account',
                                subtitle: _controller.isDeletingAccount
                                    ? 'Eliminazione in corso...'
                                    : 'Rimuovi profilo e dati associati',
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
                          const _SectionLabel('Preferenze App'),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _SwitchRow(
                                icon: Icons.notifications_active_outlined,
                                title: 'Notifiche',
                                subtitle: 'Ricevi avvisi su tappe e premi',
                                accent: AppPalette.tan,
                                value: _controller.notifiche,
                                onChanged: (v) => _controller.updatePreference(
                                  newNotifiche: v,
                                ),
                              ),
                              const _ThinDivider(),
                              _SwitchRow(
                                icon: Icons.dark_mode_outlined,
                                title: 'Modalità Notte',
                                subtitle: 'Tema scuro per l\'intera app',
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
                          const _SectionLabel('Privacy'),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              Container(
                                key: _gpsToggleKey,
                                child: _SwitchRow(
                                  icon: Icons.location_on_outlined,
                                  title: 'Posizione GPS',
                                  subtitle: 'Necessario per esplorare la mappa',
                                  accent: AppPalette.moss,
                                  value: _controller.posizione,
                                  onChanged: (v) => _controller
                                      .updatePreference(newPosizione: v),
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Informativa privacy',
                                subtitle: 'Leggi come vengono trattati i dati',
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
                          const _SectionLabel('Generale'),
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
                          const _SectionLabel('Info'),
                          const SizedBox(height: 16),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.info_outline,
                                title: 'Versione',
                                subtitle: '1.0.0',
                                accent: AppPalette.moss,
                                onTap: () => _showActionSheet(
                                  'Versione app',
                                  'Build number: 1.0.0',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.description_outlined,
                                title: 'Termini di servizio',
                                subtitle: 'Regole d’uso e responsabilità',
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
                                title: 'Contatti',
                                subtitle: 'cesenaremembers@gmail.com',
                                accent: AppPalette.tan,
                                onTap: () => _showActionSheet(
                                  'Contatti',
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

// ─────────────────────────────────────────────
//  NUOVA PAGINA DEDICATA AI CREDITI
// ─────────────────────────────────────────────
class CreditsPage extends StatelessWidget {
  const CreditsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Riconoscimenti',
          style: TextStyle(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Header decorativo con l'icona della vostra app
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.olive.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Cesena Remembers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Realizzato con passione per preservare la memoria storica della nostra città.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 48),

          // Sviluppatori con Link a GitHub
          const _SectionLabel('Il Team'),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              _ActionRow(
                icon: Icons.code_rounded,
                title: 'Lorenzo Ostolani',
                subtitle: 'Sviluppo & Architettura',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/lorenzoostolani'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
              const _ThinDivider(),
              _ActionRow(
                icon: Icons.code_rounded,
                title: 'Luca Bazzocchi',
                subtitle: 'Sviluppo & Architettura',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://github.com/ilMastroDeiBug'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Ringraziamenti statici (Senza freccine di navigazione)
          const _SectionLabel('Ringraziamenti'),
          const SizedBox(height: 16),
          _SettingsCard(
            children: [
              const _StaticCreditRow(
                icon: Icons.school_outlined,
                title: 'Prof. David Veneti',
                subtitle: 'Docente Referente',
                accent: AppPalette.moss,
              ),
              const _ThinDivider(),
              const _StaticCreditRow(
                icon: Icons.groups_outlined,
                title: 'Classe 3I',
                subtitle: 'Supporto e Ideazione',
                accent: AppPalette.tan,
              ),
              const _ThinDivider(),
              _ActionRow(
                icon: Icons.account_balance_outlined,
                title: 'ITT Blaise Pascal',
                subtitle: 'Visita il sito web dell\'istituto',
                accent: AppPalette.olive,
                onTap: () => launchUrl(
                  Uri.parse('https://www.ispascalcomandini.it/'),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  WIDGET PRIVATO PER RIGHE STATICHE SENZA FRECCIA
// ─────────────────────────────────────────────
class _StaticCreditRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;

  const _StaticCreditRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
