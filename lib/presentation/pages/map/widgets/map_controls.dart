import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';
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
    required this.selectedMapStyle,
    required this.onToggle,
    required this.onSelectStandard,
    required this.onSelectSatellite,
  });

  final bool isOpen;
  final MapStyle selectedMapStyle;
  final VoidCallback onToggle;
  final VoidCallback onSelectStandard;
  final VoidCallback onSelectSatellite;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget square({
      required String title,
      required IconData icon,
      required Color bgColor,
      required bool isSelected,
      required VoidCallback onTap,
    }) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: isSelected
                ? Border.all(color: AppPalette.olive, width: 2)
                : null,
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
                isSelected: selectedMapStyle == MapStyle.standard,
                bgColor: theme.brightness == Brightness.dark
                    ? theme.colorScheme.surfaceContainerHighest
                    : Colors.grey.shade100, // ADATTIVO
                onTap: onSelectStandard,
              ),
              const SizedBox(width: 12),
              square(
                title: 'Satellite',
                icon: Icons.satellite_alt,
                isSelected: selectedMapStyle == MapStyle.satellite,
                bgColor: theme.brightness == Brightness.dark
                    ? AppPalette.moss.withValues(alpha: 0.2)
                    : Colors.green.shade100, // ADATTIVO
                onTap: onSelectSatellite,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'btnMapType',
          backgroundColor: theme.colorScheme.surface, // ADATTIVO
          elevation: 4,
          onPressed: onToggle,
          child: Icon(
            isOpen ? Icons.close : Icons.layers,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

enum MapStyle { standard, satellite }

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
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.explore_outlined, color: Colors.white, size: 22),
            SizedBox(width: 10),
            Text(
              AppLocalizations.of(context)!.tourStartButton,
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.place, size: 15, color: AppPalette.olive),
                SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)!.tourArrivedButton,
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

class TourQuickActionButton extends StatelessWidget {
  const TourQuickActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.88),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.28)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: color,
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
    required this.icon,
    required this.iconBackground,
    required this.stopIndex,
    required this.totalStops,
    required this.distanceMeters,
    required this.elapsedSeconds,
    required this.arrived,
    required this.onTap,
  });

  final TourStop stop;
  final IconData icon;
  final Color iconBackground;
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
                color: iconBackground,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
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
                              ? AppLocalizations.of(
                                  context,
                                )!.tourStopCardArrived
                              : AppLocalizations.of(
                                  context,
                                )!.tourStopCardDistance(
                                  formatDistance(distanceMeters),
                                  stopIndex + 1,
                                  totalStops,
                                ),
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

class TourPlanSheet extends StatelessWidget {
  const TourPlanSheet({
    super.key,
    required this.upcomingStops,
    required this.distanceFromPrevious,
    required this.onReorder,
  });

  final List<TourStop> upcomingStops;
  final List<double?> distanceFromPrevious;
  final void Function(int oldIndex, int newIndex) onReorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: theme.colorScheme.outline.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.route_rounded,
                  color: theme.colorScheme.onSurface,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.tourPlanTitle,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                AppLocalizations.of(context)!.tourPlanSubtitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: upcomingStops.length,
                onReorder: onReorder,
                buildDefaultDragHandles: false,
                proxyDecorator: (child, index, animation) {
                  return Material(
                    color: Colors.transparent,
                    child: ScaleTransition(
                      scale: Tween<double>(
                        begin: 1,
                        end: 1.02,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                itemBuilder: (context, index) {
                  final stop = upcomingStops[index];
                  final legDistance = distanceFromPrevious[index];
                  return Container(
                    key: ValueKey(stop.id),
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? AppPalette.olive.withValues(alpha: 0.2)
                                : theme.colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: index == 0
                                  ? AppPalette.olive
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      stop.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: theme.colorScheme.onSurface,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  if (index == 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppPalette.olive.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(99),
                                      ),
                                      child: Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.tourPlanCurrentLabel,
                                        style: TextStyle(
                                          color: AppPalette.olive,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                legDistance == null
                                    ? AppLocalizations.of(
                                        context,
                                      )!.tourPlanFirstStop
                                    : AppLocalizations.of(
                                        context,
                                      )!.tourPlanDistanceFromPrev(
                                        formatDistance(legDistance),
                                      ),
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        ReorderableDragStartListener(
                          index: index,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.drag_handle_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 19,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
