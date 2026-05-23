import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  Future<AuthResponse> login(String email, String password) async {
    final response = await Supabase.instance.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }

  Future<AuthResponse> signUp(String email, String password) async {
    final response = await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
    return response;
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
  }
}
