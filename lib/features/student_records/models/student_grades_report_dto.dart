class StudentGradesReportDTO {
  final String enrollmentId;
  final String subjectName;
  final String stubCode;
  final int? finalGrade;
  final String remarks;

  StudentGradesReportDTO({
    required this.enrollmentId,
    required this.subjectName,
    required this.stubCode,
    this.finalGrade,
    required this.remarks,
  });

  factory StudentGradesReportDTO.fromMap(Map<String, dynamic> map) {
    // 1. Safely extract parent 'subjects' object data
    final subjectsMap = map['subjects'] as Map<String, dynamic>? ?? {};
    final extractedSubjectName = subjectsMap['subject_name']?.toString() ?? 'Unknown Subject';

    // 2. Safely extract nested child 'subject_assignments' (handles list vs object)
    String extractedStubCode = 'N/A';
    final rawAssignments = subjectsMap['subject_assignments'];
    if (rawAssignments is List && rawAssignments.isNotEmpty) {
      extractedStubCode = rawAssignments.first['stub_code']?.toString() ?? 'N/A';
    } else if (rawAssignments is Map) {
      extractedStubCode = rawAssignments['stub_code']?.toString() ?? 'N/A';
    }

    // 3. DEFENSIVE FIX: Handle 'grades' whether it returns a single Map or a List
    Map<String, dynamic> gradeData = {};
    final rawGrades = map['grades'];
    
    if (rawGrades is Map<String, dynamic>) {
      // PostgREST 1-to-1 single object response mapping
      gradeData = rawGrades;
    } else if (rawGrades is List && rawGrades.isNotEmpty) {
      // Fallback fallback collection mapping
      gradeData = rawGrades.first as Map<String, dynamic>? ?? {};
    }

    return StudentGradesReportDTO(
      enrollmentId: map['enrollment_id']?.toString() ?? '',
      subjectName: extractedSubjectName,
      stubCode: extractedStubCode,
      finalGrade: gradeData['final_grade'] != null 
          ? int.tryParse(gradeData['final_grade'].toString()) 
          : null,
      remarks: gradeData['remarks']?.toString() ?? '',
    );
  }
}