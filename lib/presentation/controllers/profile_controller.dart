import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../domain/entities/userprofile.dart';
import '../../domain/usecases/user_use_cases.dart';

class ProfileController extends ChangeNotifier {
  ProfileController({required UserUseCases userUseCases})
    : _userUseCases = userUseCases {
    loadProfile();
  }

  final UserUseCases _userUseCases;

  UserProfile? profile;
  bool isLoading = true;
  String? errorMessage;

  Future<void> loadProfile() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        errorMessage = 'Utente non autenticato.';
        return;
      }
      profile = await _userUseCases.getUserProfile(user.uid);
      errorMessage = null;
    } catch (e) {
      errorMessage = 'Impossibile caricare il profilo: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
