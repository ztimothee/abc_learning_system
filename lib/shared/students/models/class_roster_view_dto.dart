import 'package:abc_learning_system/core/themes/formatting_functions.dart';

class ClassRosterViewDTO {
  final String enrollmentId;
  final int enrollmentStatus;
  final String studentId;
  final String displayId;
  final int yearLevel;
  final String fullName;
  final String gender;
  final String contactNumber;

  ClassRosterViewDTO({
    required this.enrollmentId,
    required this.enrollmentStatus,
    required this.studentId,
    required this.displayId,
    required this.yearLevel,
    required this.fullName,
    required this.gender,
    required this.contactNumber,
  });

  factory ClassRosterViewDTO.fromMap(Map<String, dynamic> map) {
    final firstName = map['first_name'] ?? '';
    final middleName = map['middle_name'] != null ? '${map['middle_name']} ' : '';
    final lastName = map['last_name'] ?? '';
    final combinedName = buildFullNameSurnameFirst(firstName, middleName, lastName);

    return ClassRosterViewDTO(
      enrollmentId: map['enrollment_id'] ?? '',
      enrollmentStatus: map['status'] ?? 0,
      studentId: map['student_id'] ?? '',
      displayId: map['display_id'] ?? 'N/A',
      yearLevel: map['year_level'] ?? 1,
      fullName: combinedName.isEmpty ? 'Unknown Student' : combinedName,
      gender: map['gender'] ?? 'Not Specified',
      contactNumber: map['contact_number'] ?? 'No Contact',
    );
  }
}