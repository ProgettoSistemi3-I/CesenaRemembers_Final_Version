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

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;

  Future<void> _startProfileListener() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading = false;
      errorMessage = 'Utente non autenticato.';
      notifyListeners();
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
              notifyListeners();
              return;
            }
            await _loadProfileFromUseCase(user.uid);
          },
          onError: (error) {
            isLoading = false;
            errorMessage = 'Impossibile sincronizzare il profilo: $error';
            notifyListeners();
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
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }
}
