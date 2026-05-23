import 'package:abc_learning_system/features/enrollments/models/enrollment_details_dto.dart';

class StudentRecordDTO {
  final String gradeId;
  final int finalGrade;
  final String remarks;
  final EnrollmentDetailsDTO? enrollmentDetails;

  StudentRecordDTO({
    required this.gradeId,
    required this.finalGrade,
    required this.remarks,
    this.enrollmentDetails,
  });

  // Factory constructor to create a StudentRecordDTO from a map (e.g., from Supabase)
  factory StudentRecordDTO.fromMap(Map<String, dynamic> map) {
    return StudentRecordDTO(
      gradeId: map['grade_id'] as String,
      finalGrade: map['final_grade'] as int,
      remarks: map['remarks'] as String,
      enrollmentDetails: map['enrollment_details'] != null
          ? EnrollmentDetailsDTO.fromMap(
              map['enrollment_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
