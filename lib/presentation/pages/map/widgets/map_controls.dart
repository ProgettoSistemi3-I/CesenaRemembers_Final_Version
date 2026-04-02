import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../domain/entities/tour_stop.dart';
import '../../../theme/app_palette.dart';
import '../../../services/tour_formatters.dart';

class CircleFab extends StatelessWidget {
  const CircleFab({
    super.key,
    required this.heroTag,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  final String heroTag;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FloatingActionButton(
      heroTag: heroTag,
      backgroundColor: theme.colorScheme.surface, // ADATTIVO
      elevation: 4,
      shape: const CircleBorder(),
      onPressed: onTap,
      child: Icon(icon, color: iconColor),
    );
  }
}

class MapTypeButton extends StatelessWidget {
  const MapTypeButton({
    super.key,
    required this.isOpen,
    required this.urlStandard,
    required this.urlSatellite,
    required this.onToggle,
    required this.onSelect,
  });

  final bool isOpen;
  final String urlStandard;
  final String urlSatellite;
  final VoidCallback onToggle;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget square({
      required String title,
      required IconData icon,
      required Color bgColor,
      required String url,
    }) {
      return GestureDetector(
        onTap: () => onSelect(url),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 30,
                color: theme.colorScheme.onSurface,
              ), // ADATTIVO
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface, // ADATTIVO
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isOpen) ...[
          Row(
            children: [
              square(
                title: 'Standard',
                icon: Icons.map,
                bgColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.grey.shade100, // ADATTIVO
                url: urlStandard,
              ),
              const SizedBox(width: 12),
              square(
                title: 'Satellite',
                icon: Icons.satellite_alt,
                bgColor: theme.brightness == Brightness.dark
                    ? AppPalette.moss.withValues(alpha: 0.2)
                    : Colors.green.shade100, // ADATTIVO
                url: urlSatellite,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton.extended(
          heroTag: 'btnMapType',
          backgroundColor: theme.colorScheme.surface, // ADATTIVO
          elevation: 4,
          icon: Icon(
            isOpen ? Icons.close : Icons.layers,
            color: theme.colorScheme.onSurface,
          ), // ADATTIVO
          label: Text(
            isOpen ? 'Chiudi' : 'Mappe',
            style: TextStyle(color: theme.colorScheme.onSurface),
          ), // ADATTIVO
          onPressed: onToggle,
        ),
      ],
    );
  }
}

class StartTourButton extends StatelessWidget {
  const StartTourButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: AppPalette.olive,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppPalette.olive.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              'Inizia il tour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ManualArrivalButton extends StatelessWidget {
  const ManualArrivalButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(
                alpha: 0.8,
              ), // ADATTIVO
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppPalette.moss.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place, size: 15, color: AppPalette.olive),
                SizedBox(width: 5),
                Text(
                  'Sono arrivato',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: AppPalette.olive,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class NextStopCard extends StatelessWidget {
  const NextStopCard({
    super.key,
    required this.stop,
    required this.stopIndex,
    required this.totalStops,
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.arrived,
    required this.onTap,
  });

  final TourStop stop;
  final int stopIndex;
  final int totalStops;
  final double distanceMeters;
  final int elapsedSeconds;
  final bool arrived;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface, // ADATTIVO
          borderRadius: BorderRadius.circular(20),
          border: arrived
              ? Border.all(color: AppPalette.olive, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: theme.brightness == Brightness.light
                  ? Colors.black.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.5), // ADATTIVO
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: stop.iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                stop.icon,
                size: 26,
                color: Colors.black87.withValues(alpha: 0.6),
              ), // Icona fissa per staccare dal background generato
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    stop.name,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ), // ADATTIVO
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(
                        arrived ? Icons.check_circle : Icons.place_outlined,
                        size: 12,
                        color: arrived ? AppPalette.olive : AppPalette.moss,
                      ),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          arrived
                              ? 'Sei arrivato! Tocca per aprire'
                              : '${formatDistance(distanceMeters)} · tappa ${stopIndex + 1}/$totalStops',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: arrived
                                ? AppPalette.olive
                                : theme
                                      .colorScheme
                                      .onSurfaceVariant, // ADATTIVO
                            fontWeight: arrived
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (arrived)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppPalette.olive.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppPalette.olive,
                ),
              )
            else
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ), // ADATTIVO
                  const SizedBox(height: 2),
                  Text(
                    formatElapsed(elapsedSeconds),
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onSurfaceVariant, // ADATTIVO
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
