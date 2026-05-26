import 'package:abc_learning_system/features/student_records/models/subject.dart';
import 'package:abc_learning_system/shared/tutors/models/tutor_profile_dto.dart';

class SubjectAssignmentDTO {
  final String subjectAssignedId;
  final String stubCode;
  final TutorProfileDTO? tutor;
  final Subject? subject;

  SubjectAssignmentDTO({
    required this.subjectAssignedId,
    required this.stubCode,
    this.tutor,
    this.subject,
  });

  // Factory constructor to create a SubjectAssignmentDTO from a map (e.g., from Supabase)
  factory SubjectAssignmentDTO.fromMap(Map<String, dynamic> map) {
    return SubjectAssignmentDTO(
      subjectAssignedId: map['subject_assigned_id'] as String,
      stubCode: map['stub_code'] as String,
      tutor: map['tutors'] != null
          ? TutorProfileDTO.fromMap(map['tutors'] as Map<String, dynamic>)
          : null,
      subject: map['subjects'] != null
          ? Subject.fromMap(map['subjects'] as Map<String, dynamic>)
          : null,
    );
  }
}
