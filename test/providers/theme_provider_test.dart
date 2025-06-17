import 'package:gymme/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  ThemeProvider? themeProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    themeProvider = null;
  });

  tearDown(() {
    if (themeProvider != null) {
      themeProvider!.dispose();
      themeProvider = null;
    }
  });

  group('ThemeProvider Initialization Tests', () {
    testWidgets('should initialize with system theme by default', (
      WidgetTester tester,
    ) async {
      themeProvider = ThemeProvider();
      await tester.pumpAndSettle();

      expect(themeProvider!.followSystemTheme, true);

      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      expect(themeProvider!.isDarkMode, systemBrightness == Brightness.dark);
    });

    testWidgets('should initialize with saved preferences when available', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'follow_system_theme': false,
        'is_dark_mode': true,
      });

      themeProvider = ThemeProvider();
      await tester.pumpAndSettle();

      expect(themeProvider!.followSystemTheme, false);
      expect(themeProvider!.isDarkMode, true);
    });
  });

  group('Theme Toggle Tests', () {
    setUp(() async {
      themeProvider = ThemeProvider();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets('toggleTheme should switch theme and disable system follow', (
      WidgetTester tester,
    ) async {
      final initialDarkMode = themeProvider!.isDarkMode;
      var notifyCount = 0;
      themeProvider!.addListener(() => notifyCount++);

      await themeProvider!.toggleTheme();
      await tester.pumpAndSettle();

      expect(themeProvider!.isDarkMode, !initialDarkMode);
      expect(themeProvider!.followSystemTheme, false);
      expect(notifyCount, 1);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('is_dark_mode'), !initialDarkMode);
      expect(prefs.getBool('follow_system_theme'), false);
    });

    testWidgets(
      'setTheme should set specific theme and disable system follow',
      (WidgetTester tester) async {
        var notifyCount = 0;
        themeProvider!.addListener(() => notifyCount++);

        await themeProvider!.setTheme(true);
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, true);
        expect(themeProvider!.followSystemTheme, false);
        expect(notifyCount, 1);

        await themeProvider!.setTheme(false);
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, false);
        expect(themeProvider!.followSystemTheme, false);
        expect(notifyCount, 2);
      },
    );

    testWidgets('setFollowSystemTheme should enable/disable system following', (
      WidgetTester tester,
    ) async {
      var notifyCount = 0;
      themeProvider!.addListener(() => notifyCount++);

      await themeProvider!.setFollowSystemTheme(false);
      await tester.pumpAndSettle();

      expect(themeProvider!.followSystemTheme, false);
      expect(notifyCount, 1);

      await themeProvider!.setFollowSystemTheme(true);
      await tester.pumpAndSettle();

      expect(themeProvider!.followSystemTheme, true);
      final systemBrightness =
          SchedulerBinding.instance.platformDispatcher.platformBrightness;
      expect(themeProvider!.isDarkMode, systemBrightness == Brightness.dark);
      expect(notifyCount, 2);
    });
  });

  group('Cycle Theme Tests', () {
    setUp(() async {
      themeProvider = ThemeProvider();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets('cycleTheme should cycle Auto -> Light -> Dark -> Auto', (
      WidgetTester tester,
    ) async {
      // Start with Auto (system follow)
      await themeProvider!.setFollowSystemTheme(true);
      expect(themeProvider!.currentThemeMode, 'Auto');

      // Auto -> Light
      await themeProvider!.cycleTheme();
      await tester.pumpAndSettle();
      expect(themeProvider!.currentThemeMode, 'Light');
      expect(themeProvider!.isDarkMode, false);
      expect(themeProvider!.followSystemTheme, false);

      // Light -> Dark
      await themeProvider!.cycleTheme();
      await tester.pumpAndSettle();
      expect(themeProvider!.currentThemeMode, 'Dark');
      expect(themeProvider!.isDarkMode, true);
      expect(themeProvider!.followSystemTheme, false);

      // Dark -> Auto
      await themeProvider!.cycleTheme();
      await tester.pumpAndSettle();
      expect(themeProvider!.currentThemeMode, 'Auto');
      expect(themeProvider!.followSystemTheme, true);
    });

    testWidgets('currentThemeMode should return correct mode strings', (
      WidgetTester tester,
    ) async {
      await themeProvider!.setFollowSystemTheme(true);
      expect(themeProvider!.currentThemeMode, 'Auto');

      await themeProvider!.setTheme(false);
      expect(themeProvider!.currentThemeMode, 'Light');

      await themeProvider!.setTheme(true);
      expect(themeProvider!.currentThemeMode, 'Dark');
    });
  });

  group('System Theme Update Tests', () {
    setUp(() async {
      themeProvider = ThemeProvider();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets(
      'updateSystemTheme should update theme when following system and not when not following',
      (WidgetTester tester) async {
        // Following system theme
        await themeProvider!.setFollowSystemTheme(true);
        var notifyCount = 0;
        void listener() => notifyCount++;
        themeProvider!.addListener(listener);

        themeProvider!.updateSystemTheme(Brightness.dark);
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, true);
        expect(notifyCount, 1);

        themeProvider!.updateSystemTheme(Brightness.light);
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, false);
        expect(notifyCount, 2);

        // Not following system theme
        await themeProvider!.setFollowSystemTheme(false);
        await themeProvider!.setTheme(true);
        notifyCount = 0;

        themeProvider!.updateSystemTheme(Brightness.light);
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, true);
        expect(notifyCount, 0);

        themeProvider!.removeListener(listener);
      },
    );

    testWidgets(
      'refreshSystemTheme should update theme when following system and not when not following',
      (WidgetTester tester) async {
        await themeProvider!.setFollowSystemTheme(true);
        var notifyCount = 0;
        void listener() => notifyCount++;
        themeProvider!.addListener(listener);

        themeProvider!.refreshSystemTheme();
        await tester.pumpAndSettle();

        final systemBrightness =
            SchedulerBinding.instance.platformDispatcher.platformBrightness;
        expect(themeProvider!.isDarkMode, systemBrightness == Brightness.dark);
        expect(
          notifyCount,
          lessThanOrEqualTo(1),
        ); // notifyCount might be 0 or 1 depending on whether the theme actually changed

        await themeProvider!.setFollowSystemTheme(false);
        await themeProvider!.setTheme(true);
        notifyCount = 0;

        themeProvider!.refreshSystemTheme();
        await tester.pumpAndSettle();

        expect(themeProvider!.isDarkMode, true);
        expect(notifyCount, 0);
      },
    );
  });

  group('Persistence Tests', () {
    testWidgets('preferences should be saved correctly', (
      WidgetTester tester,
    ) async {
      themeProvider = ThemeProvider();
      await tester.pumpAndSettle();

      await themeProvider!.setTheme(true);
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('is_dark_mode'), true);
        expect(prefs.getBool('follow_system_theme'), false);
      });

      await themeProvider!.setFollowSystemTheme(true);
      await tester.pumpAndSettle();

      await tester.runAsync(() async {
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getBool('follow_system_theme'), true);
      });
    });
  });

  group('Getters Tests', () {
    setUp(() async {
      themeProvider = ThemeProvider();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets('isDarkMode getter should return correct value', (
      WidgetTester tester,
    ) async {
      await themeProvider!.setTheme(false);
      expect(themeProvider!.isDarkMode, false);

      await themeProvider!.setTheme(true);
      expect(themeProvider!.isDarkMode, true);
    });

    testWidgets('followSystemTheme getter should return correct value', (
      WidgetTester tester,
    ) async {
      await themeProvider!.setFollowSystemTheme(true);
      expect(themeProvider!.followSystemTheme, true);

      await themeProvider!.setFollowSystemTheme(false);
      expect(themeProvider!.followSystemTheme, false);
    });
  });

  group('Listener Notification Tests', () {
    setUp(() async {
      themeProvider = ThemeProvider();
      await Future.delayed(Duration(milliseconds: 100));
    });

    testWidgets('should notify listeners on theme changes', (
      WidgetTester tester,
    ) async {
      var notifyCount = 0;
      themeProvider!.addListener(() => notifyCount++);

      await themeProvider!.toggleTheme();
      expect(notifyCount, 1);

      await themeProvider!.setTheme(false);
      expect(notifyCount, 2);

      await themeProvider!.setFollowSystemTheme(true);
      expect(notifyCount, 3);

      await themeProvider!.cycleTheme();
      expect(notifyCount, 4);
    });
  });
}
