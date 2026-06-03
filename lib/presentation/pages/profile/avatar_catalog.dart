import 'package:flutter/material.dart';

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.assetPath,
    required this.background,
  });

  final String id;
  final String assetPath;
  final Color background;
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(
    id: 'generale',
    assetPath: 'assets/avatars/generale.png',
    background: Color(0xFFE0E0E0),
  ),
  AvatarOption(
    id: 'soldato',
    assetPath: 'assets/avatars/soldato.png',
    background: Color(0xFFD7CCC8),
  ),
  AvatarOption(
    id: 'infermiera',
    assetPath: 'assets/avatars/infermiera.png',
    background: Color(0xFFFFCDD2),
  ),
  AvatarOption(
    id: 'aviatore',
    assetPath: 'assets/avatars/aviatore.png',
    background: Color(0xFFFFF9C4),
  ),
  AvatarOption(
    id: 'telefonista',
    assetPath: 'assets/avatars/telefonista.png',
    background: Color(0xFFF8E8D0),
  ),
  AvatarOption(
    id: 'marina',
    assetPath: 'assets/avatars/marina.png',
    background: Color(0xFFE8EAF6),
  ),
  AvatarOption(
    id: 'prete',
    assetPath: 'assets/avatars/prete.png',
    background: Color(0xFFECEFF1),
  ),
  AvatarOption(
    id: 'medico',
    assetPath: 'assets/avatars/medico.png',
    background: Color(0xFFE0F2F1),
  ),
];

AvatarOption avatarById(String avatarId) {
  return avatarOptions.firstWhere(
    (option) => option.id == avatarId,
    orElse: () => avatarOptions[1], // default: soldato
  );
}
