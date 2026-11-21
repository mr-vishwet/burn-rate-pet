import 'package:flutter/material.dart';

import '../app_routes.dart';
import '../core/theme.dart';
import '../engine/checkin.dart';
import '../state/momo_scope.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/glass_card.dart';
import '../widgets/momo_avatar.dart';

/// 06 Mood Check-in: 10 questions drawn at random from the bank. Momo
/// reacts to each answer — a bright answer perks Momo up.
class CheckinScreen extends StatefulWidget {
  /// Creates the check-in screen.
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  late final List<CheckinQuestion> _questions;
  late final List<int?> _answers;
  var _current = 0;
  var _submitting = false;

  @override
  void initState() {
    super.initState();
    _questions = drawCheckinQuestions();
    _answers = List<int?>.filled(_questions.length, null);
  }

  Future<void> _finish() async {
    setState(() => _submitting = true);
    final controller = MomoScope.read(context);
    await controller.submitCheckin(
      questionIds: _questions.map((q) => q.id).toList(),
      answers: _answers.map((a) => a ?? 2).toList(),
    );
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(AppRoutes.checkinResult);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final question = _questions[_current];
    final selected = _answers[_current];
    final isLast = _current == _questions.length - 1;
    final mood = selected == null
        ? MomoMood.content
        : selected >= 3
            ? MomoMood.happy
            : selected <= 1
                ? MomoMood.low
                : MomoMood.content;
    return AppScaffold(
      title: 'Mood Check-in',
      bottomNavIndex: 1,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: (_current + 1) / _questions.length,
                minHeight: 8,
                backgroundColor: AppTheme.hairline,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.peach,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Question ${_current + 1} of ${_questions.length} · drawn '
              'at random from your bank',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MomoAvatar(size: 84, mood: mood),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Kicker(question.dimension),
                      const SizedBox(height: 6),
                      Text(
                        question.prompt,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        mood == MomoMood.happy
                            ? 'Momo perks up — a bright answer lifts the index.'
                            : mood == MomoMood.low
                                ? 'Momo listens quietly. Nothing to fix — just noticed.'
                                : 'Answer honestly. Momo never judges.',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < question.options.length; i++) ...[
              _AnswerOption(
                label: question.options[i],
                selected: selected == i,
                onTap: () => setState(() => _answers[_current] = i),
              ),
              const SizedBox(height: 10),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                if (_current > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _current--),
                      child: const Text('Back'),
                    ),
                  ),
                if (_current > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: GradientButton(
                    label: isLast ? 'See my result' : 'Next question',
                    icon: Icons.arrow_forward,
                    onPressed: selected == null || _submitting
                        ? null
                        : () {
                            if (isLast) {
                              _finish();
                            } else {
                              setState(() => _current++);
                            }
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Sleep · energy · stress · focus · social · movement · mood '
              '· appetite · calm · outlook',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerOption extends StatelessWidget {
  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.ctaGradient : null,
          color: selected ? null : AppTheme.glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.peach : AppTheme.hairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected
                    ? Colors.white.withValues(alpha: 0.9)
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? Colors.white
                      : AppTheme.peachSoft.withValues(alpha: 0.6),
                ),
              ),
              child: selected
                  ? const Icon(
                      Icons.check,
                      size: 14,
                      color: AppTheme.coral,
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
