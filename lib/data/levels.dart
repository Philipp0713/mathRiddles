import 'package:flutter/material.dart';
import 'package:math_riddle_app/riddles/sequence_riddle.dart';

import '../models/level.dart';
import '../riddles/addition_riddle.dart';
import '../screens/riddle_screen.dart';

/// The catalog of playable math puzzles, shown in the level menu.
///
/// To add a new puzzle: create a [Riddle](../models/riddle.dart)
/// implementation under `lib/riddles/` (see `addition_riddle.dart` for a
/// template) and add a [Level] entry here that wraps it in a
/// [RiddleScreen] — no new screen needed. Later, this static list can be
/// replaced or merged with puzzles fetched from a Firestore-backed
/// repository (e.g. AI-generated riddles) without changing the [Level]
/// model or the menu.
final List<Level> levels = [
  Level(
    id: 'example_addition',
    title: 'Addition Riddle',
    description: 'Solve simple addition riddles at your own pace.',
    icon: Icons.add_circle_outline,
    difficulty: LevelDifficulty.easy,
    builder: (context) =>
        RiddleScreen(title: 'Addition Riddle', riddle: AdditionRiddle()),
  ),
  Level(
    id: 'sequence',
    title: 'Sequence Riddle',
    description: 'Solve hard sequence riddles at your own pace.',
    icon: Icons.add_circle_outline,
    difficulty: LevelDifficulty.insane,
    builder: (context) =>
        RiddleScreen(title: 'Sequnce Riddle', riddle: SequenceRiddle()),
  )
];
