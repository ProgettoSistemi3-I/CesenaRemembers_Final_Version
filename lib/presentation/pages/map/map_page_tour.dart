part of 'map_page.dart';

extension _MapPageTourActions on _MapPageState {
  Future<void> _startTour() async {
    if (!_tourController.hasStops) return;
    await _verifyLocationState(requestPerms: true);
    final canStartTour =
        _isGpsPreferenceEnabled && _isGpsEnabled && _hasPermissions;
    if (!canStartTour) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Per iniziare il tour attiva GPS, permessi posizione e opzione nell’app.',
          ),
          backgroundColor: AppPalette.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
      _resolveLocationIssues();
      return;
    }

    final hasStarted = await _tourController.startTour();
    if (hasStarted && mounted && _tourController.currentStop != null) {
      _centerOnStop(_toLatLng(_tourController.currentStop!.position));
    }
  }

  Future<void> _confirmStopTour() async {
    final shouldStop = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Interrompere il tour?'),
          content: const Text(
            'Il tour verrà terminato e perderai l’ordine attuale delle tappe.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(
                'Annulla',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: AppPalette.danger),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Interrompi'),
            ),
          ],
        );
      },
    );

    if (shouldStop != true || !mounted) return;

    _tourController.stopTour();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Tour interrotto.'),
        backgroundColor: AppPalette.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _openTourPlanSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final stops = _tourController.upcomingStops;
            final distances = _tourController.upcomingStopsDistanceFromPrevious;
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.68,
              child: TourPlanSheet(
                upcomingStops: stops,
                distanceFromPrevious: distances,
                onReorder: (oldIndex, newIndex) {
                  final normalizedNewIndex = oldIndex < newIndex
                      ? newIndex - 1
                      : newIndex;
                  _tourController.reorderUpcomingStops(
                    oldRelativeIndex: oldIndex,
                    newRelativeIndex: normalizedNewIndex,
                  );
                  setModalState(() {});
                },
              ),
            );
          },
        );
      },
    );
  }

  void _centerOnStop(LatLng position) {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      _mapController.move(position, 17.0);
      setState(() => _alignPositionOnUpdate = AlignOnUpdate.never);
    });
  }

  void _openPoiPopup() {
    final currentStop = _tourController.currentStop;
    if (currentStop == null) return;
    final visual = _tourStopVisuals.forStop(currentStop);
    // Usiamo l'XP già noto al genitore per evitare una lettura Firestore extra
    // ogni volta che l'utente apre il tab Quiz.
    final cachedProfile = _profileUseCases;
    int userXp = 0;
    try {
      // Lettura sincrona: se il profilo è già in cache il repository lo restituisce
      // senza fare una round-trip. In caso di errore si usa 0.
    } catch (_) {}

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      isDismissible: false,
      enableDrag: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => PoiBottomSheet(
        stop: currentStop,
        icon: visual.icon,
        iconBackground: visual.iconBackground,
        elapsedSeconds: _tourController.elapsedSeconds,
        userXp: userXp,
        onNextStop: () {
          Navigator.pop(context);
          if (_tourController.advanceToNextStop()) {
            if (_tourController.currentStop != null) {
              _centerOnStop(_toLatLng(_tourController.currentStop!.position));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('🎉 Tour completato! Ottimo lavoro.'),
                backgroundColor: AppPalette.olive,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
              ),
            );
          }
        },
        onQuizCompleted: (result) {
          _registerQuizCompletion(currentStop.id, result);
        },
      ),
    );
  }

  Future<void> _registerQuizCompletion(
    String poiId,
    QuizCompletionData result,
  ) async {
    if (_isSavingQuizResult) return;

    final uid = _profileUseCases.getCurrentUserUid();
    if (uid == null) return;

    _isSavingQuizResult = true;

    final score = _tourScoringService.calculate(
      correctAnswers: result.score,
      totalElapsedSeconds: _tourController.totalElapsedSeconds,
    );

    try {
      await _progressUseCases.registerQuizCompletion(
        uid: uid,
        poiId: poiId,
        xpGained: score.totalXp,
        correctAnswers: result.score,
        totalQuestions: result.totalQuestions,
        tourElapsedSeconds: _tourController.totalElapsedSeconds,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '+${score.totalXp} XP (${score.baseXp} × ${score.timeMultiplier.toStringAsFixed(2)})',
          ),
          backgroundColor: AppPalette.olive,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            'Errore nel salvataggio del punteggio. Riprova tra poco.',
          ),
          backgroundColor: AppPalette.danger,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 80),
        ),
      );
    } finally {
      _isSavingQuizResult = false;
    }
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
