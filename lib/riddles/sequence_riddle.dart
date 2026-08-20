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
  int constantUnary0 = 0, constantUnary1 = 0;

  String hintText = "";

  int _hintsUsed = 0;
  static const _maxExtraTerms = 3;
  static const _baseAnswerPos = 5;
  static const _numberOfUnaryFunctions = 4;
  static const _numberOfBinaryFunctions = 2;

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

  int digitSum(int n) {
    int sum = 0;

    n = n < 0 ? -n : n;

    while (n > 0) {
      sum += n % 10;
      n ~/= 10;
    }

    return sum;
  }

  int simpleUnaryFunction(int n, int type, int constant) {
    return switch(type) {
      0 => n + constant,
      1 => n * (constant == 0 ? 1 : constant),
      2 => n ~/ (constant == 0 ? 1 : constant),
      3 => digitSum(n),
      _ => 1
    };
  }

  int simpleBinaryFunction(int n1, int n2, int type) {
    return switch(type) {
      0 => n1 + n2,
      1 => n1,
      _ => 1
    };
  }

  /// x_n given the two terms before it — the recurrence step shared by
  /// [recursiveFunctionBinary] and, in text form, by
  /// [_recursiveDefinitionText].
  int _recursiveStep(int xMinus2, int xMinus1) {
    return simpleBinaryFunction(
      simpleUnaryFunction(xMinus2, typeUnary0, constantUnary0),
      simpleUnaryFunction(xMinus1, typeUnary1, constantUnary1),
      typeBinary,
    );
  }

  int recursiveFunctionBinary(int n) {
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

  /// A recurrence where x_n depends only on x_{n-1} — simpler than
  /// [recursiveFunctionBinary], which looks two terms back.
  int recursiveFunctionUnary(int n) {
    if (n <= 0) return start0;

    int x = start0;
    for (int i = 1; i <= n; i++) {
      x = simpleUnaryFunction(x, typeUnary0, constantUnary0);
    }

    return x;
  }

  /// Textual form of one [simpleUnaryFunction] term, e.g. "x_(n-2)",
  /// "3·x_(n-2)", or "⌈√x_(n-2)⌉" — the building block for
  /// [_recursiveDefinitionText].
  String _unaryTermText(int type, int constant, String variable) {
    return switch (type) {
      0 => '($variable + $constant)',
      1 => '$variable · $constant',
      2 => '$variable / $constant',
      3 => 'digitSum($variable)',
      _ => '1',
    };
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

  /// [recursiveFunctionUnary]'s own definition, in the same style as
  /// [_recursiveDefinitionText].
  String get _recursiveUnaryDefinitionText {
    final term = _unaryTermText(typeUnary0, constantUnary0, 'x_(n-1)');
    return 'x_0 = $start0, x_n = $term';
  }

  int function(int n) {
    return switch (funType) {
      0 => quadraticFunction(n),
      1 => pow3Function(n),
      2 => recursiveFunctionBinary(n),
      3 => recursiveFunctionUnary(n),
      _ => 0
    };
  }
  @override
  void generate() {
    funType = _random.nextInt(4);

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
        typeBinary = _random.nextInt(_numberOfBinaryFunctions); 
        typeUnary0 = _random.nextInt(_numberOfUnaryFunctions);
        typeUnary1 = _random.nextInt(_numberOfUnaryFunctions); 
        constantUnary0 = _random.nextInt(8) - 3;
        constantUnary1 = _random.nextInt(8) - 3;

        /*
        //Fibonacci Preset:
        start0 = 0;
        start1 = 1;
        typeBinary = 0;
        typeUnary0 = 3;
        typeUnary1 = 3;
        constantUnary0 = 1;
        constantUnary1 = 1;
        */
        

        hintText = _recursiveDefinitionText;
        break;
      case 3: // unary recursive
        start0 = _random.nextInt(10);
        typeUnary0 = _random.nextInt(_numberOfUnaryFunctions);
        constantUnary0 = _random.nextInt(5) - 2;
        if (constantUnary0 == 0) constantUnary0 = 1;
        hintText = _recursiveUnaryDefinitionText;
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
