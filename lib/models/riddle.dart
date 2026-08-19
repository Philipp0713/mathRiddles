import 'package:flutter/material.dart';

/// The part of a math puzzle that actually varies from level to level:
/// the question shown in the middle of the screen, and the logic to
/// grade an answer to it. Everything else — score, feedback, and the
/// answer input/keypad — is handled once by `RiddleScreen`, which every
/// level shares.
///
/// To add a new puzzle, extend this class (see
/// `lib/riddles/addition_riddle.dart`) and pass an instance to a
/// `RiddleScreen` in `lib/data/levels.dart`. No new screen needed.
abstract class Riddle extends ChangeNotifier {
  /// Builds the question for the current state. Can be any widget tree —
  /// text, equations, images, multiple blanks, and so on. Call
  /// [notifyListeners] after mutating state that should change this
  /// output outside of [generate] (e.g. a hint being revealed).
  Widget build(BuildContext context);

  /// Randomizes internal state to produce a fresh question.
  void generate();

  /// Whether [answer] solves the current question.
  bool checkAnswer(String answer);

  /// Shown in the feedback message when a submitted answer was wrong.
  String get correctAnswerLabel;

  /// Whether this riddle currently has another hint to give. `RiddleScreen`
  /// only shows a hint button while this is true, so puzzles that don't
  /// want hints can leave the default (always `false`).
  bool get hasHint => false;

  /// Reveals progressively more of the puzzle. Called once per press of
  /// the hint button; each call may do something different (reveal one
  /// more data point, then finally the underlying rule, etc.) — it's up
  /// to [build] to reflect whatever was revealed. Must call
  /// [notifyListeners] so the screen rebuilds.
  void revealHint() {}
}
