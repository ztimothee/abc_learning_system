import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/shared/students/models/student_profile_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepository {
  final SupabaseClient supabase;

  StudentRepository({required this.supabase});

  Future<StudentProfileDTO> getStudentProfileById(String userId) async {
    final response = await supabase
        .from('students')
        .select('''
          student_id,
          profiles (
            user_id,
            first_name,
            middle_name,
            last_name,
            date_of_birth,
            gender,
            contact_number,
            address,
            civil_status,
            role
          )
        ''')
        .eq('user_id', userId)
        .single();

    return StudentProfileDTO.fromMap(response);
  }
}

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return StudentRepository(supabase: supabase);
});

final studentProfileProvider = FutureProvider.family<StudentProfileDTO, String>((ref, userId) async {
  final repository = ref.watch(studentRepositoryProvider);
  return await repository.getStudentProfileById(userId);
});