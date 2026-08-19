import 'package:flutter/material.dart';

import '../models/riddle.dart';
import '../widgets/answer_pad.dart';
import '../widgets/note_overlay.dart';

/// Shared screen shell for every math puzzle. [riddle] supplies the
/// question shown in the middle of the screen; this widget supplies
/// everything around it — the score, feedback message, and the answer
/// input/keypad pinned to the bottom.
///
/// Adding a new puzzle only requires a new [Riddle] implementation, not a
/// new screen — see `lib/riddles/addition_riddle.dart` and
/// `lib/data/levels.dart`.
class RiddleScreen extends StatefulWidget {
  const RiddleScreen({super.key, required this.title, required this.riddle});

  final String title;
  final Riddle riddle;

  @override
  State<RiddleScreen> createState() => _RiddleScreenState();
}

class _RiddleScreenState extends State<RiddleScreen> {
  final _answerController = TextEditingController();

  int _score = 0;
  String? _feedback;
  Color? _feedbackColor;
  int _generation = 0;
  bool _answerLocked = false;

  @override
  void initState() {
    super.initState();
    widget.riddle.generate();
    widget.riddle.addListener(_onRiddleChanged);
  }

  @override
  void dispose() {
    widget.riddle.removeListener(_onRiddleChanged);
    _answerController.dispose();
    super.dispose();
  }

  void _onRiddleChanged() => setState(() {});

  void _clearFeedback() {
    if (_feedback != null) setState(() => _feedback = null);
  }

  void _checkAnswer() {
    if (_answerController.text.isEmpty) {
      setState(() {
        _feedback = 'Enter a number.';
        _feedbackColor = Colors.orange;
      });
      return;
    }

    final correct = widget.riddle.checkAnswer(_answerController.text);
    setState(() {
      if (correct) {
        _score++;
        _answerLocked = true;
      }
      _feedback = correct ? 'Correct!' : 'Incorrect.';
      _feedbackColor = correct ? Colors.green : Colors.red;
    });
  }

  void _showSolution() {
    setState(() {
      _feedback = 'Answer: ${widget.riddle.correctAnswerLabel}';
      _feedbackColor = Colors.blueGrey;
    });
  }

  void _nextRiddle() {
    setState(() {
      _answerController.clear();
      _feedback = null;
      _answerLocked = false;
      _generation++;
      widget.riddle.generate();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (widget.riddle.hasHint)
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              tooltip: 'Hint',
              onPressed: widget.riddle.revealHint,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Center(child: Text('Score: $_score Points')),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: NoteOverlay(
                key: ValueKey(_generation),
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.riddle.build(context),
                        if (_feedback != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            _feedback!,
                            style: TextStyle(
                              color: _feedbackColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnswerPad(
              controller: _answerController,
              onChanged: _clearFeedback,
              onCheck: _checkAnswer,
              onSolution: _showSolution,
              onNext: _nextRiddle,
              locked: _answerLocked,
            ),
          ],
        ),
      ),
    );
  }
}
