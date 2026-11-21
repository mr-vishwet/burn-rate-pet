import 'dart:math';

import '../core/constants.dart';

/// The mood check-in: 10 questions, one per dimension, drawn at random
/// (shuffled order) from the bank each session. Five answers per question,
/// scored 0-4. A check-in's score is the mean answer mapped to 0-100;
/// the mood component is the mean of recent check-in scores.
class CheckinQuestion {
  /// Creates a check-in question.
  const CheckinQuestion({
    required this.id,
    required this.dimension,
    required this.prompt,
    required this.options,
  });

  /// Stable id, e.g. "focus".
  final String id;

  /// Dimension name shown above the question, e.g. "Focus".
  final String dimension;

  /// The question text.
  final String prompt;

  /// Five answer labels, worst (0) to best (4).
  final List<String> options;
}

/// The question bank — one question per dimension. The order below is the
/// bank order; a session shuffles it.
const List<CheckinQuestion> kCheckinBank = [
  CheckinQuestion(
    id: 'sleep',
    dimension: 'Sleep',
    prompt: 'How did you sleep last night?',
    options: ['Restless', 'Broken', 'Okay', 'Deep', 'Like a log'],
  ),
  CheckinQuestion(
    id: 'energy',
    dimension: 'Energy',
    prompt: "How's your energy right now?",
    options: ['Drained', 'Low', 'Okay', 'Buzzing', 'Electric'],
  ),
  CheckinQuestion(
    id: 'stress',
    dimension: 'Stress',
    prompt: 'How heavy does today feel?',
    options: ['Crushing', 'Heavy', 'Okay', 'Light', 'Feather-light'],
  ),
  CheckinQuestion(
    id: 'focus',
    dimension: 'Focus',
    prompt: "How's your focus today?",
    options: ['Foggy', 'Wobbly', 'Okay', 'Sharp', 'Locked in'],
  ),
  CheckinQuestion(
    id: 'social',
    dimension: 'Social',
    prompt: 'How connected do you feel?',
    options: ['Alone', 'Distant', 'Okay', 'Close', 'Held'],
  ),
  CheckinQuestion(
    id: 'movement',
    dimension: 'Movement',
    prompt: 'How much did you move today?',
    options: ['Not at all', 'A little', 'Some', 'Plenty', 'All day'],
  ),
  CheckinQuestion(
    id: 'mood',
    dimension: 'Mood',
    prompt: "How's your mood, honestly?",
    options: ['Grey', 'Meh', 'Okay', 'Bright', 'Glowing'],
  ),
  CheckinQuestion(
    id: 'appetite',
    dimension: 'Appetite',
    prompt: "How's your appetite?",
    options: ['None', 'Off', 'Okay', 'Healthy', 'Ravenous'],
  ),
  CheckinQuestion(
    id: 'calm',
    dimension: 'Calm',
    prompt: 'How calm do you feel?',
    options: ['Wired', 'Restless', 'Okay', 'Steady', 'Serene'],
  ),
  CheckinQuestion(
    id: 'outlook',
    dimension: 'Outlook',
    prompt: 'How does tomorrow look?',
    options: ['Dreadful', 'Uncertain', 'Okay', 'Hopeful', 'Bright'],
  ),
];

/// Draws one check-in session: all [kCheckinQuestions] questions from the
/// bank in random order. Pass a seeded [Random] for deterministic tests.
List<CheckinQuestion> drawCheckinQuestions({Random? random}) {
  final questions = List<CheckinQuestion>.of(kCheckinBank);
  questions.shuffle(random);
  return questions.take(kCheckinQuestions).toList();
}

/// Scores one completed check-in: [answers] are option indices (0-4), one
/// per question. Returns 0-100 (mean answer / 4 × 100, rounded).
int scoreCheckin(List<int> answers) {
  if (answers.isEmpty) return 0;
  final mean = answers.reduce((a, b) => a + b) / answers.length;
  return (mean / (kAnswerOptions - 1) * 100).round().clamp(0, 100);
}

/// The mood component (0-100) from recent check-in scores: their mean,
/// rounded. Returns null when there are no check-ins yet — the UI then
/// asks for a first check-in instead of inventing a number.
int? moodScoreFromRecent(List<int> recentScores) {
  if (recentScores.isEmpty) return null;
  final mean =
      recentScores.reduce((a, b) => a + b) / recentScores.length;
  return mean.round().clamp(0, 100);
}
