import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/features/auth/models/login_dto.dart';
import 'package:abc_learning_system/features/auth/models/profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final Ref ref;
  final SupabaseClient supabase;

  AuthService({required this.supabase, required this.ref});

  Future<AuthResponse> login(LoginDTO loginDTO) async {
    ref.read(isLoggingOutProvider.notifier).state = false;
    debugPrint('AuthService.login called with DTO: $loginDTO');
    final response = await supabase.auth.signInWithPassword(
      email: loginDTO.email,
      password: loginDTO.password,
    );
    debugPrint('AuthService.login response: $response');
    return response;
  }

  Future<AuthResponse> signUp(LoginDTO loginDTO, Profile profile) async {
    debugPrint(
      'AuthService.signUp called with DTO: $loginDTO and Profile: $profile',
    );
    try {
      final response = await supabase.auth.signUp(
        email: loginDTO.email,
        password: loginDTO.password,
        data: profile.toMap(),
      );
      debugPrint('AuthService.signUp response: $response');

      return response;
    } catch (e) {
      debugPrint('AuthService.signUp error: $e');
      throw Exception('Failed to sign up: $e');
    }
  }

  Future<void> logout() async {
    ref.read(isLoggingOutProvider.notifier).state = true;
    try {
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('AuthService.logout error: $e');
      throw Exception('Failed to log out: $e');
    } finally {
      ref.read(isLoggingOutProvider.notifier).state = false;
    }
  }
}

// Provider to access AuthService throughout the app
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.read(supabaseProvider);
  return AuthService(supabase: supabase, ref: ref);
});

// Checks if the user is authenticated and provides the session data
final authStateProvider = StreamProvider((ref) {
  final supabase = ref.read(supabaseProvider);
  return supabase.auth.onAuthStateChange.map((event) => event.session);
});

// Check if the user is currently logging out for state management purposes
final isLoggingOutProvider = StateProvider<bool>((ref) => false);

// Provider to access the user's profile data
final userProfileProvider = FutureProvider<Profile?>((ref) async {
  final supabase = ref.read(supabaseProvider);
  ref.watch(authStateProvider);
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null;
  }

  final baseData = await supabase
      .from('profiles')
      .select('role')
      .eq('user_id', user.id)
      .single();

  final String role = baseData['role'] ?? 'student';

  String selectQuery = '*';
  if (role == 'staff') {
    selectQuery = '*, staffs(position)';
  }

  final fullData = await supabase
      .from('profiles')
      .select(selectQuery)
      .eq('user_id', user.id)
      .single();

  return Profile.fromMap(fullData);
});
