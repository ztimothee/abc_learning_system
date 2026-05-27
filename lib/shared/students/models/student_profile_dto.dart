import 'package:abc_learning_system/features/auth/models/profile.dart';

class StudentProfileDTO {
  final String studentId;
  final String displayId;
  final Profile? profile;

  StudentProfileDTO({
    required this.studentId,
    required this.displayId,
    this.profile,
  });

  // Factory method to create a StudentProfileDTO instance from a map (e.g., from database query results)
  factory StudentProfileDTO.fromMap(Map<String, dynamic> map) {
    return StudentProfileDTO(
      studentId: map['student_id'],
      displayId: map['display_id'],
      profile: map['profiles'] != null ? Profile.fromMap(map['profiles']) : null,
    );
  }
}
