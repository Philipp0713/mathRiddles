import 'dart:math';

import 'package:flutter/material.dart';

import '../models/riddle.dart';

/// Sequence riddle: given a run of terms from a quadratic function
/// `f(n) = a + b*n + c*n^2`, guess the next one.
///
/// Demonstrates a multi-step hint: each press reveals one more term on
/// the right of the sequence — the term that used to be the answer
/// becomes visible, and the question mark moves one further out — and,
/// once three extra terms have been shown, a final press reveals the
/// underlying function as text.
class SequenceRiddle extends Riddle {
  final Random _random = Random();

  int funType = 0;

  int a = 0;
  int b = 0;
  int c = 0;
  int d = 0;
  int offset = 0;

  int start0 = 0, start1 = 0, typeBinary = 0, typeUnary0 = 0, typeUnary1 = 0; 
  double constantUnary0 = 0.0, constantUnary1 = 0.0;

  String hintText = "";

  int _hintsUsed = 0;
  static const _maxExtraTerms = 3;
  static const _baseAnswerPos = 5;

  /// The position being asked about. Starts at [_baseAnswerPos] and moves
  /// one further out per hint used, since each hint reveals the term that
  /// used to sit there.
  int get answerPos => _baseAnswerPos + _hintsUsed.clamp(0, _maxExtraTerms);

  /// The offset written as a signed suffix, e.g. "+4", "-4", or "" for 0.
  String signedNumber(int num) {
    if (num == 0) {
      return "";
    }
    if (num > 0) {
      return '+$num';
    }
    return '-${-num}';
  } 

  int quadraticFunction(int n) {
    n += offset;
    return a + n * b + n * n * c;
  }

  int pow3Function(int n) {
    n += offset;
    return a + n * b + n * n * n * d;
  }

  int simpleUnaryFunction(int n, int type, double constant) {
    return (switch(type) {
      0 => n,
      _ => 1
    } * constant).round();
  }

  int simpleBinaryFunction(int n1, int n2, int type) {
    return switch(type) {
      0 => n1 + n2,
      1 => n1,
      _ => 1
    };
  }

  /// x_n given the two terms before it — the recurrence step shared by
  /// [recursiveFunction] and, in text form, by [_recursiveDefinitionText].
  int _recursiveStep(int xMinus2, int xMinus1) {
    return simpleBinaryFunction(
      simpleUnaryFunction(xMinus2, typeUnary0, constantUnary0),
      simpleUnaryFunction(xMinus1, typeUnary1, constantUnary1),
      typeBinary,
    );
  }

  int recursiveFunction(int n) {
    if (n <= 0) return start0;
    if (n == 1) return start1;

    int xMinus2 = start0;
    int xMinus1 = start1;
    int xN = xMinus1;
    for (int i = 2; i <= n; i++) {
      xN = _recursiveStep(xMinus2, xMinus1);
      xMinus2 = xMinus1;
      xMinus1 = xN;
    }

    return xN;
  }

  /// Textual form of one [simpleUnaryFunction] term, e.g. "x_(n-2)",
  /// "3·x_(n-2)", or "⌈√x_(n-2)⌉" — the building block for
  /// [_recursiveDefinitionText].
  String _unaryTermText(int type, double constant, String variable) {
    final core = switch (type) {
      0 => variable,
      _ => '1',
    };
    if (constant == 0) return '0';
    if (constant == 1) return core;
    final constantText = constant == constant.roundToDouble()
        ? constant.toInt().toString()
        : '$constant';
    return '$constantText·$core';
  }

  String _binaryTermText(String term0, String term1, int type) {
    return switch (type) {
      0 => '$term0 + $term1',
      1 => term0,
      _ => '1',
    };
  }

  /// The recursive function's own definition, written the same way the
  /// quadratic/cubic hints show theirs — used as the final-hint text.
  String get _recursiveDefinitionText {
    final term0 = _unaryTermText(typeUnary0, constantUnary0, 'x_(n-2)');
    final term1 = _unaryTermText(typeUnary1, constantUnary1, 'x_(n-1)');
    final body = _binaryTermText(term0, term1, typeBinary);
    return 'x_0 = $start0, x_1 = $start1, x_n = $body';
  }

  int function(int n) {
    return switch (funType) {
      0 => quadraticFunction(n),
      1 => pow3Function(n),
      2 => recursiveFunction(n),
      _ => 0
    };
  }
  @override
  void generate() {
    funType = _random.nextInt(3);

    offset = _random.nextInt(3) - 1;

    switch (funType) {
      case 0: //quadratic
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(11) - 5;
        c = _random.nextInt(3) + 1;
        hintText =
            'f(n) = $a + $b·(n${signedNumber(offset)}) + $c·(n${signedNumber(offset)})²';
        break;
      case 1: //pow 3
        a = _random.nextInt(10) + 1;
        b = _random.nextInt(11) - 5;
        d = _random.nextInt(2) + 1;
        hintText =
            'f(n) = $a + $b·(n${signedNumber(offset)}) + $d·(n${signedNumber(offset)})³';
        break; //recursive function
      case 2:
        start0 = _random.nextInt(10); 
        start1 = _random.nextInt(10); 
        typeBinary = _random.nextInt(2); 
        typeUnary0 = _random.nextInt(1);
        typeUnary1 = _random.nextInt(1); 
        constantUnary0 = _random.nextInt(10).toDouble();
        constantUnary1 = _random.nextInt(10).toDouble();

        /*
        //Fibonacci Preset:
        start0 = 0; 
        start1 = 1; 
        typeBinary = 0; 
        typeUnary0 = 3;
        typeUnary1 = 3; 
        constantUnary0 = 1.toDouble();
        constantUnary1 = 1.toDouble();
        */
        

        hintText = _recursiveDefinitionText;
      default:
    }

    _hintsUsed = 0;
    notifyListeners();
  }

  @override
  bool checkAnswer(String answer) =>
      int.tryParse(answer) == function(answerPos);

  @override
  String get correctAnswerLabel => '${function(answerPos)}';

  @override
  bool get hasHint => _hintsUsed <= _maxExtraTerms;

  @override
  void revealHint() {
    _hintsUsed++;
    notifyListeners();
  }

  bool get _formulaRevealed => _hintsUsed > _maxExtraTerms;

  @override
  Widget build(BuildContext context) {
    final terms = [for (int n = 0; n < answerPos; n++) function(n)];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '${terms.join(', ')}, ?',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        if (_formulaRevealed) ...[
          const SizedBox(height: 12),
          Text(
            hintText,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }
}
