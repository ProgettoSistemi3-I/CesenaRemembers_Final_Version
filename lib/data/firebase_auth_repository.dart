import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../config/app_runtime_config.dart';
import '../domain/entities/app_user.dart';
import '../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn =
           googleSignIn ??
           GoogleSignIn(
             clientId: AppRuntimeConfig.googleWebClientId.trim().isEmpty
                 ? null
                 : AppRuntimeConfig.googleWebClientId,
           );

  @override
  Stream<AppUser?> get userStream {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    });
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    if (googleAuth == null) return null;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final UserCredential userCredential = await _firebaseAuth
        .signInWithCredential(credential);
    final User? user = userCredential.user;

    if (user == null) return null;
    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw Exception('Nessun utente autenticato.');
    }

    try {
      // Tenta l'eliminazione diretta
      await user.delete();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        // Ri-autenticazione silenziosa (o esplicita) se Firebase la richiede per sicurezza
        final googleUser =
            await _googleSignIn.signInSilently() ??
            await _googleSignIn.signIn();

        if (googleUser == null) {
          throw Exception(
            'Riautenticazione necessaria ma annullata dall\'utente.',
          );
        }

        final googleAuth = await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await user.reauthenticateWithCredential(credential);
        await user.delete();
      } else {
        rethrow;
      }
    }

    // PULIZIA PROFONDA DELLA SESSIONE GOOGLE (Risolve il bug del ri-login automatico)
    try {
      if (await _googleSignIn.isSignedIn()) {
        // Usare DISCONNECT, non signOut!
        await _googleSignIn.disconnect();
      }
    } catch (_) {
      // Fallback: se disconnect fallisce per qualche strana ragione, proviamo signOut
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    }
  }
}
