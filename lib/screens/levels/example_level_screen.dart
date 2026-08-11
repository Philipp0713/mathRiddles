import 'dart:math';

import 'package:flutter/material.dart';

/// Template puzzle screen: a single generated arithmetic riddle with a
/// text-field answer and a "next riddle" action.
///
/// Copy this file as a starting point for new puzzle types. Each level owns
/// its own screen and state, so puzzles can differ arbitrarily in mechanics
/// (multiple choice, drag-and-drop, timers, ...) while still plugging into
/// the same [Level] registration in `lib/data/levels.dart`.
class ExampleLevelScreen extends StatefulWidget {
  const ExampleLevelScreen({super.key});

  @override
  State<ExampleLevelScreen> createState() => _ExampleLevelScreenState();
}

class _ExampleLevelScreenState extends State<ExampleLevelScreen> {
  final _random = Random();
  final _answerController = TextEditingController();

  late int _a;
  late int _b;
  int _score = 0;
  String? _feedback;
  Color? _feedbackColor;

  @override
  void initState() {
    super.initState();
    _generateRiddle();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  void _generateRiddle() {
    _a = _random.nextInt(20) + 1;
    _b = _random.nextInt(20) + 1;
    _answerController.clear();
    _feedback = null;
  }

  void _checkAnswer() {
    final submitted = int.tryParse(_answerController.text);
    final correct = _a + _b;

    setState(() {
      if (submitted == null) {
        _feedback = 'Enter a number.';
        _feedbackColor = Colors.orange;
        return;
      }

      if (submitted == correct) {
        _score++;
        _feedback = 'Correct!';
        _feedbackColor = Colors.green;
      } else {
        _feedback = 'Not quite. The answer was $correct.';
        _feedbackColor = Colors.red;
      }
    });
  }

  void _nextRiddle() {
    setState(_generateRiddle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Addition Riddle'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('Score: $_score')),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$_a + $_b = ?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _answerController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                autofocus: true,
                onSubmitted: (_) => _checkAnswer(),
                decoration: const InputDecoration(
                  labelText: 'Your answer',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (_feedback != null)
                Text(
                  _feedback!,
                  style: TextStyle(color: _feedbackColor, fontSize: 16),
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _checkAnswer,
                    child: const Text('Check'),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _nextRiddle,
                    child: const Text('Next riddle'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
