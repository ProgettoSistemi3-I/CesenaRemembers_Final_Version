import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';

import '../../../theme/app_palette.dart';

class LocationIssueBanner extends StatelessWidget {
  const LocationIssueBanner({
    super.key,
    required this.isGpsEnabled,
    required this.isGpsPreferenceEnabled,
    required this.onResolve,
  });

  final bool isGpsEnabled;
  final bool isGpsPreferenceEnabled;
  final VoidCallback onResolve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppPalette.danger.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppPalette.danger.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_off_rounded,
                  color: AppPalette.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isGpsEnabled
                          ? (isGpsPreferenceEnabled
                                ? AppLocalizations.of(context)!.locationBannerMissingPermission
                                : AppLocalizations.of(context)!.locationDisabled)
                          : AppLocalizations.of(context)!.locationBannerGpsOff,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isGpsPreferenceEnabled
                          ? AppLocalizations.of(context)!.locationBannerEnableLocation
                          : AppLocalizations.of(context)!.locationBannerReEnableLocation,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.3,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppPalette.danger,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: onResolve,
                child: Text(
                  AppLocalizations.of(context)!.locationBannerResolve,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
