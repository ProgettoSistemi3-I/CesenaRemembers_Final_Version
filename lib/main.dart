import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/theme/app_palette.dart';
import 'presentation/theme/theme_controller.dart';
import 'presentation/pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final bootstrapResult = await AppBootstrap.run();
  if (!bootstrapResult.success) {
    runApp(BootstrapErrorApp(errorMessage: bootstrapResult.message));
    return;
  }

  runApp(const CesenaRemembersApp());
}

class AppBootstrapResult {
  const AppBootstrapResult.success() : success = true, message = null;
  const AppBootstrapResult.failure(this.message) : success = false;

  final bool success;
  final String? message;
}

class AppBootstrap {
  const AppBootstrap._();

  static Future<AppBootstrapResult> run() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      await di.init();
      await di.sl<ThemeController>().initTheme();

      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      return const AppBootstrapResult.success();
    } catch (e) {
      return AppBootstrapResult.failure(e.toString());
    }
  }
}

class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, this.errorMessage});

  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 54, color: AppPalette.danger),
                const SizedBox(height: 16),
                const Text(
                  'Initialization error',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMessage ?? 'Unable to start application.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CesenaRemembersApp extends StatelessWidget {
  const CesenaRemembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeCtrl = di.sl<ThemeController>();
    final localeNotifier = di.sl<ValueNotifier<Locale>>();

    return ListenableBuilder(
      listenable: Listenable.merge([themeCtrl, localeNotifier]),
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Cesena Remembers 1945',
          themeMode: themeCtrl.themeMode,
          theme: AppPalette.lightTheme,
          darkTheme: AppPalette.darkTheme,
          locale: localeNotifier.value,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const SplashScreen(),
        );
      },
    );
  }
}
