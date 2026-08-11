import 'package:flutter/material.dart';

/// Holds app-wide settings.
///
/// In-memory only for now. If settings need to survive an app restart,
/// back this with `shared_preferences` (or the user's Firestore profile
/// once accounts exist) without changing how screens read/write it.
class SettingsController extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _soundEffectsEnabled = true;

  ThemeMode get themeMode => _themeMode;
  bool get soundEffectsEnabled => _soundEffectsEnabled;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  void setSoundEffectsEnabled(bool enabled) {
    if (_soundEffectsEnabled == enabled) return;
    _soundEffectsEnabled = enabled;
    notifyListeners();
  }
}
