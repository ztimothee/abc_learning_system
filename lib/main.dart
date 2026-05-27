import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:abc_learning_system/core/utils/router.dart';
import 'package:abc_learning_system/features/auth/controllers/theme_settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await dotenv.load(fileName: 'assets/.env');

  final url = dotenv.env['SUPABASE_URL'] ?? '';
  final anonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  await Supabase.initialize(url: url, anonKey: anonKey);

  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeSettings = ref.watch(themeSettingsProvider);
    return MaterialApp.router(
      title: 'Flutter Demo',
      theme: AppTheme.light(theme: themeSettings.colorTheme),
      darkTheme: AppTheme.dark(theme: themeSettings.colorTheme),
      themeMode: themeSettings.themeMode,
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}
