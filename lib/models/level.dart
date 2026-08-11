import 'package:flutter/widgets.dart';

enum LevelDifficulty { easy, medium, hard }

/// A single playable math puzzle shown in the level menu.
///
/// [builder] creates the puzzle's own screen, so each level is free to
/// implement its mechanics however it likes. New puzzle types are added by
/// building a screen and registering a [Level] for it — see
/// `lib/data/levels.dart`.
class Level {
  const Level({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.difficulty,
    required this.builder,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final LevelDifficulty difficulty;
  final WidgetBuilder builder;
}
