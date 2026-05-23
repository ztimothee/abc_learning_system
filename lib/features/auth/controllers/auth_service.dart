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

  Future<AuthResponse> signUp(LoginDTO loginDTO, Profile profile) async {
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

  Future<void> logout() async {
    await supabase.auth.signOut();
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthService(supabase: supabase);
});

final authStateProvider = StreamProvider<Session?>((ref) {
  final supabase = ref.read(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});
