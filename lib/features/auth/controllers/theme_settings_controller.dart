import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ThemeSettingsState {
  final AppColorTheme colorTheme;
  final ThemeMode themeMode;

  const ThemeSettingsState({required this.colorTheme, required this.themeMode});

  ThemeSettingsState copyWith({
    AppColorTheme? colorTheme,
    ThemeMode? themeMode,
  }) {
    return ThemeSettingsState(
      colorTheme: colorTheme ?? this.colorTheme,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

final themeSettingsProvider = StateProvider<ThemeSettingsState>((ref) {
  return ThemeSettingsState(
    colorTheme: ColorThemes.greenTheme,
    themeMode: ThemeMode.dark,
  );
});
