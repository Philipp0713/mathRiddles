import 'package:flutter/material.dart';

import '../models/level.dart';
import '../screens/levels/example_level_screen.dart';

/// The catalog of playable math puzzles, shown in the level menu.
///
/// To add a new puzzle: build its screen under `lib/screens/levels/` and
/// add a [Level] entry here. Later, this static list can be replaced or
/// merged with puzzles fetched from a Firestore-backed repository (e.g.
/// AI-generated riddles) without changing the [Level] model or the menu.
final List<Level> levels = [
  Level(
    id: 'example_addition',
    title: 'Addition Riddle',
    description: 'Solve simple addition riddles at your own pace.',
    icon: Icons.add_circle_outline,
    difficulty: LevelDifficulty.easy,
    builder: (context) => const ExampleLevelScreen(),
  ),
];
