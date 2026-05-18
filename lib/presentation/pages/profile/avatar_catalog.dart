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
  AvatarOption(id: 'partisan',  assetPath: 'assets/avatars/partisan.png',  background: Color(0xFFE0E0E0)),
  AvatarOption(id: 'soldier',   assetPath: 'assets/avatars/soldier.png',   background: Color(0xFFD7CCC8)),
  AvatarOption(id: 'nurse',     assetPath: 'assets/avatars/nurse.png',     background: Color(0xFFFFCDD2)),
  AvatarOption(id: 'explorer',  assetPath: 'assets/avatars/explorer.png',  background: Color(0xFFFFF9C4)),
  AvatarOption(id: 'staffetta', assetPath: 'assets/avatars/staffetta.png', background: Color(0xFFF8E8D0)),
  AvatarOption(id: 'mayor',     assetPath: 'assets/avatars/mayor.png',     background: Color(0xFFE8EAF6)),
  AvatarOption(id: 'priest',    assetPath: 'assets/avatars/priest.png',    background: Color(0xFFECEFF1)),
  AvatarOption(id: 'worker',    assetPath: 'assets/avatars/worker.png',    background: Color(0xFFE0F2F1)),
];

AvatarOption avatarById(String avatarId) {
  return avatarOptions.firstWhere(
    (option) => option.id == avatarId,
    orElse: () => avatarOptions[1], // default: soldier
  );
}
