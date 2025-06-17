import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _followSystemTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get followSystemTheme => _followSystemTheme;

  ThemeProvider() {
    _initializeTheme();
  }

  Future<void> _initializeTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _followSystemTheme = prefs.getBool('follow_system_theme') ?? true;

      if (_followSystemTheme) {
        _isDarkMode = _getSystemTheme();
      } else {
        _isDarkMode = prefs.getBool('is_dark_mode') ?? false;
      }

      notifyListeners();
    } catch (e) {
      _isDarkMode = _getSystemTheme();
      notifyListeners();
    }
  }

  bool _getSystemTheme() {
    final brightness =
        SchedulerBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark;
  }

  void updateSystemTheme(Brightness systemBrightness) {
    if (_followSystemTheme) {
      final newDarkMode = systemBrightness == Brightness.dark;
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        notifyListeners();
      }
    }
  }

  Future<void> toggleTheme() async {
    _followSystemTheme = false;
    _isDarkMode = !_isDarkMode;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> setFollowSystemTheme(bool follow) async {
    _followSystemTheme = follow;

    if (follow) {
      _isDarkMode = _getSystemTheme();
    }

    await _savePreferences();
    notifyListeners();
  }

  Future<void> setTheme(bool isDark) async {
    _followSystemTheme = false;
    _isDarkMode = isDark;
    await _savePreferences();
    notifyListeners();
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', _isDarkMode);
    await prefs.setBool('follow_system_theme', _followSystemTheme);
  }

  Future<void> cycleTheme() async {
    if (_followSystemTheme) {
      // Auto -> Light
      await setTheme(false);
    } else if (!_isDarkMode) {
      // Light -> Dark
      await setTheme(true);
    } else {
      // Dark -> Auto
      await setFollowSystemTheme(true);
    }
  }

  String get currentThemeMode {
    if (_followSystemTheme) return 'Auto';
    return _isDarkMode ? 'Dark' : 'Light';
  }

  void refreshSystemTheme() {
    if (_followSystemTheme) {
      final newDarkMode = _getSystemTheme();
      if (_isDarkMode != newDarkMode) {
        _isDarkMode = newDarkMode;
        notifyListeners();
      }
    }
  }
}
