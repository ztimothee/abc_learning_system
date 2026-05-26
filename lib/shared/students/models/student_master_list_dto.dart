class StudentMasterListDTO {
  final String subjectId;
  final String firstName;
  final String middleName;
  final String lastName;
  final String displayId;
  final String enrollmentStatus;

  StudentMasterListDTO({
    required this.subjectId,
    required this.firstName,
    required this.middleName,
    required this.lastName,
    required this.displayId,
    required this.enrollmentStatus,
  });

  // Factory constructor to create a StudentMasterListDTO from a map (e.g., from Supabase)
  factory StudentMasterListDTO.fromMap(Map<String, dynamic> map) {
    return StudentMasterListDTO(
      subjectId: map['subject_id'] as String,
      firstName: map['first_name'] as String,
      middleName: map['middle_name'] as String,
      lastName: map['last_name'] as String,
      displayId: map['display_id'] as String,
      enrollmentStatus: map['enrollment_status'] as String,
    );
  }
}
