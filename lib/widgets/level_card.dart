import 'package:flutter/material.dart';

import '../models/level.dart';

class LevelCard extends StatelessWidget {
  const LevelCard({super.key, required this.level, required this.onTap});

  final Level level;
  final VoidCallback onTap;

  String _difficultyLabel(LevelDifficulty difficulty) {
    switch (difficulty) {
      case LevelDifficulty.easy:
        return 'Easy';
      case LevelDifficulty.medium:
        return 'Medium';
      case LevelDifficulty.hard:
        return 'Hard';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(child: Icon(level.icon)),
        title: Text(level.title),
        subtitle: Text(level.description),
        trailing: Chip(label: Text(_difficultyLabel(level.difficulty))),
        onTap: onTap,
      ),
    );
  }
}
