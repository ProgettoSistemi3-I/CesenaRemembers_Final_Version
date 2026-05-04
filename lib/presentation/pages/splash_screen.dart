import 'package:flutter/material.dart';
import '../services/auth_gate.dart'; // Assicurati che il percorso sia corretto!

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Impostiamo l'animazione a 1.5 secondi
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Effetto di ingrandimento fluido
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    // Effetto di dissolvenza (appare gradualmente)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    // Fai partire l'animazione
    _animationController.forward();

    // Aspetta 2.5 secondi totali, poi vai all'AuthGate
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        // pushReplacement "distrugge" lo splash screen, così l'utente non può tornarci premendo "Indietro"
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const AuthGate(),
            transitionsBuilder: (_, animation, __, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              ); // Transizione sfumata
            },
            transitionDuration: const Duration(milliseconds: 800),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sfondo nero pece
      body: Center(
        // Combiniamo il Fade (dissolvenza) e lo Scale (ingrandimento)
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Image.asset(
              'assets/icon/app_icon.png', // Il tuo logo
              width: 250, // Regola la grandezza come preferisci
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
