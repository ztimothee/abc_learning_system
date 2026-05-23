import 'package:abc_learning_system/core/themes/ui.dart';
import 'package:abc_learning_system/features/auth/controllers/auth_service.dart';
import 'package:abc_learning_system/features/auth/models/login_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isPasswordVisible = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login(LoginDTO loginDTO) async {
    final authService = ref.read(authServiceProvider);

    try {
      await authService.login(loginDTO);
      ref.invalidate(authStateProvider);
    } catch (e) {
      // Handle any unexpected errors
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('An error occurred: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final logo = ref.read(imageLogoProvider);

    final baseInputDecoration = const InputDecoration(
      border: OutlineInputBorder(),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    );

    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Card(
              elevation: 6,
              child: Padding(
                padding: const EdgeInsets.all(36.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    logo,
                    const SizedBox(height: 8),
                    const Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextField(
                      controller: _emailController,
                      decoration: baseInputDecoration.copyWith(
                        labelText: 'Email Address',
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: baseInputDecoration.copyWith(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          tooltip: _isPasswordVisible
                              ? 'Hide password'
                              : 'Show password',
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () {
                          final loginDTO = LoginDTO(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          _login(loginDTO);
                        },
                        child: Text('Login', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
