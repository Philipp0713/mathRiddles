import 'package:flutter/material.dart';

import 'level_menu_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Math Riddle App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.calculate_outlined, size: 96),
              const SizedBox(height: 16),
              Text(
                'Sharpen your mind with math puzzles',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LevelMenuScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Play'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
