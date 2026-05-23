import 'package:abc_learning_system/features/auth/models/profile.dart';

class StaffProfileDTO {
  final String staffId;
  final String position;
  final Profile? profile;

  StaffProfileDTO({
    required this.staffId,
    required this.position,
    this.profile,
  });

  // Factory method to create a StaffProfileDTO instance from a map (e.g., from database query results)
  factory StaffProfileDTO.fromMap(Map<String, dynamic> map) {
    return StaffProfileDTO(
      staffId: map['staff_id'],
      position: map['position'],
      profile: map['profile'] != null ? Profile.fromMap(map['profile']) : null,
    );
  }
}
