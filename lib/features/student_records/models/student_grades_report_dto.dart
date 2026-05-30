class StudentGradesReportDTO {
  final String enrollmentId;
  final String subjectName;
  final int? finalGrade; // Nullable, because a grade might not be encoded yet
  final String stubCode;
  final String remarks;

  StudentGradesReportDTO({
    required this.enrollmentId,
    required this.subjectName,
    this.finalGrade,
    required this.stubCode,
    required this.remarks,
  });

  factory StudentGradesReportDTO.fromMap(Map<String, dynamic> map) {
    // 1. Extract nested subject details
    final subject = map['subjects'] as Map<String, dynamic>? ?? {};

    final assignmentsList = map['subject_assignments'] as List<dynamic>? ?? [];
    String stubCodeValue = 'N/A';
    if (assignmentsList.isNotEmpty) {
      stubCodeValue = assignmentsList.first['stub_code'] ?? 'N/A';
    }

    // 2. Extract nested grade records (comes as a list or a map depending on relations)
    final gradeList = map['grades'] as List<dynamic>? ?? [];

    int? gradeValue;
    String remarksValue = 'In Progress';

    if (gradeList.isNotEmpty) {
      final gradeMap = gradeList.first as Map<String, dynamic>;
      gradeValue = gradeMap['final_grade'];
      remarksValue = gradeMap['remarks'] ?? '';
    }

    return StudentGradesReportDTO(
      enrollmentId: map['enrollment_id'] ?? '',
      subjectName: subject['subject_name'] ?? 'Unknown Subject',
      stubCode: stubCodeValue,
      finalGrade: gradeValue,
      remarks: remarksValue,
    );
  }
}
