import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:abc_learning_system/features/auth/controllers/theme_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);
    final palette = ColorThemes.availableThemes;

    return Scaffold(
      appBar: AppBar(title: const Text('Theme Settings')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text('Choose a color', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: palette.map((themeChoice) {
              final isSelected = themeChoice.name == settings.colorTheme.name;
              return ChoiceChip(
                selected: isSelected,
                onSelected: (_) {
                  ref.read(themeSettingsProvider.notifier).state = settings
                      .copyWith(colorTheme: themeChoice);
                },
                label: Text(themeChoice.name),
                avatar: CircleAvatar(
                  radius: 8,
                  backgroundColor: themeChoice.light,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          Text(
            'Choose light or dark mode',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: ThemeMode.values.map((mode) {
                return RadioListTile<ThemeMode>(
                  value: mode,
                  groupValue: settings.themeMode,
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    ref.read(themeSettingsProvider.notifier).state = settings
                        .copyWith(themeMode: value);
                  },
                  title: Text(_themeModeLabel(mode)),
                  subtitle: Text(_themeModeDescription(mode)),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: settings.colorTheme.light,
                    child: Icon(
                      Icons.palette,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${settings.colorTheme.name} theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'This color is applied to the app in both light and dark mode.',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  String _themeModeDescription(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'Follow the device setting.';
      case ThemeMode.light:
        return 'Always use light mode.';
      case ThemeMode.dark:
        return 'Always use dark mode.';
    }
  }
}
