import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_use_cases.dart';
import '../../models/user_model.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required UserUseCases userUseCases})
    : _userUseCases = userUseCases {
    _startProfileListener();
  }

  final UserUseCases _userUseCases;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _profileSub;
  bool _isDisposed = false;

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;

  void _safeNotifyListeners() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<void> _startProfileListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      errorMessage = 'Utente non autenticato.';
      _safeNotifyListeners();
      return;
    }

    await _profileSub?.cancel();
    _profileSub = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .listen(
          (snapshot) async {
            final data = snapshot.data();
            if (snapshot.exists && data != null) {
              profile = UserModel.fromJson(data, snapshot.id);
              isLoading = false;
              errorMessage = null;
              _safeNotifyListeners();
              return;
            }
            await _loadProfileFromUseCase(user.uid);
          },
          onError: (error) {
            isLoading = false;
            errorMessage = 'Impossibile sincronizzare il profilo: $error';
            _safeNotifyListeners();
          },
        );
  }

  Future<void> _loadProfileFromUseCase(String uid) async {
    try {
      profile = await _userUseCases.getUserProfile(uid);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossibile caricare il profilo: $e';
    } finally {
      isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> updateProfileBasics({String? displayName, String? avatarId}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await _userUseCases.updateProfileBasics(
        uid: user.uid,
        displayName: displayName,
        avatarId: avatarId,
      );
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Salvataggio profilo non riuscito: $e';
      _safeNotifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _profileSub?.cancel();
    super.dispose();
  }
}
