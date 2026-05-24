import 'package:abc_learning_system/features/enrollments/models/scheduled_subject_dto.dart';
import 'package:abc_learning_system/shared/students/models/student_profile_dto.dart';

class EnrollmentDetailsDTO {
  final String enrollmentId;
  final StudentProfileDTO? student;
  final ScheduledSubjectDTO? scheduledSubject;

  EnrollmentDetailsDTO({
    required this.enrollmentId,
    this.student,
    this.scheduledSubject,
  });

  // Factory constructor to create an EnrollmentDetailsDTO from a map (e.g., from Supabase)
  factory EnrollmentDetailsDTO.fromMap(Map<String, dynamic> map) {
    return EnrollmentDetailsDTO(
      enrollmentId: map['enrollment_id'] as String,
      student: map['student'] != null
          ? StudentProfileDTO.fromMap(map['student'] as Map<String, dynamic>)
          : null,
      scheduledSubject: map['scheduled_subject'] != null
          ? ScheduledSubjectDTO.fromMap(
              map['scheduled_subject'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}
