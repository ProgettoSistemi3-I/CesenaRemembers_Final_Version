import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/services/auth_gate.dart';
import 'presentation/theme/app_palette.dart';
import 'presentation/theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  await di.sl<ThemeController>().initTheme();
  await _requestLocationPermissionOnFirstOpen();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CesenaRemembersApp());
}

Future<void> _requestLocationPermissionOnFirstOpen() async {
  if (kIsWeb) return;
  final permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    await Geolocator.requestPermission();
  }
}

class CesenaRemembersApp extends StatelessWidget {
  const CesenaRemembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = di.sl<ThemeController>();

    return ListenableBuilder(
      listenable: themeCtrl,
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cesena Remembers 1945',
          themeMode: themeCtrl.themeMode,
          theme: AppPalette.lightTheme,
          darkTheme: AppPalette.darkTheme,
          home: const AuthGate(),
        );
      },
    );
  }
}
