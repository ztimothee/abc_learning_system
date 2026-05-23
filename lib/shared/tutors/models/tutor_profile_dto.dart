import 'package:abc_learning_system/features/auth/models/profile.dart';

class TutorProfileDTO {
  final String tutorId;
  final Profile? profile;

  TutorProfileDTO({required this.tutorId, this.profile});

  // Factory method to create a TutorProfileDTO instance from a map (e.g., from database query results)
  factory TutorProfileDTO.fromMap(Map<String, dynamic> map) {
    return TutorProfileDTO(
      tutorId: map['tutor_id'],
      profile: map['profile'] != null ? Profile.fromMap(map['profile']) : null,
    );
  }
}
