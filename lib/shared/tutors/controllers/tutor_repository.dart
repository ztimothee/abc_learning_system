import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/shared/tutors/models/tutor_profile_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TutorRepository {
  final SupabaseClient supabase;

  TutorRepository({required this.supabase});

  Future<TutorProfileDTO> getTutorProfileByUserId(String userId) async {
    final response = await supabase
        .from('tutors')
        .select('''
          tutor_id,
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
        .eq('user_id', userId);

    debugPrint('Raw response from tutors table: $response');
    return TutorProfileDTO.fromMap(response.first);
  }

  Future<TutorProfileDTO> getTutorProfileByTutorId(String tutorId) async {
    final response = await supabase
        .from('tutors')
        .select('''
          tutor_id,
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
        .eq('tutor_id', tutorId);

    debugPrint('Raw response from tutors table: $response');
    return TutorProfileDTO.fromMap(response.first);
  }
}

final tutorRepositoryProvider = Provider<TutorRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return TutorRepository(supabase: supabase);
});

final tutorProfileByUserIdProvider =
    FutureProvider.family<TutorProfileDTO, String>((ref, userId) async {
      final repository = ref.watch(tutorRepositoryProvider);
      return repository.getTutorProfileByUserId(userId);
    });

final tutorProfileByTutorIdProvider =
    FutureProvider.family<TutorProfileDTO, String>((ref, tutorId) async {
      final repository = ref.watch(tutorRepositoryProvider);
      return repository.getTutorProfileByTutorId(tutorId);
    });
