
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'injection_container.dart' as di;
import 'presentation/pages/map_page.dart';
import 'presentation/pages/auth_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Firebase

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inizializza Dependency Injection
  await di.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const GeoApp());
  runApp(const CesenaRemembersApp());
}

class GeoApp extends StatelessWidget {
  const GeoApp({super.key});
class CesenaRemembersApp extends StatelessWidget {
  const CesenaRemembersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cesena Remembers 1945',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const MapPage(), // Punta alla pagina UI estratta
      home: const AuthGate(),
    );
  }
}
}