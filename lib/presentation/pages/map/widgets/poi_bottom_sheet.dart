import 'package:flutter/material.dart';
import 'package:cesena_remembers/l10n/app_localizations.dart';

import '../../../../domain/entities/tour_stop.dart';
import '../../../../injection_container.dart';
import '../../../controllers/poi_quiz_controller.dart';
import '../../../theme/app_palette.dart';
import '../../../services/tour_formatters.dart';

class PoiBottomSheet extends StatefulWidget {
  const PoiBottomSheet({
    super.key,
    required this.stop,
    required this.icon,
    required this.iconBackground,
    required this.elapsedSeconds,
    required this.onQuizCompleted,
    required this.onNextStop,
    this.userXp = 0,
  });

  final TourStop stop;
  final IconData icon;
  final Color iconBackground;
  final int elapsedSeconds;
  final ValueChanged<QuizCompletionData> onQuizCompleted;
  final VoidCallback onNextStop;

  /// XP dell'utente passato dal genitore per evitare una lettura Firestore extra.
  final int userXp;

  @override
  State<PoiBottomSheet> createState() => _PoiBottomSheetState();
}

class _PoiBottomSheetState extends State<PoiBottomSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  PoiQuizController? _quizController;
  bool _quizInitialized = false;
  bool _quizCompletionSent = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    _quizController?.dispose(); // Buona pratica pulire il controller
    super.dispose();
  }

  void _handleTabChange() {
    if (_quizInitialized || _tabController.index != 1) return;

    setState(() {
      _quizController = sl<PoiQuizController>();
      _quizInitialized = true;
    });

    _quizController!.addListener(() {
      if (mounted) setState(() {});
    });

    // Recupera gli XP dell'utente (se disponibile) e inizializza il quiz
    _initQuizWithUserXp();
  }

  Future<void> _initQuizWithUserXp() async {
    _quizController!.initQuiz(widget.stop.id, widget.stop.name, widget.userXp);
  }

  void _onAnswerTap(int index) {
    _quizController?.selectAnswer(index);
  }

  void _nextQuestion() {
    _quizController?.nextQuestion();
  }

  void _completeQuiz() {
    final quizController = _quizController;
    if (quizController == null) return;

    quizController.completeQuiz();
    if (!_quizCompletionSent && quizController.quizDone) {
      _quizCompletionSent = true;
      widget.onQuizCompleted(
        QuizCompletionData(
          score: quizController.score,
          totalQuestions: quizController.totalQuestions,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.60,
      minChildSize: 0.45,
      maxChildSize: 0.90,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: widget.iconBackground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: Colors.black87.withValues(alpha: 0.55),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.stop.name,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                          Text(
                            widget.stop.period,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppPalette.olive.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppPalette.olive,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            formatElapsed(widget.elapsedSeconds),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppPalette.olive,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: .5,
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.5,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),
              TabBar(
                controller: _tabController,
                labelColor: AppPalette.olive,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                indicatorColor: AppPalette.olive,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                tabs: const [
                  Tab(text: 'Informazioni'),
                  Tab(text: 'Quiz'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 140,
                            decoration: BoxDecoration(
                              color: widget.iconBackground,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Center(
                              child: Icon(
                                widget.icon,
                                size: 56,
                                color: Colors.black.withValues(alpha: 0.3),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Container(
                                width: 3,
                                height: 14,
                                margin: const EdgeInsets.only(right: 8),
                                decoration: BoxDecoration(
                                  color: AppPalette.olive,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              Text(
                                'Storia',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.stop.description,
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.65,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),
                          GestureDetector(
                            onTap: () => _tabController.animateTo(1),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              decoration: BoxDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? AppPalette.tan.withValues(alpha: 0.15)
                                    : theme.colorScheme.surfaceContainerHighest
                                          .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: theme.brightness == Brightness.dark
                                      ? AppPalette.tan.withValues(alpha: 0.3)
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.quiz_outlined,
                                    size: 16,
                                    color: AppPalette.tan,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Fai il quiz su questa tappa →',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppPalette.tan,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SingleChildScrollView(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: _buildQuizContent(theme),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizContent(ThemeData theme) {
    if (!_quizInitialized || _quizController == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    final quizController = _quizController!;

    if (quizController.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: CircularProgressIndicator(color: AppPalette.olive),
        ),
      );
    }

    if (quizController.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            quizController.error!,
            style: const TextStyle(color: AppPalette.danger, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (quizController.totalQuestions == 0) {
      return Column(
        children: [
          Text(
            'Nessun quiz disponibile per questa tappa.',
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          NextStopActionButton(onTap: widget.onNextStop),
        ],
      );
    }

    if (quizController.quizDone) {
      return Column(
        children: [
          QuizResultCard(
            score: quizController.score,
            total: quizController.totalQuestions,
            elapsed: widget.elapsedSeconds,
          ),
          const SizedBox(height: 20),
          NextStopActionButton(onTap: widget.onNextStop),
        ],
      );
    }

    final question = quizController.currentQuestion;
    if (question == null) return const SizedBox.shrink();
    final answered = quizController.selectedAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Domanda ${quizController.questionIndex + 1} di ${quizController.totalQuestions}',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (quizController.score > 0)
              Text(
                '${quizController.score} ✓',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppPalette.olive,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value:
                (quizController.questionIndex + 1) /
                quizController.totalQuestions,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: const AlwaysStoppedAnimation<Color>(AppPalette.olive),
            minHeight: 4,
          ),
        ),
        const SizedBox(height: 18),
        if (!quizController.usesPersonalizedQuestions &&
            quizController.fallbackNotice != null) ...[
          _QuizFallbackBanner(
            notice: quizController.fallbackNotice!,
            difficultyLabel: quizController.fallbackDifficultyLabel,
          ),
          const SizedBox(height: 14),
        ],
        Text(
          question.question,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(question.options.length, (index) {
          final isSelected = quizController.selectedAnswer == index;
          final isCorrect = index == question.correctIndex;

          var bgColor = theme.colorScheme.surface;
          var borderColor = theme.colorScheme.surfaceContainerHighest;
          var textColor = theme.colorScheme.onSurface;
          IconData? trailing;

          if (answered) {
            if (isCorrect) {
              bgColor = AppPalette.moss.withValues(alpha: 0.15);
              borderColor = AppPalette.moss;
              textColor = theme.brightness == Brightness.dark
                  ? AppPalette.moss
                  : const Color(0xFF3B6D11);
              trailing = Icons.check_circle_outline;
            } else if (isSelected) {
              bgColor = AppPalette.danger.withValues(alpha: 0.15);
              borderColor = AppPalette.danger;
              textColor = AppPalette.danger;
              trailing = Icons.cancel_outlined;
            }
          }

          return GestureDetector(
            onTap: () => _onAnswerTap(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (answered && isCorrect) ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: answered
                          ? (isCorrect
                                ? AppPalette.moss.withValues(alpha: 0.2)
                                : (isSelected
                                      ? AppPalette.danger.withValues(alpha: 0.1)
                                      : theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                            .withValues(alpha: 0.5)))
                          : theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      question.options[index],
                      style: TextStyle(fontSize: 14, color: textColor),
                    ),
                  ),
                  if (trailing != null)
                    Icon(trailing, size: 18, color: textColor),
                ],
              ),
            ),
          );
        }),
        if (answered && quizController.hasMoreQuestions) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _nextQuestion,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppPalette.olive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Prossima domanda →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
        if (answered && quizController.isLastQuestionAnswered) ...[
          const SizedBox(height: 6),
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _completeQuiz,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppPalette.olive,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    'Termina quiz →',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _QuizFallbackBanner extends StatelessWidget {
  const _QuizFallbackBanner({required this.notice, this.difficultyLabel});

  final String notice;
  final String? difficultyLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppPalette.tan.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppPalette.tan.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Avviso quiz',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppPalette.tan,
            ),
          ),
          const SizedBox(height: 4),
          Text(notice, style: const TextStyle(fontSize: 12.5)),
          if (difficultyLabel != null) ...[
            const SizedBox(height: 4),
            Text(
              difficultyLabel!,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ],
        ],
      ),
    );
  }
}

class QuizCompletionData {
  const QuizCompletionData({required this.score, required this.totalQuestions});
  final int score;
  final int totalQuestions;
}

class QuizResultCard extends StatelessWidget {
  const QuizResultCard({
    super.key,
    required this.score,
    required this.total,
    required this.elapsed,
  });

  final int score;
  final int total;
  final int elapsed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final perfect = score == total;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: perfect
            ? AppPalette.moss.withValues(alpha: 0.15)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: perfect
              ? AppPalette.moss
              : theme.colorScheme.surfaceContainerHighest,
        ),
      ),
      child: Column(
        children: [
          Icon(
            perfect ? Icons.emoji_events_rounded : Icons.stars_rounded,
            size: 48,
            color: perfect ? AppPalette.olive : AppPalette.tan,
          ),
          const SizedBox(height: 12),
          Text(
            perfect
                ? AppLocalizations.of(context)!.quizAnswerPerfect
                : AppLocalizations.of(context)!.quizAnswerGood,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: perfect ? AppPalette.olive : AppPalette.tan,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$score / $total risposte corrette',
            style: TextStyle(
              fontSize: 15,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.timer_outlined,
                size: 13,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                'Tempo: ${formatElapsed(elapsed)}',
                style: TextStyle(
                  fontSize: 13,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class NextStopActionButton extends StatelessWidget {
  const NextStopActionButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppPalette.olive,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppPalette.olive.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_walk, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Prossima tappa →',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
