import 'dart:math';

import 'package:flutter/material.dart';

import '../models/riddle.dart';

/// 
///
/// Copy this file as a starting point for new puzzle types — only
/// [generate], [checkAnswer], [correctAnswerLabel], and [build] need to
/// change. Everything else about the screen (score, feedback, keypad) is
/// shared via `RiddleScreen`.
class SequenceRiddle extends Riddle {
  final Random _random = Random();

  late List<int> sequence;

  late int a;
  late int b;
  late int c;

  late int answerPos;

  int function(int n) {
    return a + n*b + n*n*c;
  }

  void initSequenceList() {
    sequence = [];

    for (int i = 0; i < answerPos; i++) {
      sequence.add(function(i));
    }
  }


  @override
  void generate() {
    a = _random.nextInt(20) + 1;
    b = _random.nextInt(5) + 1;
    c = _random.nextInt(3) + 1;

    answerPos = 4;

    initSequenceList();

    notifyListeners();
  }

  @override
  bool checkAnswer(String answer) => int.tryParse(answer) == function(answerPos);

  @override
  String get correctAnswerLabel => '${function(answerPos)}';

  @override
  Widget build(BuildContext context) {
    String text = "";

    for (int element in sequence) {
      text += "$element, ";
    }
    text += "?";


    return Text(text, style: Theme.of(context).textTheme.headlineMedium);
  }
}
