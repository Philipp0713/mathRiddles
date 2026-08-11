import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/home_screen.dart';
import 'settings/settings_controller.dart';
import 'theme/app_theme.dart';

class MathRiddleApp extends StatelessWidget {
  const MathRiddleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsController(),
      child: Consumer<SettingsController>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Math Riddle App',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: settings.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
