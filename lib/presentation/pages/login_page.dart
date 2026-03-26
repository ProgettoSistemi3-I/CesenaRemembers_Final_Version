import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../domain/usecases/auth_use_cases.dart';
import '../../injection_container.dart';

const String _googleLogoSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
  <path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/>
  <path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/>
  <path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/>
  <path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.18 1.48-4.97 2.31-8.16 2.31-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/>
  <path fill="none" d="M0 0h48v48H0z"/>
</svg>
''';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final _signInWithGoogle = sl<SignInWithGoogleUseCase>();

  bool _isLoading = false;
  String? _error;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      await _signInWithGoogle();
    } catch (e) {
      setState(() => _error = 'Errore durante il login: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final double sh = size.height;
    final double sw = size.width;

    // Scala basata sull'altezza per mantenere le proporzioni verticali
    final double scale = (sh / 844).clamp(0.7, 1.2);

    final double titleSize = 48 * scale;
    final double iconSize = 42 * scale;
    final double spacingLg = 50 * scale;
    final double hPadding =
        sw * 0.12; // Padding laterale proporzionale alla larghezza

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. IMMAGINE DI SFONDO FULL SCREEN
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1200&auto=format&fit=crop',
              fit: BoxFit.cover,
              color: Colors.black.withOpacity(0.65),
              colorBlendMode: BlendMode.darken,
              errorBuilder: (_, __, ___) =>
                  Container(color: const Color(0xFF1A1A1A)),
            ),
          ),

          // 2. GRADIENTE VIGNETTE (Migliora la leggibilità)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [Colors.transparent, Colors.black.withOpacity(0.9)],
                  radius: 1.2,
                  center: Alignment.center,
                ),
              ),
            ),
          ),

          // 3. CONTENUTO ADATTIVO
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const Spacer(
                        flex: 3,
                      ), // Spinge il contenuto verso il centro/alto
                      // Emblema
                      Container(
                        padding: EdgeInsets.all(16 * scale),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFD32F2F),
                            width: 1.5,
                          ),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: Icon(
                          Icons.military_tech,
                          size: iconSize,
                          color: const Color(0xFFD32F2F),
                        ),
                      ),

                      SizedBox(height: 20 * scale),

                      // Titolo
                      Text(
                        "CESENA\n1945",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6.0,
                          color: Colors.white,
                          height: 0.9,
                        ),
                      ),

                      const Spacer(flex: 2),

                      // Bottone Google
                      if (_isLoading)
                        const CircularProgressIndicator(
                          color: Color(0xFFD32F2F),
                        )
                      else
                        _buildGoogleButton(scale, sw),

                      // Messaggio di Errore
                      if (_error != null) _buildErrorWidget(scale),

                      const Spacer(flex: 1),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(double scale, double sw) {
    return Container(
      width: double.infinity,
      height: 55 * scale,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8), // Look più "militare"/serio
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        onPressed: _handleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(_googleLogoSvg, height: 22 * scale),
            const SizedBox(width: 12),
            Text(
              "ACCEDI CON GOOGLE",
              style: TextStyle(
                fontSize: 14 * scale,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(double scale) {
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Text(
        _error!,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.redAccent, fontSize: 12 * scale),
      ),
    );
  }
}
