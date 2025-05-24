import "package:flutter/material.dart";

/*
  LAVANDA #FFAE94FC RGB: 174 148 252
  MIRTILLO #FF221743 RGB: 34 23 67
  GIALLO #FFFFD73C RGB: 255 255 215 60
  SABBIA #FFFDF7EA RGB: 255 253 247 234 
  ROSA #FFFEACF0
  CORALLO #FFFB5C1C
*/
class MaterialTheme {
  final TextTheme textTheme;

  const MaterialTheme(this.textTheme);

  static ColorScheme lightScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff080025),
      surfaceTint: Color(0xff635787),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff221743),
      onPrimaryContainer: Color(0xff8c7fb2),
      secondary: Color(0xff715c00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xffffd73c),
      onSecondaryContainer: Color(0xff725d00),
      tertiary: Color(0xff894582),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xfffeacf0),
      onTertiaryContainer: Color(0xff7c3a75),
      error: Color(0xffab3500),
      onError: Color(0xffffffff),
      errorContainer: Color(0xfffb5c1c),
      onErrorContainer: Color(0xff511500),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff1c1b1a),
      onSurfaceVariant: Color(0xff494551),
      outline: Color(0xff7a7583),
      outlineVariant: Color(0xffcac4d3),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xffcdbff5),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff1f133f),
      primaryFixedDim: Color(0xffcdbff5),
      onPrimaryFixedVariant: Color(0xff4b406e),
      secondaryFixed: Color(0xffffe17a),
      onSecondaryFixed: Color(0xff231b00),
      secondaryFixedDim: Color(0xffeac326),
      onSecondaryFixedVariant: Color(0xff554500),
      tertiaryFixed: Color(0xffffd7f4),
      onTertiaryFixed: Color(0xff380037),
      tertiaryFixedDim: Color(0xfffeacf0),
      onTertiaryFixedVariant: Color(0xff6e2d68),
      surfaceDim: Color(0xffddd9d7),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f1),
      surfaceContainer: Color(0xfff1edeb),
      surfaceContainerHigh: Color(0xffebe7e5),
      surfaceContainerHighest: Color(0xffe6e2e0),
    );
  }

  ThemeData light() {
    return theme(lightScheme());
  }

  static ColorScheme lightMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff080025),
      surfaceTint: Color(0xff635787),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff221743),
      onPrimaryContainer: Color(0xffb0a2d7),
      secondary: Color(0xff423500),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff826b00),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff5b1c56),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff9a5491),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff661c00),
      onError: Color(0xffffffff),
      errorContainer: Color(0xffc43f00),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff121110),
      onSurfaceVariant: Color(0xff383440),
      outline: Color(0xff55505d),
      outlineVariant: Color(0xff706b79),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xffcdbff5),
      primaryFixed: Color(0xff726697),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff594e7d),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff826b00),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff665300),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff9a5491),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff7e3c77),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffc9c6c4),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff7f3f1),
      surfaceContainer: Color(0xffebe7e5),
      surfaceContainerHigh: Color(0xffe0dcda),
      surfaceContainerHighest: Color(0xffd5d1cf),
    );
  }

  ThemeData lightMediumContrast() {
    return theme(lightMediumContrastScheme());
  }

  static ColorScheme lightHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: Color(0xff080025),
      surfaceTint: Color(0xff635787),
      onPrimary: Color(0xffffffff),
      primaryContainer: Color(0xff221743),
      onPrimaryContainer: Color(0xffdacdff),
      secondary: Color(0xff362b00),
      onSecondary: Color(0xffffffff),
      secondaryContainer: Color(0xff584800),
      onSecondaryContainer: Color(0xffffffff),
      tertiary: Color(0xff4f104b),
      onTertiary: Color(0xffffffff),
      tertiaryContainer: Color(0xff71306b),
      onTertiaryContainer: Color(0xffffffff),
      error: Color(0xff551600),
      onError: Color(0xffffffff),
      errorContainer: Color(0xff872800),
      onErrorContainer: Color(0xffffffff),
      surface: Color(0xfffdf8f6),
      onSurface: Color(0xff000000),
      onSurfaceVariant: Color(0xff000000),
      outline: Color(0xff2e2a36),
      outlineVariant: Color(0xff4b4754),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xff31302f),
      inversePrimary: Color(0xffcdbff5),
      primaryFixed: Color(0xff4d4270),
      onPrimaryFixed: Color(0xffffffff),
      primaryFixedDim: Color(0xff362b58),
      onPrimaryFixedVariant: Color(0xffffffff),
      secondaryFixed: Color(0xff584800),
      onSecondaryFixed: Color(0xffffffff),
      secondaryFixedDim: Color(0xff3e3100),
      onSecondaryFixedVariant: Color(0xffffffff),
      tertiaryFixed: Color(0xff71306b),
      onTertiaryFixed: Color(0xffffffff),
      tertiaryFixedDim: Color(0xff561853),
      onTertiaryFixedVariant: Color(0xffffffff),
      surfaceDim: Color(0xffbbb8b6),
      surfaceBright: Color(0xfffdf8f6),
      surfaceContainerLowest: Color(0xffffffff),
      surfaceContainerLow: Color(0xfff4f0ee),
      surfaceContainer: Color(0xffe6e2e0),
      surfaceContainerHigh: Color(0xffd7d4d2),
      surfaceContainerHighest: Color(0xffc9c6c4),
    );
  }

  ThemeData lightHighContrast() {
    return theme(lightHighContrastScheme());
  }

  static ColorScheme darkScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffcdbff5),
      surfaceTint: Color(0xffcdbff5),
      onPrimary: Color(0xff342956),
      primaryContainer: Color(0xff221743),
      onPrimaryContainer: Color(0xff8c7fb2),
      secondary: Color(0xfffff6e3),
      onSecondary: Color(0xff3b2f00),
      secondaryContainer: Color(0xffffd73c),
      onSecondaryContainer: Color(0xff725d00),
      tertiary: Color(0xffffd7f4),
      onTertiary: Color(0xff541550),
      tertiaryContainer: Color(0xfffeacf0),
      onTertiaryContainer: Color(0xff7c3a75),
      error: Color(0xffffb59c),
      onError: Color(0xff5c1900),
      errorContainer: Color(0xfffb5c1c),
      onErrorContainer: Color(0xff511500),
      surface: Color(0xff141312),
      onSurface: Color(0xffe6e2e0),
      onSurfaceVariant: Color(0xffcac4d3),
      outline: Color(0xff948e9d),
      outlineVariant: Color(0xff494551),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e0),
      inversePrimary: Color(0xff635787),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff1f133f),
      primaryFixedDim: Color(0xffcdbff5),
      onPrimaryFixedVariant: Color(0xff4b406e),
      secondaryFixed: Color(0xffffe17a),
      onSecondaryFixed: Color(0xff231b00),
      secondaryFixedDim: Color(0xffeac326),
      onSecondaryFixedVariant: Color(0xff554500),
      tertiaryFixed: Color(0xffffd7f4),
      onTertiaryFixed: Color(0xff380037),
      tertiaryFixedDim: Color(0xfffeacf0),
      onTertiaryFixedVariant: Color(0xff6e2d68),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff3a3938),
      surfaceContainerLowest: Color(0xff0f0e0d),
      surfaceContainerLow: Color(0xff1c1b1a),
      surfaceContainer: Color(0xff201f1e),
      surfaceContainerHigh: Color(0xff2b2a29),
      surfaceContainerHighest: Color(0xff363433),
    );
  }

  ThemeData dark() {
    return theme(darkScheme());
  }

  static ColorScheme darkMediumContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xffe2d6ff),
      surfaceTint: Color(0xffcdbff5),
      onPrimary: Color(0xff291e4a),
      primaryContainer: Color(0xff9689bd),
      onPrimaryContainer: Color(0xff000000),
      secondary: Color(0xfffff6e3),
      onSecondary: Color(0xff3b2f00),
      secondaryContainer: Color(0xffffd73c),
      onSecondaryContainer: Color(0xff514200),
      tertiary: Color(0xffffd7f4),
      onTertiary: Color(0xff4c0d49),
      tertiaryContainer: Color(0xfffeacf0),
      onTertiaryContainer: Color(0xff5b1c57),
      error: Color(0xffffd3c5),
      onError: Color(0xff4a1200),
      errorContainer: Color(0xfffb5c1c),
      onErrorContainer: Color(0xff000000),
      surface: Color(0xff141312),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffe1d9e9),
      outline: Color(0xffb5afbe),
      outlineVariant: Color(0xff938e9c),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e0),
      inversePrimary: Color(0xff4c416f),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff140735),
      primaryFixedDim: Color(0xffcdbff5),
      onPrimaryFixedVariant: Color(0xff3a2f5c),
      secondaryFixed: Color(0xffffe17a),
      onSecondaryFixed: Color(0xff161100),
      secondaryFixedDim: Color(0xffeac326),
      onSecondaryFixedVariant: Color(0xff423500),
      tertiaryFixed: Color(0xffffd7f4),
      onTertiaryFixed: Color(0xff270026),
      tertiaryFixedDim: Color(0xfffeacf0),
      onTertiaryFixedVariant: Color(0xff5b1c56),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff464443),
      surfaceContainerLowest: Color(0xff080707),
      surfaceContainerLow: Color(0xff1e1d1c),
      surfaceContainer: Color(0xff292827),
      surfaceContainerHigh: Color(0xff333231),
      surfaceContainerHighest: Color(0xff3f3d3c),
    );
  }

  ThemeData darkMediumContrast() {
    return theme(darkMediumContrastScheme());
  }

  static ColorScheme darkHighContrastScheme() {
    return const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xfff4edff),
      surfaceTint: Color(0xffcdbff5),
      onPrimary: Color(0xff000000),
      primaryContainer: Color(0xffc9bbf1),
      onPrimaryContainer: Color(0xff0e022f),
      secondary: Color(0xfffff6e3),
      onSecondary: Color(0xff000000),
      secondaryContainer: Color(0xffffd73c),
      onSecondaryContainer: Color(0xff2d2300),
      tertiary: Color(0xffffeaf7),
      onTertiary: Color(0xff000000),
      tertiaryContainer: Color(0xfffeacf0),
      onTertiaryContainer: Color(0xff270026),
      error: Color(0xffffece7),
      onError: Color(0xff000000),
      errorContainer: Color(0xffffaf95),
      onErrorContainer: Color(0xff1d0400),
      surface: Color(0xff141312),
      onSurface: Color(0xffffffff),
      onSurfaceVariant: Color(0xffffffff),
      outline: Color(0xfff4edfd),
      outlineVariant: Color(0xffc6c0cf),
      shadow: Color(0xff000000),
      scrim: Color(0xff000000),
      inverseSurface: Color(0xffe6e2e0),
      inversePrimary: Color(0xff4c416f),
      primaryFixed: Color(0xffe8ddff),
      onPrimaryFixed: Color(0xff000000),
      primaryFixedDim: Color(0xffcdbff5),
      onPrimaryFixedVariant: Color(0xff140735),
      secondaryFixed: Color(0xffffe17a),
      onSecondaryFixed: Color(0xff000000),
      secondaryFixedDim: Color(0xffeac326),
      onSecondaryFixedVariant: Color(0xff161100),
      tertiaryFixed: Color(0xffffd7f4),
      onTertiaryFixed: Color(0xff000000),
      tertiaryFixedDim: Color(0xfffeacf0),
      onTertiaryFixedVariant: Color(0xff270026),
      surfaceDim: Color(0xff141312),
      surfaceBright: Color(0xff51504e),
      surfaceContainerLowest: Color(0xff000000),
      surfaceContainerLow: Color(0xff201f1e),
      surfaceContainer: Color(0xff31302f),
      surfaceContainerHigh: Color(0xff3c3b3a),
      surfaceContainerHighest: Color(0xff484645),
    );
  }

  ThemeData darkHighContrast() {
    return theme(darkHighContrastScheme());
  }

  ThemeData theme(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    brightness: colorScheme.brightness,
    colorScheme: colorScheme,
    textTheme: textTheme.apply(
      bodyColor: colorScheme.onSurface,
      displayColor: colorScheme.onSurface,
    ),
    scaffoldBackgroundColor: colorScheme.background,
    canvasColor: colorScheme.surface,
  );

  List<ExtendedColor> get extendedColors => [];
}

class ExtendedColor {
  final Color seed, value;
  final ColorFamily light;
  final ColorFamily lightHighContrast;
  final ColorFamily lightMediumContrast;
  final ColorFamily dark;
  final ColorFamily darkHighContrast;
  final ColorFamily darkMediumContrast;

  const ExtendedColor({
    required this.seed,
    required this.value,
    required this.light,
    required this.lightHighContrast,
    required this.lightMediumContrast,
    required this.dark,
    required this.darkHighContrast,
    required this.darkMediumContrast,
  });
}

class ColorFamily {
  const ColorFamily({
    required this.color,
    required this.onColor,
    required this.colorContainer,
    required this.onColorContainer,
  });

  final Color color;
  final Color onColor;
  final Color colorContainer;
  final Color onColorContainer;
}
