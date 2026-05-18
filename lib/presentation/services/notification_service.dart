import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/usecases/user_profile_use_cases.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init(UserProfileUseCases profileUseCases, String uid) async {
    if (_initialized) return;

    // Initialization settings for Android local notifications (foreground)
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestSoundPermission: true,
          requestBadgePermission: true,
          requestAlertPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle foreground notification tap
      },
    );

    await requestPermissions();

    // Ottieni il token FCM
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await profileUseCases.saveFcmToken(uid, fcmToken);
      }

      // Ascolta l'aggiornamento del token
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        profileUseCases.saveFcmToken(uid, newToken);
      });
    } catch (_) {
      // Evitiamo log rumorosi o sensibili in produzione.
    }

    // Gestione notifiche Push ricevute mentre l'app è in FOREGROUND
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        showLocalNotification(
          message.notification!.title ?? 'Notifica',
          message.notification!.body ?? '',
        );
      }
    });

    _initialized = true;
  }

  Future<void> requestPermissions() async {
    // Richiedi permesso FCM (importante specialmente su iOS)
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Permessi standard FlutterLocalNotifications
    await Permission.notification.request();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> showLocalNotification(String title, String body) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'social_channel',
          'Social Notifications',
          channelDescription:
              'Notifiche per le interazioni sociali come richieste di amicizia',
          importance: Importance.high,
          priority: Priority.high,
          ticker: 'ticker',
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails();

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  // Questo serve solo per testare il flusso o in fallback se il backend ritarda
  Future<void> showFriendRequestNotification(int newRequestsCount) async {
    await showLocalNotification(
      'Nuova richiesta di amicizia',
      'Hai ricevuto $newRequestsCount nuov${newRequestsCount > 1 ? 'e' : 'a'} richiest${newRequestsCount > 1 ? 'e' : 'a'} di amicizia!',
    );
  }
}
