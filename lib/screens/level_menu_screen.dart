import 'package:flutter/material.dart';

import '../data/levels.dart';
import '../widgets/level_card.dart';

class LevelMenuScreen extends StatelessWidget {
  const LevelMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a Puzzle')),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final level = levels[index];
          return LevelCard(
            level: level,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: level.builder));
            },
          );
        },
      ),
    );
  }
}
