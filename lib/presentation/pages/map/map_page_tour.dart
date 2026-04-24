part of 'map_page.dart';

extension _MapPageTourActions on _MapPageState {
  Future<void> _startTour() async {
    if (!_tourController.hasStops) return;
    _quizOrchestrator.clearSessionCache();
    final hasStarted = await _tourController.startTour();
    if (!hasStarted || !mounted || _tourController.currentStop == null) return;

    _centerOnStop(_toLatLng(_tourController.currentStop!.position));
    await _prepareQuizForCurrentStop();
    unawaited(_prefetchQuizForNextStop());
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
        onNextStop: () {
          Navigator.pop(context);
          if (_tourController.advanceToNextStop()) {
            if (_tourController.currentStop != null) {
              _centerOnStop(_toLatLng(_tourController.currentStop!.position));
              unawaited(_prepareQuizForCurrentStop());
              unawaited(_prefetchQuizForNextStop());
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
        quizQuestionsLoader: () => _loadQuizQuestions(currentStop),
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

  Future<void> _prepareQuizForCurrentStop() async {
    final stop = _tourController.currentStop;
    final uid = _quizUserUid;
    if (stop == null || uid == null) return;

    try {
      await _quizOrchestrator.prepareForStop(
        stop: stop,
        uid: uid,
        profileLevel: _quizUserLevel,
      );
    } catch (_) {
      // In test forziamo solo AI: gli errori saranno mostrati nella UI quiz.
    }
  }

  Future<void> _prefetchQuizForNextStop() async {
    final uid = _quizUserUid;
    if (uid == null) return;

    await _quizOrchestrator.prefetchNextStop(
      stop: _nextStopForPrefetch,
      uid: uid,
      profileLevel: _quizUserLevel,
    );
  }

  Future<List<QuizQuestion>> _loadQuizQuestions(TourStop stop) async {
    final uid = _quizUserUid;
    if (uid == null) {
      throw const QuizGenerationException('Utente non autenticato.');
    }

    return _quizOrchestrator.getQuestionsForStop(
      stop: stop,
      uid: uid,
      profileLevel: _quizUserLevel,
    );
  }

  LatLng _toLatLng(GeoPoint point) => LatLng(point.latitude, point.longitude);
}
