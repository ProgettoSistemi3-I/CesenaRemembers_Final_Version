import 'dart:async';
import 'package:flutter/material.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/entities/userprofile.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/user_profile_use_cases.dart';
import '../../injection_container.dart';
import '../pages/login_page.dart';
import '../pages/onboarding/onboarding_page.dart';
import '../pages/profile/profile_setup_page.dart';
import '../theme/theme_controller.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
import 'main_shell.dart';
import 'notification_service.dart';
import 'push_notification_service.dart';
import 'shell_navigation_store.dart';
import '../widgets/glass_snackbar.dart';

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
  late final UserProfileUseCases _profileUseCases;
  late final AuthRepository _authRepository;
  late final Future<void> _ensureFuture;
  StreamSubscription<UserProfile?>? _profileSubscription;
  int _previousReceivedRequestsCount = -1;
  int _previousPendingAchievementsCount = -1;

  @override
  void initState() {
    super.initState();
    _profileUseCases = sl<UserProfileUseCases>();
    _authRepository = sl<AuthRepository>();
    _ensureFuture = _checkBanAndInit();
  }

  Future<void> _checkBanAndInit() async {
    final isBanned = await _profileUseCases.isUserBanned(widget.appUser.id);
    if (isBanned) {
      await _authRepository.signOut();
      throw const _BannedFromFirestoreException();
    }

    await _profileUseCases.ensureUserDocument(
      uid: widget.appUser.id,
      email: widget.appUser.email,
    );
    sl<ThemeController>().refreshFromProfile();
    _initNotifications();
  }

  void _initNotifications() async {
    final notificationService = NotificationService();
    await notificationService.init(
      _profileUseCases,
      widget.appUser.id,
      context,
    );

    _profileSubscription = _profileUseCases
        .getUserProfileStream(widget.appUser.id)
        .listen((profile) {
          if (profile == null) return;

          // Friend requests
          final currentRequestsCount = profile.receivedFriendRequests.length;
          if (_previousReceivedRequestsCount != -1 &&
              currentRequestsCount > _previousReceivedRequestsCount) {
            final newRequestsCount =
                currentRequestsCount - _previousReceivedRequestsCount;
            notificationService.showFriendRequestNotification(newRequestsCount);
          }
          _previousReceivedRequestsCount = currentRequestsCount;

          // Pending Achievements
          final currentPendingCount = profile.pendingAchievements.length;
          if (_previousPendingAchievementsCount != -1 &&
              currentPendingCount > _previousPendingAchievementsCount) {
            final scaffoldMessenger =
                PushNotificationService.scaffoldMessengerKey.currentState;
            final currentContext =
                PushNotificationService.navigatorKey.currentContext ?? context;

            if (scaffoldMessenger != null) {
              final double achievementBannerBottomMargin =
                  (MediaQuery.of(currentContext).size.height * 0.38)
                      .clamp(260.0, 360.0)
                      .toDouble();

              showGlassSnackBar(
                currentContext,
                message:
                    'Hai sbloccato un nuovo obiettivo! Tocca per andare a riscattarlo.',
                type: GlassSnackType.success,
                icon: Icons.emoji_events,
                duration: const Duration(seconds: 10),
                margin: EdgeInsets.fromLTRB(
                  16,
                  0,
                  16,
                  achievementBannerBottomMargin,
                ),
                onTap: () {
                  ShellNavigationStore.goToTab(2); // Vai al profilo
                },
              );
            }
          }
          _previousPendingAchievementsCount = currentPendingCount;
        });
  }

  @override
  void dispose() {
    _profileSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _ensureFuture,
      builder: (context, ensureSnapshot) {
        // Caso ban: il signOut ha già triggerato lo stream,
        // AuthGate tornerà a LoginPage. Mostriamo uno schermo di caricamento
        // neutro per evitare qualsiasi flash della _BannedScreen
        // che poi scompare subito.
        if (ensureSnapshot.hasError &&
            ensureSnapshot.error is _BannedFromFirestoreException) {
          // Mostriamo loading: tra pochi ms lo stream aggiorna e
          // AuthGate mostra LoginPage (che gestisce il ban via isBanned flag
          // settato dal FirebaseAuthException 'user-disabled', oppure
          // semplicemente l'utente torna alla login normale se l'account
          // non è disabilitato su Auth ma solo su Firestore).
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

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
                  '${AppLocalizations.of(context)!.errorLoadProfile}: ${ensureSnapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return StreamBuilder<UserProfile?>(
          stream: _profileUseCases.getUserProfileStream(widget.appUser.id),
          builder: (context, profileSnapshot) {
            if (!profileSnapshot.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final profileCompleted =
                profileSnapshot.data?.profileCompleted == true;
            final onboardingCompleted =
                profileSnapshot.data?.onboardingCompleted == true;

            if (!profileCompleted) {
              return ProfileSetupPage(
                uid: widget.appUser.id,
                email: widget.appUser.email,
                suggestedName: widget.appUser.displayName,
              );
            }

            if (!onboardingCompleted) {
              return OnboardingPage(uid: widget.appUser.id);
            }

            return const MainShell();
          },
        );
      },
    );
  }
}

/// Eccezione interna usata solo per segnalare il ban da Firestore.
class _BannedFromFirestoreException implements Exception {
  const _BannedFromFirestoreException();
}
