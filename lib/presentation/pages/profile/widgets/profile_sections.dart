import 'package:flutter/material.dart';

import '../../../theme/app_palette.dart';

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    super.key,
    required this.avatar,
    required this.displayName,
    required this.username,
    required this.onAvatarTap,
    required this.onEditName,
  });

  final IconData avatar;
  final String displayName;
  final String username;
  final VoidCallback onAvatarTap;
  final VoidCallback onEditName;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppPalette.tan.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onAvatarTap,
            child: CircleAvatar(
              radius: 52,
              backgroundColor: AppPalette.tanLight,
              child: Icon(avatar, size: 56, color: AppPalette.textDark),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                displayName,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppPalette.textDark,
                ),
              ),
              IconButton(
                onPressed: onEditName,
                icon: const Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: AppPalette.textMid,
                ),
              ),
            ],
          ),
          Text(
            username,
            style: const TextStyle(color: AppPalette.textMid, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class ProfileStatsSection extends StatelessWidget {
  const ProfileStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      childAspectRatio: 1.55,
      children: const [
        _StatCard(
          icon: Icons.verified_user_outlined,
          label: 'Traguardi',
          value: '3 / 11',
          color: AppPalette.olive,
        ),
        _StatCard(
          icon: Icons.emoji_events_outlined,
          label: 'Classifica',
          value: '# 1',
          color: AppPalette.tan,
        ),
        _StatCard(
          icon: Icons.location_on_outlined,
          label: 'Siti Visitati',
          value: '67',
          color: AppPalette.moss,
        ),
        _StatCard(
          icon: Icons.quiz_outlined,
          label: 'Quiz Superati',
          value: '34',
          color: AppPalette.tan,
        ),
      ],
    );
  }
}

class ProfileBadgesSection extends StatelessWidget {
  const ProfileBadgesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: _BadgeCard(icon: Icons.military_tech, label: 'Pioniere'),
        ),
        SizedBox(width: 10),
        Expanded(child: _BadgeCard(icon: Icons.explore, label: 'Esploratore')),
        SizedBox(width: 10),
        Expanded(child: _BadgeCard(icon: Icons.history_edu, label: 'Storico')),
      ],
    );
  }
}

class ProfileSectionTitle extends StatelessWidget {
  const ProfileSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          margin: const EdgeInsets.only(right: 8),
          decoration: BoxDecoration(
            color: AppPalette.olive,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppPalette.textDark,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.tanLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                color: AppPalette.textDark,
                fontWeight: FontWeight.w700,
              )),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(color: AppPalette.textMid, fontSize: 12)),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  const _BadgeCard({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: AppPalette.warmWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppPalette.tanLight),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppPalette.olive),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppPalette.textMid),
          ),
        ],
      ),
    );
  }
}
