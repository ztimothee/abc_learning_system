import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/shared/students/models/student_master_list_dto.dart';
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

  Future<List<StudentProfileDTO>> getStudentsByStubCode(String stubCode) async {
    debugPrint('getStudentsByStubCode called with stubCode: $stubCode');
    final response = await supabase
        .from('student_enrollment_details_view')
        .select('''
            enrollment_status,
            stub_code,
            students (
              display_id,
              profiles (
                first_name,
                middle_name,
                last_name
              )
            )
          ''')
        .eq('stub_code', stubCode);

    debugPrint(
      "Raw response from student_enrollment_details_view for stub_code $stubCode: $response",
    );
    return response
        .map((studentMap) => StudentProfileDTO.fromMap(studentMap))
        .toList();
  }

  Future<List<StudentMasterListDTO>> getStudentMasterListByStubCode(
    String stubCode,
  ) async {
    debugPrint(
      'getStudentMasterListByStubCode called with stubCode: $stubCode',
    );
    final response = await supabase
        .from('student_enrollment_details_view')
        .select(
          'subject_id, first_name, middle_name, last_name, display_id, enrollment_status',
        )
        .eq('stub_code', stubCode);

    debugPrint(
      'Raw response from student_enrollment_details_view for master list $stubCode: $response',
    );
    return response
        .map((studentMap) => StudentMasterListDTO.fromMap(studentMap))
        .toList();
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

final studentsByStubCodeProvider =
    FutureProvider.family<List<StudentProfileDTO>, String>((
      ref,
      stubCode,
    ) async {
      debugPrint('studentsByStubCodeProvider called with stubCode: $stubCode');
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getStudentsByStubCode(stubCode);
    });

final studentMasterListByStubCodeProvider =
    FutureProvider.family<List<StudentMasterListDTO>, String>((
      ref,
      stubCode,
    ) async {
      debugPrint(
        'studentMasterListByStubCodeProvider called with stubCode: $stubCode',
      );
      final repository = ref.watch(studentRepositoryProvider);
      debugPrint('Fetched StudentRepository: $repository');
      return await repository.getStudentMasterListByStubCode(stubCode);
    });
