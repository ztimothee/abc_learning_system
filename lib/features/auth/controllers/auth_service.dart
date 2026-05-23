import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/features/auth/models/login_dto.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient supabase;

  AuthService({required this.supabase});

  Future<AuthResponse> login(LoginDTO loginDTO) async {
    final response = await supabase.auth.signInWithPassword(
      email: loginDTO.email,
      password: loginDTO.password,
    );
    return response;
  }

  Future<AuthResponse> signUp(
    LoginDTO loginDTO,
    Profile profile,
  ) async {
    try {
      final response = await supabase.auth.signUp(
        email: loginDTO.email,
        password: loginDTO.password,
        data: profile.toMap(),
      );

      return response;
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }

  bool checkAuthState() {
    final session = supabase.auth.currentSession;

    // If session is not null, the user is authenticated
    return session != null;
  }

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthService(supabase: supabase);
});
