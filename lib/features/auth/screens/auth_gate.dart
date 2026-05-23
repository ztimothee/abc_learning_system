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
    final authService = ref.watch(authServiceProvider);
    final isAuthenticated = authService.checkAuthState();

    if (isAuthenticated) {
      // If the user is authenticated, show the main app screen
      return Scaffold(
        body: Center(
          child: Text('Welcome to the ABC Learning System!'),
        ),
      );
    } else {
      // If the user is not authenticated, show the login screen
      return const LoginScreen();
    }
  }
}