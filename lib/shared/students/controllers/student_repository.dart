import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/shared/students/models/class_roster_view_dto.dart';
import 'package:abc_learning_system/shared/students/models/student_profile_dto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StudentRepository {
  final SupabaseClient supabase;

  StudentRepository({required this.supabase});

  Future<StudentProfileDTO> getStudentProfileByUserId(String userId) async {
    final response = await supabase
        .from('students')
        .select('''
          student_id,
          display_id,
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

    debugPrint('Raw response from students table: $response');
    return StudentProfileDTO.fromMap(response);
  }

  Future<StudentProfileDTO> getStudentProfileByStudentId(
    String studentId,
  ) async {
    final response = await supabase
        .from('students')
        .select('''
          student_id,
          display_id,
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
        .eq('student_id', studentId)
        .single();

    debugPrint('Raw response from students table: $response');
    return StudentProfileDTO.fromMap(response);
  }

  Future<StudentProfileDTO> getStudentProfileByDisplayId(
    String displayId,
  ) async {
    final response = await supabase
        .from('students')
        .select('''
          student_id,
          display_id,
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
        .eq('display_id', displayId)
        .single();

    debugPrint('Raw response from students table: $response');
    return StudentProfileDTO.fromMap(response);
  }

  Future<List<ClassRosterViewDTO>> getClassRoster({
    required String subjectId,
    required String stubCode,
  }) async {
    // 1. Query your fresh flat database view layout
    final List<Map<String, dynamic>> response = await supabase
        .from('class_roster_view')
        .select()
        .eq('subject_id', subjectId)
        .eq(
          'stub_code',
          stubCode,
        ); // 💡 Directly filters alongside subjectId smoothly!

    // 2. Map the results cleanly into your flat view DTO array packages
    return response.map((data) => ClassRosterViewDTO.fromMap(data)).toList();
  }
}

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return StudentRepository(supabase: supabase);
});

final studentProfileByUserIdProvider =
    FutureProvider.family<StudentProfileDTO, String>((ref, userId) async {
      debugPrint('studentProfileByUserIdProvider called with userId: $userId');
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getStudentProfileByUserId(userId);
    });

final studentProfileByStudentIdProvider =
    FutureProvider.family<StudentProfileDTO, String>((ref, studentId) async {
      debugPrint(
        'studentProfileByStudentIdProvider called with studentId: $studentId',
      );
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getStudentProfileByStudentId(studentId);
    });

final studentProfileByDisplayIdProvider =
    FutureProvider.family<StudentProfileDTO, String>((ref, displayId) async {
      debugPrint(
        'studentProfileByDisplayIdProvider called with displayId: $displayId',
      );
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getStudentProfileByDisplayId(displayId);
    });

final classRosterProvider =
    FutureProvider.family<List<ClassRosterViewDTO>, Map<String, String>>((
      ref,
      params,
    ) async {
      final subjectId = params['subjectId']!;
      final stubCode = params['stubCode']!;
      debugPrint(
        'classRosterProvider called with subjectId: $subjectId, stubCode: $stubCode',
      );
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getClassRoster(
        subjectId: subjectId,
        stubCode: stubCode,
      );
    });
