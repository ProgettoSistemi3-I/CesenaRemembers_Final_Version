import 'package:flutter/material.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../injection_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _signOut = sl<SignOutUseCase>();

  bool _notifiche = true;
  bool _modalitaNotte = false;
  bool _posizione = true;
  bool _isLoggingOut = false;

  Future<void> _handleLogout() async {
    setState(() => _isLoggingOut = true);
    try {
      await _signOut();
      // AuthGate reagisce automaticamente allo stream
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout fallito: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      /*appBar: AppBar(
        leading: const Icon(
          Icons.arrow_back,
          color: Color.fromARGB(255, 73, 120, 89),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(color: Color.fromARGB(255, 73, 120, 89)),
        ),
        backgroundColor: Color.fromARGB(255, 73, 120, 89),
        elevation: 0,
      ),*/
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Account'),
              _buildNavTile(
                label: 'Modifica Profilo',
                icon: Icons.person_outline,
                color: Color.fromARGB(255, 73, 120, 89),
                onTap: () {},
              ),
              _buildNavTile(
                label: 'Cambia Password',
                icon: Icons.lock_outline,
                color: Color.fromARGB(255, 73, 120, 89),
                onTap: () {},
              ),
              _buildNavTile(
                label: 'Email',
                icon: Icons.email_outlined,
                color: Color.fromARGB(255, 73, 120, 89),
                onTap: () {},
              ),

              const SizedBox(height: 25),
              _buildSectionTitle('Preferenze'),
              _buildToggleTile(
                label: 'Notifiche',
                icon: Icons.notifications_outlined,
                color: Color.fromARGB(255, 43, 59, 84),
                value: _notifiche,
                onChanged: (v) => setState(() => _notifiche = v),
              ),
              _buildToggleTile(
                label: 'Modalità Notte',
                icon: Icons.dark_mode_outlined,
                color: Color.fromARGB(255, 43, 59, 84),
                value: _modalitaNotte,
                onChanged: (v) => setState(() => _modalitaNotte = v),
              ),
              _buildToggleTile(
                label: 'Posizione GPS',
                icon: Icons.location_on_outlined,
                color: Color.fromARGB(255, 43, 59, 84),
                value: _posizione,
                onChanged: (v) => setState(() => _posizione = v),
              ),

              const SizedBox(height: 25),
              _buildSectionTitle('Altro'),
              _buildNavTile(
                label: 'Privacy Policy',
                icon: Icons.shield_outlined,
                color: Color.fromARGB(255, 35, 35, 35),
                onTap: () {},
              ),
              _buildNavTile(
                label: 'Termini di Servizio',
                icon: Icons.description_outlined,
                color: Color.fromARGB(255, 35, 35, 35),
                onTap: () {},
              ),
              _buildNavTile(
                label: 'Versione App',
                icon: Icons.info_outline,
                color: Color.fromARGB(255, 35, 35, 35),
                trailing: const Text(
                  'v1.0.0',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                onTap: () {},
              ),

              const SizedBox(height: 25),
              // Logout button
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 15),
                child: OutlinedButton.icon(
                  onPressed: _isLoggingOut ? null : _handleLogout,
                  icon: _isLoggingOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.logout, color: Colors.red),
                  label: Text(
                    _isLoggingOut ? 'Uscita in corso...' : 'Logout',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            trailing ??
                Icon(Icons.chevron_right, color: color.withOpacity(0.6)),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required String label,
    required IconData icon,
    required Color color,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(width: 15),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          Switch(value: value, onChanged: onChanged, activeThumbColor: color),
        ],
      ),
    );
  }
}
