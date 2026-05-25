import 'package:abc_learning_system/features/enrollments/controllers/enrollment_repository.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_details_dto.dart';
import 'package:abc_learning_system/features/enrollments/models/enrollment_items_dto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnrollmentOperationController extends AsyncNotifier<void>{
  @override
  Future<void> build() async {
    // No initialization needed for now
  }

  Future<List<EnrollmentDetailsDTO>> fetchAllEnrollments() async {
    final enrollmentRepository = ref.read(enrollmentRepositoryProvider);
    return await enrollmentRepository.getAllStudentsWithAssignedSubjects();
  }

  Future<StudentEnrollmentSummaryDTO> fetchStudentEnrollments(String studentId) async {
    final enrollmentRepository = ref.read(enrollmentRepositoryProvider);
    return await enrollmentRepository.getEnrollmentsForStudent(studentId);
  }
}