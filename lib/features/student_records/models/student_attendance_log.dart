class StudentAttendanceLog {
  final String attendanceId;
  final String enrollmentId;
  final String studentDisplayId;
  final String studentName;
  int status; // 0: Unmarked, 1: Present, 2: Absent, 3: Late, 4: Excused

  StudentAttendanceLog({
    required this.attendanceId,
    required this.enrollmentId,
    required this.studentDisplayId,
    required this.studentName,
    required this.status, // Default to Present for quick marking
  });

  factory StudentAttendanceLog.fromPreGenMap(Map<String, dynamic> map) {
    final enrollment = map['enrollments'] as Map<String, dynamic>? ?? {};
    final student = enrollment['students'] as Map<String, dynamic>? ?? {};
    final profile = student['profiles'] as Map<String, dynamic>? ?? {};

    final firstName = profile['first_name'] as String? ?? '';
    final middleName = profile['middle_name'] as String? ?? '';
    final lastName = profile['last_name'] as String? ?? '';

    return StudentAttendanceLog(
      attendanceId: map['attendance_id'] ?? '', 
      enrollmentId: enrollment['enrollment_id'] ?? '',
      studentDisplayId: student['student_id'] ?? 'N/A',
      studentName: '$firstName $middleName $lastName'.trim(),
      status: map['status'] ?? 0,
    );
  }
}
