import 'package:flutter/material.dart';

class AvatarOption {
  const AvatarOption({
    required this.id,
    required this.icon,
    required this.background,
  });

  final String id;
  final IconData icon;
  final Color background;
}

const List<AvatarOption> avatarOptions = [
  AvatarOption(id: 'person', icon: Icons.person, background: Color(0xFFEEEEEE)),
  AvatarOption(
    id: 'military_tech',
    icon: Icons.military_tech,
    background: Color(0xFFFFECB3),
  ),
  AvatarOption(
    id: 'local_fire_department',
    icon: Icons.local_fire_department,
    background: Color(0xFFFFCDD2),
  ),
  AvatarOption(id: 'bolt', icon: Icons.bolt, background: Color(0xFFFFF9C4)),
  AvatarOption(id: 'shield', icon: Icons.shield, background: Color(0xFFBBDEFB)),
  AvatarOption(id: 'star', icon: Icons.star, background: Color(0xFFC8E6C9)),
  AvatarOption(
    id: 'emoji_events',
    icon: Icons.emoji_events,
    background: Color(0xFFE1BEE7),
  ),
  AvatarOption(id: 'public', icon: Icons.public, background: Color(0xFFB2EBF2)),
  AvatarOption(
    id: 'psychology',
    icon: Icons.psychology,
    background: Color(0xFFD7CCC8),
  ),
  AvatarOption(
    id: 'auto_awesome',
    icon: Icons.auto_awesome,
    background: Color(0xFFF8BBD0),
  ),
];

AvatarOption avatarById(String avatarId) {
  return avatarOptions.firstWhere(
    (option) => option.id == avatarId,
    orElse: () => avatarOptions[1],
  );
}
