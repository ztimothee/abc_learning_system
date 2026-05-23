import 'package:abc_learning_system/features/student_records/models/subject.dart';

class DebitDTO {
  final String enrollmentId;
  final int status;
  final DateTime createdAt;
  final String studentId;
  final Subject? subject;

  DebitDTO({
    required this.enrollmentId,
    required this.status,
    required this.createdAt,
    required this.studentId,
    this.subject,
  });

  // Method to convert a DebitDTO instance to a map to submit to the database
  factory DebitDTO.fromMap(Map<String, dynamic> map) {
    return DebitDTO(
      enrollmentId: map['enrollment_id'],
      status: map['status'],
      createdAt: DateTime.parse(map['created_at']),
      studentId: map['student_id'],
      subject: map['subject'] != null ? Subject.fromMap(map['subject']) : null,
    );
  }
}
