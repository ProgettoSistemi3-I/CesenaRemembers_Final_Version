import 'package:flutter/material.dart';

import '../../../domain/usecases/auth_use_cases.dart';
import '../../../domain/usecases/user_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/settings_controller.dart';
import '../../theme/app_palette.dart';
import '../../theme/theme_controller.dart'; // Import fondamentale per il tema dinamico

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

  // --- VARIABILI VISIVE (Non salvate sul DB per ora) ---
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _gpsToggleKey = GlobalKey();

  String _selectedLanguage = 'Italiano';
  String _selectedTheme =
      'Sistema'; // Aggiornato per riflettere il tema globale
  String _notificationType = 'Solo eventi e progressi';
  String _consents = 'Minimi necessari';
  bool _offlineDownloadsEnabled = true;

  @override
  void initState() {
    super.initState();

    // INIZIALIZZAZIONE CON IL THEME CONTROLLER GLOBALE!
    _controller = SettingsController(
      signOutUseCase: sl<SignOutUseCase>(),
      userUseCases: sl<UserUseCases>(),
      themeController:
          sl<ThemeController>(), // Questo fa la magia in tempo reale
    );

    _controller.addListener(_onControllerError);

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

  void _onControllerError() {
    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: AppPalette.danger,
        ),
      );
      _controller.clearError();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerError);
    _controller.dispose();
    _animCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  METODI PER I POPUP (BOTTOM SHEETS) ADATTIVI
  // ─────────────────────────────────────────────
  void _showInfoSheet({required String title, required String body}) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface, // ADATTIVO!
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.olive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ChoiceSheet(
        title: 'Lingua',
        options: const ['Italiano', 'English', 'Français', 'Deutsch'],
        selected: _selectedLanguage,
        onSelect: (value) => setState(() => _selectedLanguage = value),
      ),
    );
  }

  void _showThemePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ChoiceSheet(
        title: 'Tema App (Visivo)',
        options: const ['Sistema', 'Chiaro', 'Scuro'],
        selected: _selectedTheme,
        onSelect: (value) => setState(() => _selectedTheme = value),
      ),
    );
  }

  void _showNotificationTypes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ChoiceSheet(
        title: 'Tipi notifiche',
        options: const [
          'Tutte',
          'Solo eventi importanti',
          'Solo eventi e progressi',
          'Nessuna promozione',
        ],
        selected: _notificationType,
        onSelect: (value) => setState(() => _notificationType = value),
      ),
    );
  }

  void _showConsentsPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ChoiceSheet(
        title: 'Consensi',
        options: const [
          'Minimi necessari',
          'Statistiche anonime',
          'Statistiche + personalizzazione',
        ],
        selected: _consents,
        onSelect: (value) => setState(() => _consents = value),
      ),
    );
  }

  void _confirmDeleteAccount() {
    final theme = Theme.of(context);
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          'Eliminare account?',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        content: Text(
          'Questa operazione rimuoverà account, progressi e dati associati.',
          style: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppPalette.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Eliminazione account avviata')),
              );
            },
            child: const Text('Elimina'),
          ),
        ],
      ),
    );
  }

  void _showActionSheet(String title, String subtitle) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14.5,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.olive,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Perfetto'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // Recuperiamo il tema attuale

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ADATTIVO!
      body: ListenableBuilder(
        listenable: _controller,
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
                slivers: [
                  SliverAppBar(
                    backgroundColor: theme.scaffoldBackgroundColor, // ADATTIVO
                    elevation: 0,
                    expandedHeight: 0,
                    floating: true,
                    snap: true,
                    centerTitle: true,
                    title: Text(
                      'Impostazioni',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface, // ADATTIVO
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
                          const _HeaderCard(
                            title: 'Tour interattivo WWII',
                            subtitle:
                                'Gestisci privacy, notifiche, lingua e dati offline in un unico posto.',
                            icon: Icons.tour_outlined,
                          ),
                          const SizedBox(height: 24),

                          // --- ACCOUNT ---
                          const _SectionLabel('Account'),
                          const SizedBox(height: 12),
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
                                icon: Icons.delete_outline,
                                title: 'Elimina account',
                                subtitle: 'Rimuovi profilo e dati associati',
                                accent: AppPalette.danger,
                                onTap: _confirmDeleteAccount,
                                destructive: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- PREFERENZE APP ---
                          const _SectionLabel('Preferenze App'),
                          const SizedBox(height: 12),
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
                              // Posizione GPS spostata da qui
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- PRIVACY ---
                          const _SectionLabel('Privacy'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              // Posizione GPS inserita qui
                              Container(
                                key: _gpsToggleKey,
                                child: _SwitchRow(
                                  icon: Icons.location_on_outlined,
                                  title: 'Posizione GPS',
                                  subtitle:
                                      'Necessario per esplorare la mappa',
                                  accent: AppPalette.moss,
                                  value: _controller.posizione,
                                  onChanged: (v) =>
                                      _controller.updatePreference(
                                        newPosizione: v,
                                      ),
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Informativa privacy',
                                subtitle: 'Leggi come vengono trattati i dati',
                                accent: AppPalette.tan,
                                onTap: () => _showInfoSheet(
                                  title: 'Informativa privacy',
                                  body:
                                      'Inserisci qui il testo o il link alla tua informativa privacy.',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.checklist_outlined,
                                title: 'Consensi',
                                subtitle: _consents,
                                accent: AppPalette.moss,
                                onTap: _showConsentsPicker,
                              ),
                              // Autorizzazioni rimossa!
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- GENERALE ---
                          const _SectionLabel('Generale'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.language,
                                title: 'Lingua',
                                subtitle: _selectedLanguage,
                                accent: AppPalette.olive,
                                onTap: _showLanguagePicker,
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.color_lens_outlined,
                                title: 'Stile Icone',
                                subtitle: _selectedTheme,
                                accent: AppPalette.tan,
                                onTap: _showThemePicker,
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- DATI ---
                          const _SectionLabel('Dati'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _SwitchRow(
                                icon: Icons.download_for_offline_outlined,
                                title: 'Download offline',
                                subtitle: 'Scarica mappe, testi e tappe',
                                accent: AppPalette.olive,
                                value: _offlineDownloadsEnabled,
                                onChanged: (v) => setState(
                                  () => _offlineDownloadsEnabled = v,
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.cleaning_services_outlined,
                                title: 'Cancella cache',
                                subtitle: 'Libera spazio occupato',
                                accent: AppPalette.tan,
                                onTap: () => _showActionSheet(
                                  'Cancella cache',
                                  'Vuoi eseguire la pulizia dei file temporanei?',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 22),

                          // --- INFO ---
                          const _SectionLabel('Info'),
                          const SizedBox(height: 12),
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
                                onTap: () => _showInfoSheet(
                                  title: 'Termini di servizio',
                                  body: 'Testo dei termini di servizio...',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.mail_outline,
                                title: 'Contatti',
                                subtitle: 'supporto@cesenaremembers.it',
                                accent: AppPalette.tan,
                                onTap: () => _showActionSheet(
                                  'Contatti',
                                  'supporto@cesenaremembers.it',
                                ),
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
          );
        },
      ),
    );
  }
}
