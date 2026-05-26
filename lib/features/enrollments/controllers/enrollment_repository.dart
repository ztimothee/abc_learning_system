import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_details_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_items_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EnrollmentRepository {
  final SupabaseClient supabase;

  EnrollmentRepository({required this.supabase});

  Future<List<EnrollmentDetailsDTO>>
  getAllStudentsWithAssignedSubjects() async {
    final List<Map<String, dynamic>> response = await supabase
        .from('enrollments')
        .select('''
        enrollment_id,
        students (
          profiles (
            first_name,
            middle_name,
            last_name,
          )
        )
      ''')
        .eq('status', 1); // Only fetch active enrollments

    return response
        .map((enrollmentMap) => EnrollmentDetailsDTO.fromMap(enrollmentMap))
        .toList();
  }

  // Using native eager-loading proved to be too messy, so we will use a view to fetch all necessary data in one query and then map it to our DTOs.
  Future<StudentEnrollmentSummaryDTO> getEnrollmentsForStudent(
    String studentId,
  ) async {
    final List<Map<String, dynamic>> response = await supabase
        .from(
          'student_enrollment_details_view',
        ) // This is a view that joins enrollments with subjects and schedules to get all necessary info in one query
        .select()
        .eq('student_id', studentId);

    final List<EnrollmentItemsDTO> subjectList = response
        .map((enrollmentMap) => EnrollmentItemsDTO.fromMap(enrollmentMap))
        .toList();

    final double totalTuition = response.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          (double.tryParse(item['tuition_fee']?.toString() ?? '0') ?? 0.0),
    );

    return StudentEnrollmentSummaryDTO(
      enrollments: subjectList,
      totalTuition: totalTuition,
    );
  }

  Future<void> enrollStudentInSubject({
    required String studentId,
    required String subjectId,
  }) async {
    await supabase.from('enrollments').insert({
      'student_id': studentId,
      'subject_id': subjectId,
      'status': 1, // Active enrollment
    });
  }

  // Set status 0 enrollment to 1 to confirm enrollment, or set it to 0 to cancel enrollment
  Future<void> updateEnrollmentStatus({
    required String enrollmentId,
    required int newStatus,
  }) async {
    await supabase
        .from('enrollments')
        .update({'status': newStatus})
        .eq('enrollment_id', enrollmentId);
  }

  Future<void> updateEnrollmentStatuses({
    required List<String> enrollmentIds,
    required int newStatus,
  }) async {
    for (final enrollmentId in enrollmentIds) {
      await updateEnrollmentStatus(
        enrollmentId: enrollmentId,
        newStatus: newStatus,
      );
    }
  }
}

final enrollmentRepositoryProvider = Provider<EnrollmentRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);
  return EnrollmentRepository(supabase: supabase);
});

final studentEnrollmentSummaryProvider =
    FutureProvider.family<StudentEnrollmentSummaryDTO, String>((
      ref,
      studentId,
    ) async {
      final repository = ref.watch(enrollmentRepositoryProvider);
      return await repository.getEnrollmentsForStudent(studentId);
    });
