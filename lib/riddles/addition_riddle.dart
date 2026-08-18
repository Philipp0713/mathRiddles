import 'dart:math';

import 'package:flutter/material.dart';

import '../models/riddle.dart';

/// Template riddle: "a + b = ?" for two random small numbers.
///
/// Copy this file as a starting point for new puzzle types — only
/// [generate], [checkAnswer], [correctAnswerLabel], and [build] need to
/// change. Everything else about the screen (score, feedback, keypad) is
/// shared via `RiddleScreen`.
class AdditionRiddle extends Riddle {
  final Random _random = Random();

  late int a;
  late int b;

  @override
  void generate() {
    a = _random.nextInt(20) + 1;
    b = _random.nextInt(20) + 1;
    notifyListeners();
  }

  @override
  bool checkAnswer(String answer) => int.tryParse(answer) == a + b;

  @override
  String get correctAnswerLabel => '${a + b}';

  @override
  Widget build(BuildContext context) {
    return Text('$a + $b = ?', style: Theme.of(context).textTheme.headlineMedium);
  }
}
