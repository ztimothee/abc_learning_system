import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AppAssets {
  static Image logo({double? width, double? height}) {
    return Image.asset(
      'assets/images/abclogo.png',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }

  static Widget shimmerLogo = Stack(
    children: [
      logo(width: 120),
      Positioned.fill(
        child: Shimmer.fromColors(
          baseColor: Colors.transparent,
          highlightColor: Colors.white.withValues(alpha: 0.6),
          child: logo(width: 120),
        ),
      ),
    ],
  );
}

class AppColorTheme {
  final String name;
  final Color light;
  final Color dark;

  const AppColorTheme({
    required this.name,
    required this.light,
    required this.dark,
  });
}

class ColorThemes {
  static Color get blue => const Color(0xFF2F5BFF);
  static Color get blueSoft => const Color(0xFF6C8CFF);
  static Color get green => const Color(0xFF1F8A4C);
  static Color get greenSoft => const Color(0xFF49B96D);
  static Color get purple => const Color(0xFF7A4DFF);
  static Color get purpleSoft => const Color(0xFFA78BFA);
  static Color get pink => const Color(0xFFFF5FA2);
  static Color get pinkSoft => const Color(0xFFFF8BC0);
  static Color get orange => const Color(0xFFFF9A3D);
  static Color get orangeSoft => const Color(0xFFFFB15C);
  static Color get yellow => const Color(0xFFF5C542);
  static Color get yellowSoft => const Color(0xFFFFD86B);
  static Color get red => const Color(0xFFD93E3E);
  static Color get redSoft => const Color(0xFFFF6B6B);
  static Color get teal => const Color(0xFF00A59A);
  static Color get tealSoft => const Color(0xFF33C7BA);
  static Color get surfaceLight => const Color(0xFFFFFFFF);
  static Color get surfaceDark => const Color(0xFF151B27);
  static Color get backgroundLight => const Color(0xFFF5F6FA);
  static Color get backgroundDark => const Color(0xFF0E1320);
  static Color get textDark => const Color(0xFF1D2433);
  static Color get textLight => const Color(0xFFE7ECF6);

  static AppColorTheme get blueTheme =>
      AppColorTheme(name: 'Blue', light: blue, dark: blueSoft);

  static AppColorTheme get greenTheme =>
      AppColorTheme(name: 'Green', light: green, dark: greenSoft);

  static AppColorTheme get purpleTheme =>
      AppColorTheme(name: 'Purple', light: purple, dark: purpleSoft);

  static AppColorTheme get pinkTheme =>
      AppColorTheme(name: 'Pink', light: pink, dark: pinkSoft);

  static AppColorTheme get orangeTheme =>
      AppColorTheme(name: 'Orange', light: orange, dark: orangeSoft);

  static AppColorTheme get yellowTheme =>
      AppColorTheme(name: 'Yellow', light: yellow, dark: yellowSoft);

  static AppColorTheme get redTheme =>
      AppColorTheme(name: 'Red', light: red, dark: redSoft);

  static AppColorTheme get tealTheme =>
      AppColorTheme(name: 'Teal', light: teal, dark: tealSoft);

  static List<AppColorTheme> get availableThemes => <AppColorTheme>[
    blueTheme,
    greenTheme,
    purpleTheme,
    pinkTheme,
    orangeTheme,
    yellowTheme,
    redTheme,
    tealTheme,
  ];

  static Color get defaultTheme => green;
}

class AppTheme {
  static AppColorTheme get defaultTheme => ColorThemes.greenTheme;

  static ThemeData light({
    AppColorTheme theme = const AppColorTheme(
      name: 'Green',
      light: Color(0xFF1F8A4C),
      dark: Color(0xFF49B96D),
    ),
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: theme.light,
          brightness: Brightness.light,
        ).copyWith(
          primary: theme.light,
          secondary: theme.dark,
          surface: ColorThemes.surfaceLight,
          background: ColorThemes.backgroundLight,
          error: ColorThemes.red,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: ColorThemes.textDark,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF0F2F8),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFD6DAE6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFDDE1EC),
        thickness: 1,
      ),
    );
  }

  static ThemeData dark({
    AppColorTheme theme = const AppColorTheme(
      name: 'Green',
      light: Color(0xFF1F8A4C),
      dark: Color(0xFF49B96D),
    ),
  }) {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: theme.dark,
          brightness: Brightness.dark,
        ).copyWith(
          primary: theme.dark,
          secondary: theme.light,
          surface: ColorThemes.surfaceDark,
          background: ColorThemes.backgroundDark,
          error: ColorThemes.redSoft,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: ColorThemes.textLight,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(fontSize: 16, height: 1.4),
        bodyMedium: TextStyle(fontSize: 14, height: 1.4),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1B2334),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF2A3146)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.6),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2C354B),
        thickness: 1,
      ),
    );
  }
}
