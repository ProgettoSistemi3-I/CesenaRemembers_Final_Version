import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import 'shell_navigation_store.dart';

class PushNotificationService {
  static bool _isInitialized = false;
  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<void> initializeAndSaveToken() async {
    if (_isInitialized) return;
    try {
      final messaging = FirebaseMessaging.instance;

      // 1. Richiedi i permessi all'utente
      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // 2. Prendi l'UID corrente ed estrai il Token FCM
        final profileUseCases = sl<UserProfileUseCases>();
        final uid = profileUseCases.getCurrentUserUid();

        if (uid != null) {
          String? token = await messaging.getToken();
          if (token != null) {
            await profileUseCases.saveFcmToken(uid, token);
          }
        }

        // 3. Configura i Listener per gestire le notifiche in tempo reale
        _setupNotificationListeners();
        _isInitialized = true;
      }
    } catch (_) {
      // Evitiamo log rumorosi o sensibili in produzione.
    }
  }

  static void _setupNotificationListeners() {
    // ------------------------------------------------------------------
    // 1. APP IN BACKGROUND: L'utente clicca sulla notifica nel sistema
    // ------------------------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationClick(message.data);
    });

    // ------------------------------------------------------------------
    // 2. APP CHIUSA (Terminata): L'utente clicca e l'app si accende da zero
    // ------------------------------------------------------------------
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        _handleNotificationClick(message.data);
      }
    });
  }

  static void _handleNotificationClick(Map<String, dynamic> data) {
    final notificationType = data['type'];

    if (notificationType == 'friend_request') {
      ShellNavigationStore.openFriendRequestsPanel.value = true;
      ShellNavigationStore.goToTab(2); // Apri tab Profilo
    } else if (notificationType == 'friend_accepted') {
      ShellNavigationStore.goToTab(1); // Apri tab Community
    }
  }
}
