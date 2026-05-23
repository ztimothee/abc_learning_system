import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => Scaffold(body: const CircularProgressIndicator()),
      error: (error, stackTrace) =>
          const Scaffold(body: Center(child: Text('An error occurred.'))),
      data: (session) => session != null
          ? const Scaffold(
              body: Center(child: Text('Welcome to the ABC Learning System!')),
            )
          : const LoginScreen(),
    );
  }
}
