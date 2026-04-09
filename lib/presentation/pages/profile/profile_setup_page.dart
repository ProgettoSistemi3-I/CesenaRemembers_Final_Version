import 'package:flutter/material.dart';

import '../../../domain/usecases/user_use_cases.dart';
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
  final UserUseCases _userUseCases = sl<UserUseCases>();

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

  String _normalizeUsername(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed.replaceAll(RegExp(r'[^a-z0-9_.]'), '');
  }

  Future<void> _submit() async {
    final displayName = _nameController.text.trim();
    final normalizedUsername = _normalizeUsername(_usernameController.text);

    if (displayName.length < 2) {
      setState(() => _error = 'Il nome in app deve avere almeno 2 caratteri.');
      return;
    }

    if (normalizedUsername.length < 3 || normalizedUsername.length > 20) {
      setState(
        () =>
            _error = 'Username non valido (usa 3-20 caratteri: a-z, 0-9, _ o .).',
      );
      return;
    }

    setState(() {
      _isSaving = true;
      _error = null;
    });

    try {
      final available = await _userUseCases.isUsernameAvailable(
        normalizedUsername,
      );
      if (!available) {
        setState(() {
          _error = 'Username già in uso. Scegline un altro.';
          _isSaving = false;
        });
        return;
      }

      await _userUseCases.completeInitialProfile(
        uid: widget.uid,
        email: widget.email,
        username: normalizedUsername,
        displayName: displayName,
        avatarId: avatarOptions[_selectedAvatarIndex].id,
      );
    } catch (e) {
      final message = e.toString();
      setState(() {
        _error = message.contains('USERNAME_NOT_AVAILABLE')
            ? 'Username già in uso. Scegline un altro.'
            : 'Impossibile salvare il profilo. Riprova tra qualche secondo.';
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
                'Crea il tuo profilo',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Scegli username univoco (non modificabile), nome in app e avatar.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nome in app',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _usernameController,
                autocorrect: false,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  hintText: 'es. cesena_explorer',
                  prefixText: '@',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Scegli avatar',
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
                      : const Text('Conferma profilo'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
