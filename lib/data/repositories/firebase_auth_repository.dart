import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  @override
  User? get currentUser => _firebaseAuth.currentUser;

  AppUser? _mapUser(User? user) {
    if (user == null) {
      return null;
    }

    return AppUser(
      id: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  @override
  Stream<AppUser?> get userStream => _firebaseAuth.authStateChanges().map(_mapUser);

  @override
  Future<void> signInWithEmail(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorMessage(e.code));
    }
  }

  @override
  Future<void> register(String email, String password) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'displayName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorMessage(e.code));
    }
  }

  @override
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Accesso Google annullato.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) {
        throw Exception('Impossibile recuperare l\'utente Google.');
      }

      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();
      if (!userDoc.exists) {
        await userRef.set({
          'email': user.email,
          'displayName': user.displayName,
          'createdAt': FieldValue.serverTimestamp(),
          'role': 'user',
        });
      }
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorMessage(e.code));
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Errore Login Google: $e');
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await _firestore.collection('users').doc(user.uid).update({
          'displayName': name,
        });
        await user.reload();
      }
    } catch (_) {
      throw Exception('Impossibile aggiornare il nome.');
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_mapErrorMessage(e.code));
    } catch (_) {
      throw Exception('Errore reset password.');
    }
  }

  @override
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _firebaseAuth.signOut();
  }

  String _mapErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Utente non trovato.';
      case 'wrong-password':
        return 'Password errata.';
      case 'email-already-in-use':
        return 'Email già usata.';
      case 'weak-password':
        return 'Password troppo debole.';
      case 'invalid-email':
        return 'Email non valida.';
      case 'invalid-credential':
        return 'Credenziali non valide.';
      case 'network-request-failed':
        return 'Nessuna connessione internet.';
      default:
        return 'Errore: $code';
    }
  }
}
