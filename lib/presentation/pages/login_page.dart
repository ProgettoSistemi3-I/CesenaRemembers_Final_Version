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

// ─────────────────────────────────────────────
//  Palette coerente con il resto dell'capp
// ─────────────────────────────────────────────
const _cream = Color(0xFFF7F3EE);
const _warmWhite = Color(0xFFFFFFFF);
const _olive = Color(0xFF5C6B3A);
const _moss = Color(0xFF8A9E5B);
const _tan = Color(0xFFB5885A);
const _tanLight = Color(0xFFE8D4BE);
const _textDark = Color(0xFF2C2C2C);
const _textMid = Color(0xFF7A7A7A);

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
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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
      if (!mounted) return;
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

    final double scale = (sh / 844).clamp(0.75, 1.3);

    final double titleSize = 52 * scale;
    final double iconSize = 48 * scale;
    final double iconPad = 16 * scale;
    final double spacingLg = 60 * scale;
    final double spacingMd = 24 * scale;
    final double spacingSm = 16 * scale;
    final double hPadding = (sw * 0.08).clamp(20.0, 48.0);
    final double btnVertPad = 14 * scale;
    final double btnFontSize = 15 * scale;
    final double logoSize = 24 * scale;

    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: false,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sfondo mappa d'epoca
          Image.network(
            'https://images.unsplash.com/photo-1524661135-423995f22d0b'
            '?q=80&w=1000&auto=format&fit=crop',
            fit: BoxFit.cover,
            color: Colors.black.withValues(alpha: 0.62),
            colorBlendMode: BlendMode.darken,
            errorBuilder: (_, _, _) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2B2B2B), Color(0xFF000000)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Vignettatura
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.78)],
                radius: 1.0,
              ),
            ),
          ),

          // Contenuto centrato
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPadding),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Emblema militare
                      Container(
                        padding: EdgeInsets.all(iconPad),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: _olive, width: 2),
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                        child: Icon(
                          Icons.military_tech,
                          size: iconSize,
                          color: _olive,
                        ),
                      ),
                      SizedBox(height: spacingMd),

                      // Titolo
                      Text(
                        "CESENA",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: Colors.white,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "1945",
                        style: TextStyle(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 4.0,
                          color: _tan,
                          height: 1.0,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: spacingLg),

                      // Bottone / loader
                      if (_isLoading)
                        const CircularProgressIndicator(color: _olive)
                      else
                        _buildGoogleButton(
                          btnVertPad: btnVertPad,
                          btnFontSize: btnFontSize,
                          logoSize: logoSize,
                        ),

                      // Errore
                      if (_error != null) ...[
                        SizedBox(height: spacingSm),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacingSm,
                                vertical: spacingSm * 0.75,
                              ),
                              decoration: BoxDecoration(
                                color: _tan.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _tan.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  color: const Color(0xFFB84F4F),
                                  fontSize: 13 * scale,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget _buildGoogleButton({
    required double btnVertPad,
    required double btnFontSize,
    required double logoSize,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: _olive.withValues(alpha: 0.22),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _cream,
          foregroundColor: _textDark,
          padding: EdgeInsets.symmetric(vertical: btnVertPad),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
            side: BorderSide(color: _olive.withValues(alpha: 0.28), width: 1),
          ),
          elevation: 0,
        ),
        onPressed: _handleSignIn,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.string(
              _googleLogoSvg,
              height: logoSize,
              width: logoSize,
            ),
            SizedBox(width: logoSize * 0.5),
            Text(
              "ACCEDI CON GOOGLE",
              style: TextStyle(
                fontSize: btnFontSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
