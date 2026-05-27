import 'package:abc_learning_system/core/services/supabase.dart';
import 'package:abc_learning_system/features/enrollments/models/batched_subjects_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_details_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_items_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/tutor_subjects_dto.dart';
import 'package:flutter/material.dart';
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

  Future<List<TutorSubjectsDTO>> getAssignedSubjectsForTutorByTutorId(
    String tutorId,
  ) async {
    final response = await supabase
        .from('subject_assignments')
        .select('''
          subject_assigned_id,
          stub_code,
          subjects (
            subject_id,
            subject_name
          )
        ''')
        .eq('tutor_id', tutorId);

    return response
        .map((scheduleMap) => TutorSubjectsDTO.fromMap(scheduleMap))
        .toList();
  }

  // Using native eager-loading proved to be too messy, so we will use a view to fetch all necessary data in one query and then map it to our DTOs.
  Future<StudentEnrollmentSummaryDTO> getEnrollmentsForStudent(
    String studentId,
  ) async {
    debugPrint(
      'EnrollmentRepository.getEnrollmentsForStudent called with studentId: $studentId',
    );
    final List<Map<String, dynamic>> response = await supabase
        .from(
          'student_enrollment_details_view',
        ) // This is a view that joins enrollments with subjects and schedules to get all necessary info in one query
        .select()
        .eq('student_id', studentId);

    debugPrint('Raw response from student_enrollment_details_view: $response');
    final List<EnrollmentItemsDTO> subjectList = response
        .map((enrollmentMap) => EnrollmentItemsDTO.fromMap(enrollmentMap))
        .toList();

    debugPrint('Mapped EnrollmentItemsDTO list: $subjectList');
    final double totalTuition = response.fold<double>(
      0.0,
      (sum, item) =>
          sum +
          (double.tryParse(item['tuition_fee']?.toString() ?? '0') ?? 0.0),
    );

    debugPrint('Calculated total tuition: $totalTuition');
    return StudentEnrollmentSummaryDTO(
      enrollments: subjectList,
      totalTuition: totalTuition,
    );
  }

  Future<List<BatchedSubjectsDTO>> getAllBatchedSubjects() async {
    final response = await supabase.from('batched_subjects').select('''
          batch_id,
          batch_name,
          created_at,
          subject_to_batch (
            subjects (
              subject_id,
              subject_name,
              tuition_fee
            )
          )
        ''');

    return response
        .map((batchMap) => BatchedSubjectsDTO.fromMap(batchMap))
        .toList();
  }

  // OPERATIONS FOR ENROLLMENT MANAGEMENT ===========================================================================================

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

  Future<void> batchEnrollStudentInSubjects({
    required String studentId,
    required String batchId,
  }) async {
    await supabase.rpc(
      'enroll_student_in_batch',
      params: {'p_student_id': studentId, 'p_batch_id': batchId},
    );
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

  Future<void> updateMultipleEnrollmentStatus({
    required List<String> enrollmentIds,
    required int newStatus,
  }) async {
    if (enrollmentIds.isEmpty) return; // No enrollments to update

    // Do this in only a single query to avoid multiple round trips to the database
    await supabase
        .from('enrollments')
        .update({'status': newStatus})
        .inFilter('enrollment_id', enrollmentIds);
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
      debugPrint('Fetching enrollments for student ID: $studentId');
      final repository = ref.watch(enrollmentRepositoryProvider);
      debugPrint('EnrollmentRepository instance: $repository');
      return await repository.getEnrollmentsForStudent(studentId);
    });

final tutorAssignedSubjectsProvider =
    FutureProvider.family<List<TutorSubjectsDTO>, String>((ref, tutorId) async {
      final repository = ref.watch(enrollmentRepositoryProvider);
      return repository.getAssignedSubjectsForTutorByTutorId(tutorId);
    });

final allBatchedSubjectsProvider = FutureProvider<List<BatchedSubjectsDTO>>((
  ref,
) async {
  final repository = ref.watch(enrollmentRepositoryProvider);
  return repository.getAllBatchedSubjects();
});
