import 'package:abc_learning_system/core/themes/formatting_functions.dart';
import 'package:abc_learning_system/shared/widgets/info_row.dart';
import 'package:abc_learning_system/features/auth/controllers/theme_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HeaderCard extends ConsumerWidget {
  final String title;
  final String id;
  final String name;

  const HeaderCard({
    super.key,
    required this.title,
    required this.id,
    required this.name,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeSettingsProvider);

    final lightAmount =
        (themeSettings.colorTheme.name == 'Green' ||
            themeSettings.colorTheme.name == 'Teal')
        ? 0.25
        : 0.45;

    final darkAmount =
        (themeSettings.colorTheme.name == 'Green' ||
            themeSettings.colorTheme.name == 'Teal')
        ? 0.08
        : 0.12;

    final colors = [
      darken(themeSettings.colorTheme.light, lightAmount),
      darken(themeSettings.colorTheme.dark, darkAmount),
    ];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 24,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.badge_outlined,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 18,
                  runSpacing: 12,
                  children: [
                    InfoChip(label: 'ID', value: id),
                    InfoChip(label: 'Name', value: name),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
