import 'package:flutter/material.dart';

import '../../../domain/usecases/auth_use_cases.dart';
import '../../../domain/usecases/user_use_cases.dart';
import '../../../injection_container.dart';
import '../../controllers/settings_controller.dart'; // Assicurati che il path sia giusto per te

// Dichiariamo che la parte visiva dei widget si trova in questo file separato
part 'settings_page_sections.dart';

// ─────────────────────────────────────────────
//  Design tokens
// ─────────────────────────────────────────────
const _cream = Color(0xFFF7F3EE);
const _warmWhite = Color(0xFFFFFFFF);
const _olive = Color(0xFF5C6B3A);
const _moss = Color(0xFF8A9E5B);
const _tan = Color(0xFFB5885A);
const _tanLight = Color(0xFFE8D4BE);
const _textDark = Color(0xFF2C2C2C);
const _textMid = Color(0xFF7A7A7A);
const _danger = Color(0xFF9C4B4B);

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

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

  String _selectedLanguage = 'Italiano';
  String _selectedTheme = 'Chiaro';
  String _notificationType = 'Solo eventi e progressi';
  String _consents = 'Minimi necessari';
  bool _offlineDownloadsEnabled = true;

  @override
  void initState() {
    super.initState();

    // Inizializziamo il cervello della pagina (SENZA GetCurrentUserUseCase, come concordato!)
    _controller = SettingsController(
      signOutUseCase: sl<SignOutUseCase>(),
      userUseCases: sl<UserUseCases>(),
    );

    _controller.addListener(_onControllerError);

    // Animazioni di Ostolani
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

  void _onControllerError() {
    if (_controller.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_controller.errorMessage!),
          backgroundColor: _danger,
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
    super.dispose();
  }

  // ─────────────────────────────────────────────
  //  METODI PER I POPUP (BOTTOM SHEETS)
  // ─────────────────────────────────────────────
  void _showInfoSheet({required String title, required String body}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: _warmWhite,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              body,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.45,
                color: _textMid,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _olive,
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
      backgroundColor: _warmWhite,
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
      backgroundColor: _warmWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => _ChoiceSheet(
        title: 'Tema',
        options: const ['Chiaro', 'Scuro', 'Sistema'],
        selected: _selectedTheme,
        onSelect: (value) => setState(() => _selectedTheme = value),
      ),
    );
  }

  void _showNotificationTypes() {
    showModalBottomSheet(
      context: context,
      backgroundColor: _warmWhite,
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
      backgroundColor: _warmWhite,
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
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _warmWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Eliminare account?',
          style: TextStyle(fontWeight: FontWeight.w700, color: _textDark),
        ),
        content: const Text(
          'Questa operazione rimuoverà account, progressi e dati associati.',
          style: TextStyle(color: _textMid, height: 1.4),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annulla'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _danger,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: _warmWhite,
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
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 14.5,
                color: _textMid,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: _olive,
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
    return Scaffold(
      backgroundColor: _cream,
      // Ascoltiamo il Controller per i cambiamenti in tempo reale
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) {
          if (_controller.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _olive),
            );
          }

          return FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: CustomScrollView(
                slivers: [
                  const SliverAppBar(
                    backgroundColor: _cream,
                    elevation: 0,
                    expandedHeight: 0,
                    floating: true,
                    snap: true,
                    centerTitle: true,
                    title: Text(
                      'Impostazioni',
                      style: TextStyle(
                        color: _textDark,
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

                          // ─────────────────────────────────────────────
                          // SEZIONE ACCOUNT
                          // ─────────────────────────────────────────────
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
                                accent: _olive,
                                onTap: _controller.isLoggingOut
                                    ? () {}
                                    : _controller.handleLogout,
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.delete_outline,
                                title: 'Elimina account',
                                subtitle: 'Rimuovi profilo e dati associati',
                                accent: _danger,
                                onTap: _confirmDeleteAccount,
                                destructive: true,
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ─────────────────────────────────────────────
                          // SEZIONE PREFERENZE APP (Collegate al DB)
                          // ─────────────────────────────────────────────
                          const _SectionLabel('Preferenze App'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _SwitchRow(
                                icon: Icons.notifications_active_outlined,
                                title: 'Notifiche',
                                subtitle: 'Ricevi avvisi su tappe e premi',
                                accent: _tan,
                                value: _controller.notifiche,
                                onChanged: (v) => _controller.updatePreference(
                                  newNotifiche: v,
                                ),
                              ),
                              const _ThinDivider(),
                              _SwitchRow(
                                icon: Icons.dark_mode_outlined,
                                title: 'Modalità Notte',
                                subtitle: 'Tema scuro per risparmiare batteria',
                                accent: _olive,
                                value: _controller.modalitaNotte,
                                onChanged: (v) => _controller.updatePreference(
                                  newModalitaNotte: v,
                                ),
                              ),
                              const _ThinDivider(),
                              _SwitchRow(
                                icon: Icons.location_on_outlined,
                                title: 'Posizione GPS',
                                subtitle: 'Necessario per esplorare la mappa',
                                accent: _moss,
                                value: _controller.posizione,
                                onChanged: (v) => _controller.updatePreference(
                                  newPosizione: v,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ─────────────────────────────────────────────
                          // SEZIONE PRIVACY
                          // ─────────────────────────────────────────────
                          const _SectionLabel('Privacy'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.privacy_tip_outlined,
                                title: 'Informativa privacy',
                                subtitle: 'Leggi come vengono trattati i dati',
                                accent: _tan,
                                onTap: () => _showInfoSheet(
                                  title: 'Informativa privacy',
                                  body:
                                      'Inserisci qui il testo o il link alla tua informativa privacy. Deve spiegare in modo chiaro quali dati raccogli, perché li usi, per quanto tempo li conservi e come l’utente può esercitare i propri diritti.',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.checklist_outlined,
                                title: 'Consensi',
                                subtitle: _consents,
                                accent: _moss,
                                onTap: _showConsentsPicker,
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.manage_accounts_outlined,
                                title: 'Autorizzazioni',
                                subtitle: _controller.posizione
                                    ? 'GPS, notifiche e permessi attivi'
                                    : 'Permessi limitati',
                                accent: _olive,
                                onTap: () => _showInfoSheet(
                                  title: 'Autorizzazioni',
                                  body:
                                      'Qui puoi indirizzare l’utente alle autorizzazioni del sistema per GPS, notifiche, fotocamera o altri permessi usati dalla tua app.',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ─────────────────────────────────────────────
                          // SEZIONE GENERALE
                          // ─────────────────────────────────────────────
                          const _SectionLabel('Generale'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.language,
                                title: 'Lingua',
                                subtitle: _selectedLanguage,
                                accent: _olive,
                                onTap: _showLanguagePicker,
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.dark_mode_outlined,
                                title: 'Tema App (Visivo)',
                                subtitle: _selectedTheme,
                                accent: _tan,
                                onTap: _showThemePicker,
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ─────────────────────────────────────────────
                          // SEZIONE DATI
                          // ─────────────────────────────────────────────
                          const _SectionLabel('Dati'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _SwitchRow(
                                icon: Icons.download_for_offline_outlined,
                                title: 'Download offline',
                                subtitle: 'Scarica mappe, testi e tappe',
                                accent: _olive,
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
                                accent: _tan,
                                onTap: () => _showActionSheet(
                                  'Cancella cache',
                                  'Qui puoi eseguire la pulizia dei file temporanei, immagini e contenuti precari salvati localmente.',
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 22),

                          // ─────────────────────────────────────────────
                          // SEZIONE INFO
                          // ─────────────────────────────────────────────
                          const _SectionLabel('Info'),
                          const SizedBox(height: 12),
                          _SettingsCard(
                            children: [
                              _ActionRow(
                                icon: Icons.info_outline,
                                title: 'Versione',
                                subtitle: '1.0.0',
                                accent: _moss,
                                onTap: () => _showActionSheet(
                                  'Versione app',
                                  'Mostra qui build number, release notes o controlli aggiornamenti.',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.description_outlined,
                                title: 'Termini di servizio',
                                subtitle: 'Regole d’uso e responsabilità',
                                accent: _olive,
                                onTap: () => _showInfoSheet(
                                  title: 'Termini di servizio',
                                  body:
                                      'Inserisci qui i tuoi termini di servizio. Per una app con tour reali è utile chiarire uso corretto, responsabilità, limiti dei contenuti storici e sicurezza durante il percorso.',
                                ),
                              ),
                              const _ThinDivider(),
                              _ActionRow(
                                icon: Icons.mail_outline,
                                title: 'Contatti',
                                subtitle: 'supporto@cesenaremembers.it',
                                accent: _tan,
                                onTap: () => _showActionSheet(
                                  'Contatti',
                                  'Qui puoi inserire email di supporto, sito web, social o modulo feedback.',
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
