import 'package:abc_learning_system/features/auth/models/profile.dart';

class StudentProfileDTO {
  final String studentId;
  final Profile? profile;

  StudentProfileDTO({required this.studentId, this.profile});

  // Factory method to create a StudentProfileDTO instance from a map (e.g., from database query results)
  factory StudentProfileDTO.fromMap(Map<String, dynamic> map) {
    return StudentProfileDTO(
      studentId: map['student_id'],
      profile: map['profile'] != null ? Profile.fromMap(map['profile']) : null,
    );
  }
}
