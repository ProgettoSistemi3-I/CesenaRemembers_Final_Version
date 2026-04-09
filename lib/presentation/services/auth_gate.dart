import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/user_use_cases.dart';
import '../../injection_container.dart';
import '../pages/login_page.dart';
import '../pages/profile/profile_setup_page.dart';
import 'main_shell.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = sl<AuthRepository>();

    return StreamBuilder<AppUser?>(
      stream: repository.userStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final appUser = snapshot.data;
        if (appUser == null) {
          return const LoginPage();
        }

        return _AuthenticatedGate(appUser: appUser);
      },
    );
  }
}

class _AuthenticatedGate extends StatefulWidget {
  const _AuthenticatedGate({required this.appUser});

  final AppUser appUser;

  @override
  State<_AuthenticatedGate> createState() => _AuthenticatedGateState();
}

class _AuthenticatedGateState extends State<_AuthenticatedGate> {
  late final UserUseCases _userUseCases;
  late final Future<void> _ensureFuture;

  @override
  void initState() {
    super.initState();
    _userUseCases = sl<UserUseCases>();
    _ensureFuture = _userUseCases.ensureUserDocument(
      uid: widget.appUser.id,
      email: widget.appUser.email,
      authDisplayName: widget.appUser.displayName,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ensureFuture,
      builder: (context, ensureSnapshot) {
        if (ensureSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (ensureSnapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Errore di inizializzazione profilo: ${ensureSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.appUser.id)
              .snapshots(),
          builder: (context, docSnapshot) {
            if (!docSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final doc = docSnapshot.data!;
            if (!doc.exists) {
              // Il documento è stato eliminato (cancellazione account in corso).
              // Mostriamo un indicatore di caricamento in attesa che anche
              // l'utente auth venga rimosso e il flusso torni alla LoginPage.
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final data = doc.data();
            final profileCompleted = data?['profileCompleted'] == true;

            if (!profileCompleted) {
              return ProfileSetupPage(
                uid: widget.appUser.id,
                email: widget.appUser.email,
                suggestedName: widget.appUser.displayName,
              );
            }

            return const MainShell();
          },
        );
      },
    );
  }
}
