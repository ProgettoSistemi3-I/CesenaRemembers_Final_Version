import 'package:flutter/material.dart';
import '../pages/map/map_page.dart';
import '../pages/profile/profile_page.dart';
import '../pages/settings/settings_page.dart';
import 'shell_navigation_store.dart';
import '../pages/social/social_page.dart';

// 🔴 IMPORT AGGIUNTI PER LE NOTIFICHE E LA CLEAN ARCHITECTURE
import 'push_notification_service.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  // Le pagine vengono mantenute in vita (non ricostruite ad ogni switch)
  final List<Widget> _pages = const [
    MapPage(),
    SocialPage(),
    ProfilePage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    ShellNavigationStore.tabIndex.addListener(_onTabIndexChanged);

    // 🔴 AGGIUNTA LA LOGICA DELLE NOTIFICHE ALL'AVVIO
    _initializeNotifications();
  }

  // 🔴 ESTRATTO IN UN METODO PER MANTENERE IL CODICE PULITO
  void _initializeNotifications() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🔴 Passiamo il context al servizio così può gestire la UI
      PushNotificationService.initializeAndSaveToken(context);
    });
  }

  @override
  void dispose() {
    ShellNavigationStore.tabIndex.removeListener(_onTabIndexChanged);
    super.dispose();
  }

  void _onTabIndexChanged() {
    if (!mounted) return;
    setState(() => _currentIndex = ShellNavigationStore.tabIndex.value);
  }

  void _onTapBottomBar(int index) {
    ShellNavigationStore.goToTab(index);
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTapBottomBar,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            activeIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Community',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events_outlined),
            activeIcon: Icon(Icons.emoji_events),
            label: 'Profilo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Impostazioni',
          ),
        ],
      ),
    );
  }
}
