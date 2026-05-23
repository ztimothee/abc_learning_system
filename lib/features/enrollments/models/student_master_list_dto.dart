import 'package:abc_learning_system/shared/students/models/student_profile_dto.dart';

class StudentMasterListDTO {
  final String enrollmentId;
  final String subjectId;
  final int status;
  final StudentProfileDTO? student;

  StudentMasterListDTO({
    required this.enrollmentId,
    required this.subjectId,
    required this.status,
    this.student,
  });

  // Factory constructor to create a StudentMasterListDTO from a map (e.g., from Supabase)
  factory StudentMasterListDTO.fromMap(Map<String, dynamic> map) {
    return StudentMasterListDTO(
      enrollmentId: map['enrollment_id'] as String,
      subjectId: map['subject_id'] as String,
      status: map['status'] as int,
      student: map['student'] != null
          ? StudentProfileDTO.fromMap(map['student'] as Map<String, dynamic>)
          : null,
    );
  }
}
