import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../domain/validation/profile_validation.dart';
import '../../../domain/usecases/user_profile_use_cases.dart';
import '../../../injection_container.dart';
import '../../theme/app_palette.dart';
import 'avatar_catalog.dart';

class ProfileSetupPage extends StatefulWidget {
  const ProfileSetupPage({
    super.key,
    required this.uid,
    required this.email,
    this.suggestedName,
  });

  final String uid;
  final String email;
  final String? suggestedName;

  @override
  State<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends State<ProfileSetupPage> {
  String _loc(String it, String en) => Localizations.localeOf(context).languageCode == 'en' ? en : it;
  final UserProfileUseCases _profileUseCases = sl<UserProfileUseCases>();

  late final TextEditingController _nameController;
  final TextEditingController _usernameController = TextEditingController();
  int _selectedAvatarIndex = 1;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: (widget.suggestedName ?? '').trim(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final displayName = _nameController.text.trim();
    final normalizedUsername = ProfileValidation.normalizeUsername(
      _usernameController.text,
    );

    if (!ProfileValidation.isValidDisplayName(displayName)) {
      setState(
        () => _error =
            'Il nome in app deve avere ${ProfileValidation.minDisplayNameLength}-${ProfileValidation.maxDisplayNameLength} caratteri.',
      );
      return;
    }
    if (ProfileValidation.hasOffensiveDisplayName(displayName)) {
      setState(
        () => _error =
            _loc('Il nome in app contiene termini non consentiti. Scegline uno diverso.', 'Display name contains forbidden terms. Choose a different one.'),
      );
      return;
    }

    if (!ProfileValidation.isValidUsername(normalizedUsername)) {
      setState(
        () => _error =
            'Username non valido (usa ${ProfileValidation.minUsernameLength}-${ProfileValidation.maxUsernameLength} caratteri: a-z, 0-9, _ o .).',
      );
      return;
    }
    if (ProfileValidation.hasOffensiveUsername(normalizedUsername)) {
      setState(
        () => _error =
            _loc('Username contiene termini non consentiti. Scegline uno diverso.', 'Username contains forbidden terms. Choose a different one.'),
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      // Best-effort check: se le rules bloccano query globali non interrompiamo
      // il flusso, lasciando al salvataggio finale la validazione definitiva.
      try {
        final available = await _profileUseCases.isUsernameAvailable(
          normalizedUsername,
        );
        if (!available) {
          setState(() {
            _error = _loc('Username già in uso. Scegline un altro.', 'Username already in use. Choose another one.');
            _isSaving = false;
          });
          return;
        }
      } catch (_) {
        // Ignoriamo errori di availability check (es. permission-denied).
      }

      await _profileUseCases.completeInitialProfile(
        uid: widget.uid,
        email: widget.email,
        username: normalizedUsername,
        displayName: displayName,
        avatarId: avatarOptions[_selectedAvatarIndex].id,
      );
      if (mounted) {
        setState(() => _isSaving = false);
      }
    } catch (e) {
      final message = e.toString();
      setState(() {
        if (message.contains('USERNAME_NOT_AVAILABLE')) {
          _error = _loc('Username già in uso. Scegline un altro.', 'Username already in use. Choose another one.');
        } else if (message.contains('USERNAME_INDEX_PERMISSION_DENIED')) {
          _error =
              'Configurazione Firestore non valida: servono permessi di lettura/scrittura su usernames/{username}.';
        } else if (message.contains('INVALID_DISPLAY_NAME')) {
          _error =
              'Il nome in app deve avere ${ProfileValidation.minDisplayNameLength}-${ProfileValidation.maxDisplayNameLength} caratteri.';
        } else if (message.contains('INVALID_USERNAME')) {
          _error =
              'Username non valido (usa ${ProfileValidation.minUsernameLength}-${ProfileValidation.maxUsernameLength} caratteri).';
        } else if (message.contains('OFFENSIVE_DISPLAY_NAME')) {
          _error =
              _loc('Il nome in app contiene termini non consentiti. Scegline uno diverso.', 'Display name contains forbidden terms. Choose a different one.');
        } else if (message.contains('OFFENSIVE_USERNAME')) {
          _error = _loc('Username contiene termini non consentiti. Scegline uno diverso.', 'Username contains forbidden terms. Choose a different one.');
        } else if (e is FirebaseException && e.code == 'permission-denied') {
          _error =
              _loc('Permessi Firestore insufficienti per completare il profilo. Controlla le regole del progetto.', 'Insufficient Firestore permissions to complete the profile. Check project rules.');
        } else {
          _error = _loc('Impossibile salvare il profilo. Riprova tra qualche secondo.', 'Unable to save profile. Try again in a few seconds.');
        }
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),
              Text(
                _loc('Crea il tuo profilo', 'Create your profile'),
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _loc('Scegli username univoco (non modificabile), nome in app e avatar.', 'Choose a unique username (not editable), a display name and an avatar.'),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _loc('Nome in app', 'Display name'),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: _loc('es. cesena_explorer', 'e.g. cesena_explorer'),
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _loc('Scegli avatar', 'Choose avatar'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: List.generate(avatarOptions.length, (index) {
                  final option = avatarOptions[index];
                  final selected = _selectedAvatarIndex == index;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedAvatarIndex = index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? AppPalette.olive : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: option.background,
                        child: Icon(option.icon, color: Colors.black54),
                      ),
                    ),
                  );
                }),
              ),
              if (_error != null) ...[
                const SizedBox(height: 14),
                Text(
                  _error!,
                  style: const TextStyle(color: AppPalette.danger),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _submit,
                  child: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_loc('Conferma profilo', 'Confirm profile')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
