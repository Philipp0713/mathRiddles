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
}
