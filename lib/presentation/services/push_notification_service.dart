import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import 'shell_navigation_store.dart';

class PushNotificationService {
  static Future<void> initializeAndSaveToken(BuildContext context) async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

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
            print('✅ Token FCM salvato con successo: $token');
          }
        }

        // 3. Configura i Listener per gestire le notifiche in tempo reale
        _setupNotificationListeners(context);
      } else {
        print('⚠️ L\'utente ha negato i permessi per le notifiche.');
      }
    } catch (e) {
      print('❌ Errore durante l\'inizializzazione delle notifiche: $e');
    }
  }

  static void _setupNotificationListeners(BuildContext context) {
    // ------------------------------------------------------------------
    // 1. APP APERTA (Foreground): Mostra un dialog o uno SnackBar custom
    // ------------------------------------------------------------------
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
        '🔔 Notifica ricevuta in Foreground: ${message.notification?.title}',
      );

      if (message.notification != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.people, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.notification!.title ?? '',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        message.notification!.body ?? '',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
            action: SnackBarAction(
              label: 'VAI',
              textColor: Colors.white,
              onPressed: () => _handleNotificationClick(message.data),
            ),
          ),
        );
      }
    });

    // ------------------------------------------------------------------
    // 2. APP IN BACKGROUND: L'utente clicca sulla notifica nel sistema
    // ------------------------------------------------------------------
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 Notifica cliccata da Background!');
      _handleNotificationClick(message.data);
    });

    // ------------------------------------------------------------------
    // 3. APP CHIUSA (Terminata): L'utente clicca e l'app si accende da zero
    // ------------------------------------------------------------------
    FirebaseMessaging.instance.getInitialMessage().then((
      RemoteMessage? message,
    ) {
      if (message != null) {
        print('🚀 App avviata da notifica spenta!');
        _handleNotificationClick(message.data);
      }
    });
  }

  // 🔴 LOGICA DI REINDERIZZAMENTO AUTOMATICO AL CLICK
  static void _handleNotificationClick(Map<String, dynamic> data) {
    final notificationType = data['type'];

    // Sfruttiamo lo ShellNavigationStore esistente per spostare l'utente sulla Community
    if (notificationType == 'friend_request' ||
        notificationType == 'friend_accepted') {
      print('➔ Sposto l\'utente alla scheda Community (Index 1)');
      ShellNavigationStore.goToTab(1); // Sposta l'indice sul tab SocialPage
    }
  }
}
