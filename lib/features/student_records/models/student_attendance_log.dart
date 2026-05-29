class StudentAttendanceLog {
  final String enrollmentId;
  final String studentDisplayId;
  final String studentName;
  int status; // 0: Unmarked, 1: Present, 2: Absent, 3: Late, 4: Excused

  StudentAttendanceLog({
    required this.enrollmentId,
    required this.studentDisplayId,
    required this.studentName,
    this.status = 1, // Default to Present for quick marking
  });

  factory StudentAttendanceLog.fromMap(Map<String, dynamic> map) {
    final attendanceList = map['attendances'] as List<dynamic>? ?? [];

    int initialStatus = 1; // Default to Unmarked

    if (attendanceList.isNotEmpty) {
      initialStatus = attendanceList.first['status'] ?? 1; 
    }

    final firstName = map['first_name'] as String? ?? '';
    final middleName = map['middle_name'] as String? ?? '';
    final lastName = map['last_name'] as String? ?? '';

    return StudentAttendanceLog(
      enrollmentId: map['enrollment_id'] ?? '',
      studentDisplayId: map['student_id'] ?? 'N/A',
      studentName: '$firstName $middleName $lastName'.trim(),
      status: initialStatus,
    );
  }
}
