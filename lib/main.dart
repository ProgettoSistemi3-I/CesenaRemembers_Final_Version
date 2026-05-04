import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_palette.dart';
import 'presentation/theme/theme_controller.dart';
import 'presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await di.init();
  await di.sl<ThemeController>().initTheme();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const CesenaRemembersApp());
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
          home: const SplashScreen(),
        );
      },
    );
  }
}
