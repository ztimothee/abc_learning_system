class TutorProfileDTO {
  final String tutorId;
  final String displayId;
  final String userId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String contactNumber;
  final String address;
  final int civilStatus;
  final String role;

  TutorProfileDTO({
    required this.tutorId,
    required this.displayId,
    required this.userId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    required this.contactNumber,
    required this.address,
    required this.civilStatus,
    required this.role,
  });

  // Factory method to create a TutorProfileDTO instance from a map (e.g., from database query results)
  factory TutorProfileDTO.fromMap(Map<String, dynamic> map) {
    final profileMap = map['profiles'] as Map<String, dynamic>;

    return TutorProfileDTO(
      tutorId: map['tutor_id'] ?? '',
      displayId: map['display_id'] ?? '',
      userId: profileMap['user_id'] ?? '',
      firstName: profileMap['first_name'] ?? '',
      middleName: profileMap['middle_name'] ?? '',
      lastName: profileMap['last_name'] ?? '',
      dateOfBirth: DateTime.parse(profileMap['date_of_birth'] ?? DateTime.now()),
      gender: profileMap['gender'] ?? '',
      contactNumber: profileMap['contact_number'] ?? '',
      address: profileMap['address'] ?? '',
      civilStatus: profileMap['civil_status'] ?? 0,
      role: profileMap['role'] ?? '',
    );
  }
}
